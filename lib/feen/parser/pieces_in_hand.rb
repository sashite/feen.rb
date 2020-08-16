# frozen_string_literal: true

module FEEN
  module Parser
    # The pieces in hand module.
    module PiecesInHand
      # The list of pieces in hand grouped by players.
      #
      # @param pieces_in_hand_by_players_str [String] The serialized list of
      #   pieces in hand grouped by players.
      #
      # @example Parse a list of serialized pieces in hand
      #   parse("S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s")
      #   # => [
      #   #      %w[S],
      #   #      %w[b g g g g n n n n p p p p p p p p p p p p p p p p p r r s]
      #   #    ]
      #
      # @return [Array] The list of pieces in hand grouped by players.
      def self.parse(pieces_in_hand_by_players_str)
        pieces_in_hand_by_players_str
          .split('/', -1)
          .map { |pieces_in_hand_str| pieces_in_hand_str.split(',') }
      end
    end
  end
end
