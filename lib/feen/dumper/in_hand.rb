# frozen_string_literal: true

module FEEN
  module Dumper
    # The in hand class.
    class InHand
      def self.dump(bottomside_in_hand_pieces, topside_in_hand_pieces)
        [
          bottomside_in_hand_pieces,
          topside_in_hand_pieces
        ].map { |pieces| new(*pieces).call }.join('/')
      end

      attr_reader :pieces

      def initialize(*pieces)
        @pieces = pieces
      end

      def call
        pieces.sort.join(',')
      end
    end
  end
end