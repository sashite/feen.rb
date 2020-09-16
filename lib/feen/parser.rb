# frozen_string_literal: true

require_relative "parser/board"
require_relative "parser/pieces_in_hand"
require_relative "parser/shape"
require_relative "parser/turn"

module FEEN
  # The parser module.
  module Parser
    # Parse a FEEN string into position params.
    #
    # @param feen [String] The FEEN string representing a position.
    #
    # @example Parse a classic Tsume Shogi problem
    #   call("3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 0 S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s")
    #   # => {
    #   #      "active_side_id": 0,
    #   #      "board": {
    #   #         3 => "s",
    #   #         4 => "k",
    #   #         5 => "s",
    #   #        22 => "+P",
    #   #        43 => "+B"
    #   #      },
    #   #      "indexes": [9, 9],
    #   #      "pieces_in_hand_grouped_by_sides": [
    #   #        %w[S],
    #   #        %w[b g g g g n n n n p p p p p p p p p p p p p p p p p r r s]
    #   #      ]
    #   #    }
    #
    # @return [Hash] The position params representing the position.
    def self.call(feen)
      board, active_side_id, in_hand = feen.split(" ")

      {
        active_side_id: Turn.parse(active_side_id),
        board: Board.new(board).to_h,
        indexes: Shape.new(board).to_a,
        pieces_in_hand_grouped_by_sides: PiecesInHand.parse(in_hand)
      }
    end
  end
end
