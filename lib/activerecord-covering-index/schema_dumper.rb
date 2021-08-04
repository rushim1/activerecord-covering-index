# frozen_string_literal: true

module ActiverecordCoveringIndex
  module SchemaDumper
    private

    def index_parts(index)
      index_parts = super
      index_parts << "include: #{index.include.inspect}" if index.include.present?
      index_parts
    end
  end
end
