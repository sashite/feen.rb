# frozen_string_literal: true

require_relative File.join("dumper", "in_hand")
require_relative File.join("dumper", "square")
require_relative File.join("dumper", "turn")

module FEEN
  # The dumper module.
  module Dumper
    # Dump position params into a FEEN string.
    #
    # @param in_hand [Array] The list of pieces in hand.
    # @param shape [Array] The shape of the board.
    # @param side_id [Integer] The identifier of the player who must play.
    # @param square [Hash] The index of each piece on the board.
    #
    # @example Dump a classic Tsume Shogi problem
    #   call(
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
    def self.call(in_hand:, shape:, side_id:, square:)
      [
        Square.new(shape, square).to_s,
        Turn.dump(side_id),
        InHand.dump(in_hand)
      ].join(" ")
    end
  end
end
