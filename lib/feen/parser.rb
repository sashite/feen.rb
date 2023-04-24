# frozen_string_literal: true

require_relative File.join("parser", "in_hand")
require_relative File.join("parser", "shape")
require_relative File.join("parser", "square")
require_relative File.join("parser", "turn")

module FEEN
  # The parser module.
  module Parser
    # Parse a FEEN string into position params.
    #
    # @param feen [String] The FEEN string representing a position.
    #
    # @example Parse a classic Tsume Shogi problem
    #   call("3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 0 S,b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s")
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
    def self.call(feen)
      square_str, side_id_str, in_hand_str = feen.split

      {
        in_hand: InHand.parse(in_hand_str),
        shape:   Shape.new(square_str).to_a,
        side_id: Turn.parse(side_id_str),
        square:  Square.new(square_str).to_h
      }
    end
  end
end
