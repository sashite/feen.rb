# frozen_string_literal: true

require_relative File.join("feen", "dumper")
require_relative File.join("feen", "parser")

# This module provides a Ruby interface for data serialization and
# deserialization in FEEN format.
#
# @see https://developer.sashite.com/specs/fen-easy-extensible-notation
module Feen
  # Dumps position params into a FEEN string.
  #
  # @param pieces_in_hand [Array, nil] The list of pieces in hand.
  # @param board_shape [Array] The shape of the board.
  # @param side_to_move [String] The identifier of the player who must play.
  # @param piece_placement [Hash] The index of each piece on the board.
  #
  # @example Dump a classic Tsume Shogi problem
  #   dump(
  #     "side_to_move": "s",
  #     "pieces_in_hand": %w[S r r b g g g g s n n n n p p p p p p p p p p p p p p p p p],
  #     "board_shape": [9, 9],
  #     "piece_placement": {
  #        3 => "s",
  #        4 => "k",
  #        5 => "s",
  #       22 => "+P",
  #       43 => "+B"
  #     }
  #   )
  #   # => "3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 s S,b,g*4,n*4,p*17,r*2,s"
  #
  # @return [String] The FEEN string representing the position.
  def self.dump(board_shape:, side_to_move:, piece_placement:, pieces_in_hand: nil)
    Dumper.call(
      pieces_in_hand:,
      board_shape:,
      side_to_move:,
      piece_placement:
    )
  end

  # Parses a FEEN string into position params.
  #
  # @param feen [String] The FEEN string representing a position.
  #
  # @example Parse a classic Tsume Shogi problem
  #   parse("3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 s S,b,g*4,n*4,p*17,r*2,s")
  #   # => {
  #   #      "pieces_in_hand": ["S", "b", "g", "g", "g", "g", "n", "n", "n", "n", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "r", "r", "s"],
  #   #      "board_shape": [9, 9],
  #   #      "side_to_move": "s",
  #   #      "piece_placement": {
  #   #         3 => "s",
  #   #         4 => "k",
  #   #         5 => "s",
  #   #        22 => "+P",
  #   #        43 => "+B"
  #   #      }
  #
  # @return [Hash] The position params representing the position.
  def self.parse(feen)
    Parser.call(feen)
  end
end
