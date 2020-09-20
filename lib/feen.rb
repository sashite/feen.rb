# frozen_string_literal: true

require_relative "feen/dumper"
require_relative "feen/parser"

# This module provides a Ruby interface for data serialization and
# deserialization in FEEN format.
#
# @see https://developer.sashite.com/specs/forsyth-edwards-expanded-notation
module FEEN
  # @example Dumps position params into a FEEN string.
  #
  # @param side_id [Integer] The identifier of the player who must play.
  # @param board [Hash] The indexes of each piece on the board.
  # @param indexes [Array] The shape of the board.
  # @param hands [Array] The list of pieces in hand
  #   grouped by players.
  #
  # @example Dump a classic Tsume Shogi problem
  #   dump(
  #     "side_id": 0,
  #     "board": {
  #        3 => "s",
  #        4 => "k",
  #        5 => "s",
  #       22 => "+P",
  #       43 => "+B"
  #     },
  #     "hands": [
  #       %w[S],
  #       %w[r r b g g g g s n n n n p p p p p p p p p p p p p p p p p]
  #     ],
  #     "indexes": [9, 9]
  #   )
  #   # => "3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 0 S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s"
  #
  # @return [String] The FEEN string representing the position.
  def self.dump(board:, hands:, indexes:, side_id:)
    Dumper.call(
      board: board,
      hands: hands,
      indexes: indexes,
      side_id: side_id
    )
  end

  # Parses a FEEN string into position params.
  #
  # @param feen [String] The FEEN string representing a position.
  #
  # @example Parse a classic Tsume Shogi problem
  #   parse("3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 0 S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s")
  #   # => {
  #   #      "side_id": 0,
  #   #      "board": {
  #   #         3 => "s",
  #   #         4 => "k",
  #   #         5 => "s",
  #   #        22 => "+P",
  #   #        43 => "+B"
  #   #      },
  #   #      "hands": [
  #   #        %w[S],
  #   #        %w[b g g g g n n n n p p p p p p p p p p p p p p p p p r r s]
  #   #      ],
  #   #      "indexes": [9, 9]
  #   #    }
  #
  # @return [Hash] The position params representing the position.
  def self.parse(feen)
    Parser.call(feen)
  end
end
