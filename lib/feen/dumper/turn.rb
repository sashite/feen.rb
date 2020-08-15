# frozen_string_literal: true

module FEEN
  module Dumper
    # The turn class.
    class Turn
      # @param active_side [String] The identifier of the active player.
      # @param sides_count [Integer] The number of players.
      def initialize(active_side, sides_count)
        @active_side = active_side
        @sides_count = sides_count
      end

      # @return [Integer] The number of the player who have to play.
      def to_i
        Integer(@active_side) % @sides_count
      end
    end
  end
end
