# frozen_string_literal: true

module ActiverecordCoveringIndex
  module SchemaCreation
    def self.prepended(base)
      attr_opts = { to: :@conn }
      attr_opts[:private] = true if ActiveRecord::VERSION::MAJOR >= 6

      base.delegate :supports_covering_index?, attr_opts
    end

    private

    def visit_CreateIndexDefinition(o)
      index = o.index

      sql = ["CREATE"]
      sql << "UNIQUE" if index.unique
      sql << "INDEX"
      sql << "IF NOT EXISTS" if o.if_not_exists
      sql << o.algorithm if o.algorithm
      sql << index.type if index.type
      sql << "#{quote_column_name(index.name)} ON #{quote_table_name(index.table)}"
      sql << "USING #{index.using}" if supports_index_using? && index.using
      sql << "(#{quoted_columns(index)})"
      sql << "INCLUDE (#{quoted_index_includes(index.include)})" if supports_covering_index? && index.include
      sql << "WHERE #{index.where}" if supports_partial_index? && index.where

      sql.join(" ")
    end

    def quoted_index_includes(columns)
      String === columns ? columns : quoted_columns_for_index(Array(columns), {})
    end
  end
end
