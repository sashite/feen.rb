# frozen_string_literal: true

require_relative 'dumper/board'
require_relative 'dumper/pieces_in_hand'
require_relative 'dumper/turn'

module FEEN
  # The dumper module.
  module Dumper
    # Dump position params into a FEEN string.
    #
    # @param active_side [Integer] The identifier of the player who must play.
    # @param indexes [Array] The shape of the board.
    # @param pieces_in_hand_grouped_by_sides [Array] The list of pieces in hand
    #   grouped by players.
    # @param squares [Array] The list of squares on the board.
    #
    # @example Dump Four-player chess's starting position
    #   call(
    #     active_side: 0,
    #     indexes: [14, 14],
    #     pieces_in_hand_grouped_by_sides: [
    #       [],
    #       [],
    #       [],
    #       []
    #     ],
    #     squares: [
    #       nil , nil , nil , "yR", "yN", "yB", "yK", "yQ", "yB", "yN", "yR", nil , nil , nil ,
    #       nil , nil , nil , "yP", "yP", "yP", "yP", "yP", "yP", "yP", "yP", nil , nil , nil ,
    #       nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil ,
    #       "bR", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gR",
    #       "bN", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gN",
    #       "bB", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gB",
    #       "bK", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gQ",
    #       "bQ", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gK",
    #       "bB", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gB",
    #       "bN", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gN",
    #       "bR", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gR",
    #       nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil ,
    #       nil , nil , nil , "rP", "rP", "rP", "rP", "rP", "rP", "rP", "rP", nil , nil , nil ,
    #       nil , nil , nil , "rR", "rN", "rB", "rQ", "rK", "rB", "rN", "rR", nil , nil , nil
    #     ]
    #   )
    #   # => "3,yR,yN,yB,yK,yQ,yB,yN,yR,3/3,yP,yP,yP,yP,yP,yP,yP,yP,3/14/bR,bP,10,gP,gR/bN,bP,10,gP,gN/bB,bP,10,gP,gB/bK,bP,10,gP,gQ/bQ,bP,10,gP,gK/bB,bP,10,gP,gB/bN,bP,10,gP,gN/bR,bP,10,gP,gR/14/3,rP,rP,rP,rP,rP,rP,rP,rP,3/3,rR,rN,rB,rQ,rK,rB,rN,rR,3 0 ///"
    #
    # @return [String] The FEEN string representing the position.
    def self.call(active_side:, indexes:, pieces_in_hand_grouped_by_sides:, squares:)
      [
        Board.new(*indexes).to_s(*squares),
        Turn.dump(active_side, pieces_in_hand_grouped_by_sides.length),
        PiecesInHand.dump(*pieces_in_hand_grouped_by_sides)
      ].join(' ')
    end
  end
end
