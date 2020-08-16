# frozen_string_literal: true

require_relative 'parser/board'
require_relative 'parser/pieces_in_hand'
require_relative 'parser/shape'
require_relative 'parser/turn'

module FEEN
  # The parser module.
  module Parser
    # Parse a FEEN string into position params.
    #
    # @param feen [String] The FEEN string representing a position.
    #
    # @example Parse Four-player chess's starting position
    #   call("3,yR,yN,yB,yK,yQ,yB,yN,yR,3/3,yP,yP,yP,yP,yP,yP,yP,yP,3/14/bR,bP,10,gP,gR/bN,bP,10,gP,gN/bB,bP,10,gP,gB/bK,bP,10,gP,gQ/bQ,bP,10,gP,gK/bB,bP,10,gP,gB/bN,bP,10,gP,gN/bR,bP,10,gP,gR/14/3,rP,rP,rP,rP,rP,rP,rP,rP,3/3,rR,rN,rB,rQ,rK,rB,rN,rR,3 0 ///")
    #   # => {
    #   #      active_side: 0,
    #   #      indexes: [14, 14],
    #   #      pieces_in_hand_grouped_by_sides: [
    #   #        [],
    #   #        [],
    #   #        [],
    #   #        []
    #   #      ],
    #   #      squares: [
    #   #        nil , nil , nil , "yR", "yN", "yB", "yK", "yQ", "yB", "yN", "yR", nil , nil , nil ,
    #   #        nil , nil , nil , "yP", "yP", "yP", "yP", "yP", "yP", "yP", "yP", nil , nil , nil ,
    #   #        nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil ,
    #   #        "bR", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gR",
    #   #        "bN", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gN",
    #   #        "bB", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gB",
    #   #        "bK", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gQ",
    #   #        "bQ", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gK",
    #   #        "bB", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gB",
    #   #        "bN", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gN",
    #   #        "bR", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gR",
    #   #        nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil ,
    #   #        nil , nil , nil , "rP", "rP", "rP", "rP", "rP", "rP", "rP", "rP", nil , nil , nil ,
    #   #        nil , nil , nil , "rR", "rN", "rB", "rQ", "rK", "rB", "rN", "rR", nil , nil , nil
    #   #      ]
    #   #    }
    #
    # @return [Hash] The position params representing the position.
    def self.call(feen)
      params(*feen.split(' '))
    end

    # Parse the FEEN string's three fields and return the position params.
    #
    # @param board [String] The flatten board.
    # @param active_side [String] The active side identifier.
    # @param in_hand [String] The captured actors.
    #
    # @return [Hash] The position params representing the position.
    private_class_method def self.params(board, active_side, in_hand)
      {
        active_side: Turn.parse(active_side),
        indexes: Shape.new(board).to_a,
        pieces_in_hand_grouped_by_sides: PiecesInHand.parse(in_hand),
        squares: Board.new(board).to_a
      }
    end
  end
end
