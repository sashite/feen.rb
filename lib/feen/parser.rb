# frozen_string_literal: true

require_relative 'parser/indexes'
# require_relative 'parser/in_hand'
# require_relative 'parser/turn'

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
      squares = board.split(/[\/,]+/).flat_map { |sub_string| sub_string.match?(/[0-9]+/) ? Array.new(Integer(sub_string)) : sub_string }

      in_hand_pieces = in_hand.split('/')

      {
        indexes: Indexes.new(board).call,
        squares: squares,
        is_turn_to_topside: turn.eql?('t'),
        bottomside_in_hand_pieces: in_hand_pieces.fetch(0, '').split(','),
        topside_in_hand_pieces: in_hand_pieces.fetch(1, '').split(',')
      }
    end
  end
end
