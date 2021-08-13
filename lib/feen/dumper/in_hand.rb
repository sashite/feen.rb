# frozen_string_literal: true

module FEEN
  module Dumper
    # The pieces in hand module.
    module InHand
      # Serialize pieces in hand lists into a string.
      #
      # @param piece_names [Array] A list of pieces in hand.
      #
      # @example Dump a list of pieces in hand
      #   dump(["S", "b", "g", "g", "g", "g", "n", "n", "n", "n", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "r", "r", "s"])
      #   # => "S,b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s"
      #
      # @example Dump an empty list of pieces in hand
      #   dump([])
      #   # => "-"
      #
      # @return [String] A string representing the pieces in hand.
      def self.dump(piece_names)
        return "-" if piece_names.empty?

        piece_names.sort.join(",")
      end
    end
  end
end
