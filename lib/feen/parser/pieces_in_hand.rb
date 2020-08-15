# frozen_string_literal: true

module FEEN
  module Parser
    # The pieces in hand class.
    module PiecesInHand
      # The list of pieces in hand grouped by players.
      #
      # @param pieces_in_hand_by_players_str [String] The serialized list of
      #   pieces in hand grouped by players.
      #
      # @return [Array] The list of bottomside's pieces in hand.
      def self.parse(pieces_in_hand_by_players_str)
        pieces_in_hand_by_players_str
          .split('/', -1)
          .map { |pieces_in_hand_str| pieces_in_hand_str.split(',') }
      end
    end
  end
end