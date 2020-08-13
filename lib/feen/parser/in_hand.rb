# frozen_string_literal: true

module FEEN
  module Parser
    # The in hand class.
    class InHand
      attr_reader :bottomside_pieces, :topside_pieces

      def initialize(in_hand)
        bottomside_pieces_in_hand, topside_pieces_in_hand = in_hand.split('/')

        @bottomside_pieces = bottomside_pieces_in_hand.to_s.split(',')
        @topside_pieces = topside_pieces_in_hand.to_s.split(',')
      end

      def topside?
        char.eql?('t')
      end
    end
  end
end
