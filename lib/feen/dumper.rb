# frozen_string_literal: true

require_relative File.join("dumper", "piece_placement")

module Feen
  # The dumper module.
  module Dumper
    # Dump position params into a FEEN string.
    #
    # @param board_shape [Array] The shape of the board.
    # @param side_to_move [String] Identify the active side.
    # @param piece_placement [Hash] The index of each piece on the board.
    #
    # @example Dump a classic Tsume Shogi problem
    #   call(
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
    def self.call(board_shape:, side_to_move:, piece_placement:)
      [
        PiecePlacement.new(board_shape, piece_placement).to_s,
        side_to_move
      ].join(" ")
    end
  end
end
