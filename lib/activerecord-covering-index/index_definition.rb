# frozen_string_literal: true

module ActiverecordCoveringIndex
  module IndexDefinition
    def self.prepended(base)
      base.attr_reader :include
    end

    def initialize(
      table, name,
      unique = false,
      columns = [],
      lengths: {},
      orders: {},
      opclasses: {},
      where: nil,
      type: nil,
      using: nil,
      comment: nil,
      include: []
    )
      @table = table
      @name = name
      @unique = unique
      @columns = columns
      @lengths = concise_options(lengths)
      @orders = concise_options(orders)
      @opclasses = concise_options(opclasses)
      @where = where
      @type = type
      @using = using
      @comment = comment
      @include = include
    end
  end
end
