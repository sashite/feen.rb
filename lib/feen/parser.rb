# frozen_string_literal: true

require_relative 'parser/board'
require_relative 'parser/in_hand'
require_relative 'parser/shape'
require_relative 'parser/turn'

module FEEN
  # The parser module.
  module Parser
    # Parse a FEEN string into position params.
    #
    # @return [Hash] The position params representing the position.
    def self.call(feen_string)
      params(*feen_string.split(' '))
    end

    # Parse the FEEN string's three fields and return the position params.
    #
    # @param board [String] The flatten board.
    # @param turn [String] The active side.
    # @param in_hand [String] The captured actors.
    #
    # @return [Hash] The position params representing the position.
    private_class_method def self.params(board, turn, in_hand)
      pieces_in_hand = InHand.new(in_hand)

      {
        indexes: Shape.new(board).to_a,
        squares: Board.new(board).to_a,
        is_turn_to_topside: Turn.new(turn).topside?,
        bottomside_in_hand_pieces: pieces_in_hand.bottomside_in_hand_pieces,
        topside_in_hand_pieces: pieces_in_hand.topside_in_hand_pieces
      }
    end
  end
end
