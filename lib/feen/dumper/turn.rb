# frozen_string_literal: true

module FEEN
  module Dumper
    # The turn class.
    module Turn
      # @param active_side [Integer] The identifier of the active player.
      # @param sides_count [Integer] The number of players.
      #
      # @return [String] The number that identify the player who have to play.
      def self.dump(active_side, sides_count)
        String(Integer(active_side) % Integer(sides_count))
      end
    end
  end
end
