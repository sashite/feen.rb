# frozen_string_literal: true

module FEEN
  module Dumper
    # The in hand class.
    class InHand
      # Serialize pieces in hand lists into a string.
      #
      # @param bottomside_in_hand_pieces [Array] The list of bottom-side's pieces in hand.
      # @param topside_in_hand_pieces [Array] The list of top-side's pieces in hand.
      #
      # @return [String] A string representing the pieces in hand of both
      #   players.
      def self.dump(bottomside_in_hand_pieces, topside_in_hand_pieces)
        [
          bottomside_in_hand_pieces,
          topside_in_hand_pieces
        ].map { |pieces| new(*pieces).to_s }.join('/')
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
