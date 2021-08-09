# frozen_string_literal: true

module ActiverecordCoveringIndex
  module PostgreSQLAdapter
    def supports_covering_index?
      if respond_to?(:database_version) # ActiveRecord 6+
        database_version >= 110_000
      else
        postgresql_version >= 110_000
      end
    end

    def add_index_options(table_name, column_name, name: nil, if_not_exists: false, internal: false, **options)
      options.assert_valid_keys(:unique, :length, :order, :opclass, :where, :type, :using, :comment, :algorithm, :include)

      options[:name] = name if name
      options[:internal] = internal
      non_key_columns = options.delete(:include)

      original_index_options = super(table_name, column_name, **options)

      if original_index_options.first.is_a?(String)
        index_name, index_type, index_columns, index_options, algorithm, using, comment = original_index_options

        if non_key_columns && supports_covering_index?
          non_key_columns = [non_key_columns] if non_key_columns.is_a?(Symbol)
          non_key_columns = quoted_columns_for_index(non_key_columns, {}).join(", ")

          index_options = " INCLUDE (#{non_key_columns})" + index_options
        end

        [index_name, index_type, index_columns, index_options, algorithm, using, comment]
      else
        index, algorithm, if_not_exists = original_index_options

        index_with_include = ActiveRecord::ConnectionAdapters::IndexDefinition.new(
          index.table,
          index.name,
          index.unique,
          index.columns,
          lengths: index.lengths,
          orders: index.orders,
          opclasses: index.opclasses,
          where: index.where,
          type: index.type,
          using: index.using,
          comment: index.comment,
          include: non_key_columns
        )

        [index_with_include, algorithm, if_not_exists]
      end
    end

    def indexes(table_name)
      scope = quoted_scope(table_name)

      result = query(<<~SQL, "SCHEMA")
        SELECT distinct i.relname, d.indisunique, d.indkey, pg_get_indexdef(d.indexrelid), t.oid,
                        pg_catalog.obj_description(i.oid, 'pg_class') AS comment, d.indnkeyatts
        FROM pg_class t
        INNER JOIN pg_index d ON t.oid = d.indrelid
        INNER JOIN pg_class i ON d.indexrelid = i.oid
        LEFT JOIN pg_namespace n ON n.oid = i.relnamespace
        WHERE i.relkind IN ('i', 'I')
          AND d.indisprimary = 'f'
          AND t.relname = #{scope[:name]}
          AND n.nspname = #{scope[:schema]}
        ORDER BY i.relname
      SQL

      result.map do |row|
        index_name = row[0]
        unique = row[1]
        indkey = row[2].split(" ").map(&:to_i)
        inddef = row[3]
        oid = row[4]
        comment = row[5]
        indnkeyatts = row[6]

        using, expressions, _, where = inddef.scan(/ USING (\w+?) \((.+?)\)(?: INCLUDE \((.+?)\))?(?: WHERE (.+))?\z/m).flatten

        orders = {}
        opclasses = {}

        columns = Hash[query(<<~SQL, "SCHEMA")].values_at(*indkey)
          SELECT a.attnum, a.attname
          FROM pg_attribute a
          WHERE a.attrelid = #{oid}
          AND a.attnum IN (#{indkey.join(",")})
        SQL

        non_key_columns = columns.pop(columns.count - indnkeyatts)

        if indkey.include?(0)
          columns = expressions
        else
          # add info on sort order (only desc order is explicitly specified, asc is the default)
          # and non-default opclasses
          expressions.scan(/(?<column>\w+)"?\s?(?<opclass>\w+_ops)?\s?(?<desc>DESC)?\s?(?<nulls>NULLS (?:FIRST|LAST))?/).each do |column, opclass, desc, nulls|
            opclasses[column] = opclass.to_sym if opclass
            if nulls
              orders[column] = [desc, nulls].compact.join(" ")
            else
              orders[column] = :desc if desc
            end
          end
        end

        ActiveRecord::ConnectionAdapters::IndexDefinition.new(
          table_name,
          index_name,
          unique,
          columns,
          orders: orders,
          opclasses: opclasses,
          where: where,
          using: using.to_sym,
          comment: comment.presence,
          include: non_key_columns
        )
      end
    end
  end
end
