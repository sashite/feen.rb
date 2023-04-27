# frozen_string_literal: true

require_relative File.join("feen", "dumper")
require_relative File.join("feen", "parser")

# This module provides a Ruby interface for data serialization and
# deserialization in FEEN format.
#
# @see https://github.com/sashite/specs/blob/main/forsyth-edwards-expanded-notation.md
module Feen
  # Dumps position params into a FEEN string.
  #
  # @param board_shape [Array] The shape of the board.
  # @param side_to_move [String] The identifier of the player who must play.
  # @param piece_placement [Hash] The index of each piece on the board.
  #
  # @example Dump a classic Tsume Shogi problem
  #   dump(
  #     "board_shape": [9, 9],
  #     "side_to_move": "s",
  #     "piece_placement": {
  #        3 => "s",
  #        4 => "k",
  #        5 => "s",
  #       22 => "+P",
  #       43 => "+B"
  #     }
  #   )
  #   # => "3sks3/9/4+P4/9/7+B1/9/9/9/9 s"
  #
  # @return [String] The FEEN string representing the position.
  def self.dump(board_shape:, side_to_move:, piece_placement:)
    Dumper.call(
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
  #   parse("3sks3/9/4+P4/9/7+B1/9/9/9/9 s")
  #   # => {
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
  def self.parse(feen, regex: /\+?[a-z]/i)
    Parser.call(feen, regex:)
  end
end
