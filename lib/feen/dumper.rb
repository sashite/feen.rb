# frozen_string_literal: true

require_relative "dumper/board"
require_relative "dumper/pieces_in_hand"
require_relative "dumper/turn"

module FEEN
  # The dumper module.
  module Dumper
    # Dump position params into a FEEN string.
    #
    # @param active_side_id [Integer] The identifier of the player who must play.
    # @param board [Hash] The indexes of each piece on the board.
    # @param indexes [Array] The shape of the board.
    # @param pieces_in_hand_grouped_by_sides [Array] The list of pieces in hand
    #   grouped by players.
    #
    # @example Dump a classic Tsume Shogi problem
    #   call(
    #     "active_side_id": 0,
    #     "board": {
    #       "3": "s",
    #       "4": "k" ,
    #       "5": "s",
    #       "22": "+P",
    #       "43": "+B"
    #     },
    #     "indexes": [9, 9],
    #     "pieces_in_hand_grouped_by_sides": [
    #       %w[S],
    #       %w[r r b g g g g s n n n n p p p p p p p p p p p p p p p p p]
    #     ]
    #   )
    #   # => "3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 0 S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s"
    #
    # @return [String] The FEEN string representing the position.
    def self.call(active_side_id:, board:, indexes:, pieces_in_hand_grouped_by_sides:)
      [
        Board.new(indexes, board).to_s,
        Turn.dump(active_side_id, pieces_in_hand_grouped_by_sides.length),
        PiecesInHand.dump(pieces_in_hand_grouped_by_sides)
      ].join(" ")
    end
  end
end
