# frozen_string_literal: true

# require_relative 'parser/board'
# require_relative 'parser/in_hand'
# require_relative 'parser/turn'

module FEEN
  # The parser module.
  module Parser
    # Parse a FEEN string into position params.
    #
    # @return [Hash] The position params representing the position.
    def self.call(feen_string)
      board, turn, in_hand = feen_string.split(' ')

      in_hand_pieces = in_hand.split('/')

      {
        indexes: indexes,
        squares: squares,
        is_turn_to_topside: turn.eql?('t'),
        bottomside_in_hand_pieces: in_hand_pieces.fetch(0),
        topside_in_hand_pieces: in_hand_pieces.fetch(1)
      }
    end
  end
end
