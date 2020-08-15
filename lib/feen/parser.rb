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
    # @return [Hash] The position params representing the position.
    def self.call(feen)
      params(*feen.split(' '))
    end

    # Parse the FEEN string's three fields and return the position params.
    #
    # @param board [String] The flatten board.
    # @param active_side [String] The active side number.
    # @param in_hand [String] The captured actors.
    #
    # @return [Hash] The position params representing the position.
    private_class_method def self.params(board, active_side, in_hand)
      {
        active_side: Turn.parse(active_side),
        indexes: Shape.new(board).to_a,
        pieces_in_hand_by_players: PiecesInHand.parse(in_hand),
        squares: Board.new(board).to_a
      }
    end
  end
end
