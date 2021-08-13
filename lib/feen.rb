# frozen_string_literal: true

require_relative File.join("feen", "dumper")
require_relative File.join("feen", "parser")

# This module provides a Ruby interface for data serialization and
# deserialization in FEEN format.
#
# @see https://developer.sashite.com/specs/forsyth-edwards-expanded-notation
module FEEN
  # Dumps position params into a FEEN string.
  #
  # @param in_hand [Array] The list of pieces in hand.
  # @param shape [Array] The shape of the board.
  # @param side_id [Integer] The identifier of the player who must play.
  # @param square [Hash] The index of each piece on the board.
  #
  # @example Dump a classic Tsume Shogi problem
  #   dump(
  #     "in_hand": %w[S r r b g g g g s n n n n p p p p p p p p p p p p p p p p p],
  #     "shape": [9, 9],
  #     "side_id": 0,
  #     "square": {
  #        3 => "s",
  #        4 => "k",
  #        5 => "s",
  #       22 => "+P",
  #       43 => "+B"
  #     }
  #   )
  #   # => "3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 0 S,b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s"
  #
  # @return [String] The FEEN string representing the position.
  def self.dump(in_hand:, shape:, side_id:, square:)
    Dumper.call(
      in_hand: in_hand,
      shape: shape,
      side_id: side_id,
      square: square
    )
  end

  # Parses a FEEN string into position params.
  #
  # @param feen [String] The FEEN string representing a position.
  #
  # @example Parse a classic Tsume Shogi problem
  #   parse("3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 0 S,b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s")
  #   # => {
  #   #      "in_hand": ["S", "b", "g", "g", "g", "g", "n", "n", "n", "n", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "r", "r", "s"],
  #   #      "shape": [9, 9],
  #   #      "side_id": 0,
  #   #      "square": {
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
