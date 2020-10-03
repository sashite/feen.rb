# frozen_string_literal: true

module FEEN
  module Parser
    # The pieces in hand module.
    module InHand
      # The list of pieces in hand grouped by players.
      #
      # @param piece_names_str [String] The serialized list of pieces in hand.
      #
      # @example Parse a list of serialized pieces in hand
      #   parse("S,b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s")
      #   # => ["S", "b", "g", "g", "g", "g", "n", "n", "n", "n", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "r", "r", "s"]
      #
      # @example Parse an empty list of serialized pieces in hand
      #   parse("-")
      #   # => []
      #
      # @return [Array] The list of pieces in hand grouped by players.
      def self.parse(piece_names_str)
        return [] if piece_names_str == "-"

        piece_names_str.split(",")
      end
    end
  end
end
