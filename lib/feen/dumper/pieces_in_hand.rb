# frozen_string_literal: true

module FEEN
  module Dumper
    # The pieces in hand class.
    #
    # @example Serialize a list of pieces in hand grouped by sides
    #   PiecesInHand.dump(
    #     %w[S],
    #     %w[r r b g g g g s n n n n p p p p p p p p p p p p p p p p p]
    #   )
    #   # => "S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s"
    class PiecesInHand
      # Serialize pieces in hand lists into a string.
      #
      # @param pieces_in_hand_by_players [Array] The list of pieces in hand
      #   grouped by players.
      #
      # @return [String] A string representing the pieces in hand of both
      #   players.
      def self.dump(*pieces_in_hand_by_players)
        pieces_in_hand_by_players.map { |pieces| new(*pieces).to_s }.join('/')
      end

      # @param pieces [Array] A list of pieces in hand.
      def initialize(*pieces)
        @pieces = pieces.sort
      end

      # @return [String] A string representing the pieces in hand.
      def to_s
        @pieces.join(',')
      end
    end
  end
end
