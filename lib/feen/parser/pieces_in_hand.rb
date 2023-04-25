# frozen_string_literal: true

module Feen
  module Parser
    # The pieces in hand module.
    module PiecesInHand
      # The list of pieces in hand grouped by players.
      #
      # @param pieces_in_hand [String, nil] The serialized list of pieces in hand.
      #
      # @example Parse a list of serialized pieces in hand
      #   parse("S,b,g*4,n*4,p*17,r*2,s")
      #   # => ["S", "b", "g", "g", "g", "g", "n", "n", "n", "n", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "r", "r", "s"]
      #
      # @example Parse an empty list of serialized pieces in hand
      #   parse("-")
      #   # => []
      #
      # @return [Array] The list of pieces in hand grouped by players.
      def self.parse(pieces_in_hand)
        return if pieces_in_hand.nil?

        pieces_in_hand.split(",").flat_map do |piece|
          if piece.include?("*")
            letter, count = piece.split("*")
            [letter] * count.to_i
          else
            piece
          end
        end.sort
      end
    end
  end
end
