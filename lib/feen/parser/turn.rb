# frozen_string_literal: true

module FEEN
  module Parser
    # The turn class.
    module Turn
      # @param active_side_id [String] The identifier of bottom-side and top-side.
      #
      # @return [Integer] The number of the active side.
      def self.parse(active_side_id)
        Integer(active_side_id)
      end
    end
  end
end
