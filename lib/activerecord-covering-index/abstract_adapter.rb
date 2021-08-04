# frozen_string_literal: true

module ActiverecordCoveringIndex
  module AbstractAdapter
    def supports_covering_index?
      false
    end
  end
end
