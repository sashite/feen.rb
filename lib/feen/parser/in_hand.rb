# frozen_string_literal: true

module FEEN
  module Parser
    # The in hand class.
    class InHand
      # @param in_hand [String] The captured actors.
      def initialize(in_hand)
        bottomside_pieces_in_hand, topside_pieces_in_hand = in_hand.split('/')

        @bottomside_pieces_in_hand = bottomside_pieces_in_hand.to_s
        @topside_pieces_in_hand = topside_pieces_in_hand.to_s
      end

      # The list of pieces in hand owned by the bottomside player.
      #
      # @return [Array] The list of bottomside's pieces in hand.
      def bottomside_in_hand_pieces
        @bottomside_pieces_in_hand.split(',').sort
      end

      # The list of pieces in hand owned by the topside player.
      #
      # @return [Array] The list of topside's pieces in hand.
      def topside_in_hand_pieces
        @topside_pieces_in_hand.split(',').sort
      end
    end
  end
end
