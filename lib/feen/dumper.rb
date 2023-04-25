# frozen_string_literal: true

require_relative File.join("dumper", "piece_placement")
require_relative File.join("dumper", "pieces_in_hand")

module Feen
  # The dumper module.
  module Dumper
    # Dump position params into a FEEN string.
    #
    # @param side_to_move [String] Identify the active side.
    # @param pieces_in_hand [Array, nil] The list of pieces in hand.
    # @param board_shape [Array] The shape of the board.
    # @param piece_placement [Hash] The index of each piece on the board.
    #
    # @example Dump a classic Tsume Shogi problem
    #   call(
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
    def self.call(board_shape:, side_to_move:, piece_placement:, pieces_in_hand: nil)
      array = [
        PiecePlacement.new(board_shape, piece_placement).to_s,
        side_to_move
      ]

      array << PiecesInHand.dump(pieces_in_hand) if Array(pieces_in_hand).any?
      array.join(" ")
    end
  end
end
