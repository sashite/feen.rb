# frozen_string_literal: true

module FEEN
  module Dumper
    # The pieces in hand class.
    #
    # @example Serialize a list of pieces in hand grouped by sides
    #   PiecesInHand.dump(%w[S r r b g g g g s n n n n p p p p p p p p p p p p p p p p p])
    #   # => "S,b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s"
    module InHand
      # Serialize pieces in hand lists into a string.
      #
      # @param piece_names [Array] A list of pieces in hand.
      #
      # @return [String] A string representing the pieces in hand.
      def self.dump(piece_names)
        return "-" if piece_names.empty?

        piece_names.sort.join("/")
      end
    end
  end
end
