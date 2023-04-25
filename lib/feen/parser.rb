# frozen_string_literal: true

require_relative File.join("parser", "board_shape")
require_relative File.join("parser", "pieces_in_hand")
require_relative File.join("parser", "piece_placement")

module Feen
  # The parser module.
  module Parser
    # Parse a FEEN string into position params.
    #
    # @param feen [String] The FEEN string representing a position.
    #
    # @example Parse a classic Tsume Shogi problem
    #   call("3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 s S,b,g*4,n*4,p*17,r*2,s")
    #   # => {
    #   #      "side_to_move": "s",
    #   #      "pieces_in_hand": ["S", "b", "g", "g", "g", "g", "n", "n", "n", "n", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "r", "r", "s"],
    #   #      "board_shape": [9, 9],
    #   #      "piece_placement": {
    #   #         3 => "s",
    #   #         4 => "k",
    #   #         5 => "s",
    #   #        22 => "+P",
    #   #        43 => "+B"
    #   #      }
    #
    # @return [Hash] The position params representing the position.
    def self.call(feen)
      piece_placement, side_to_move, pieces_in_hand = feen.split

      {
        board_shape:     BoardShape.new(piece_placement).to_a,
        pieces_in_hand:  PiecesInHand.parse(pieces_in_hand),
        piece_placement: PiecePlacement.new(piece_placement).to_h,
        side_to_move:
      }
    end
  end
end
