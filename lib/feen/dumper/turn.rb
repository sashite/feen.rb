# frozen_string_literal: true

module FEEN
  module Dumper
    # The turn module.
    module Turn
      # @param active_side_id [Integer] The identifier of the active player.
      # @param sides_count [Integer] The number of players.
      #
      # @example Dump the number that identify the player who have to play
      #   dump(0, 2) # => "0"
      #
      # @return [String] The number that identify the player who have to play.
      def self.dump(active_side_id, sides_count)
        String(Integer(active_side_id) % Integer(sides_count))
      end
    end
  end
end
