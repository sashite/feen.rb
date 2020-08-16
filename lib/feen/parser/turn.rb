# frozen_string_literal: true

module FEEN
  module Parser
    # The turn class.
    module Turn
      # @param active_side_id [String] The identifier of bottom-side and
      #   top-side.
      #
      # @example Parse the number that identify the player who have to play
      #   parse("0") # => 0
      #
      # @return [Integer] The number that identify the player who have to play.
      def self.parse(active_side_id)
        Integer(active_side_id)
      end
    end
  end
end
