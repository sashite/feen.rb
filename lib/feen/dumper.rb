# frozen_string_literal: true

require_relative 'dumper/board'
require_relative 'dumper/pieces_in_hand'
require_relative 'dumper/turn'

module FEEN
  # The dumper module.
  module Dumper
    # Dump position params into a FEEN string.
    #
    # @param indexes [Array] The shape of the board.
    # @param squares [Array] The list of squares of on the board.
    # @param is_turn_to_topside [Boolean] The player who must play.
    # @param bottomside_in_hand_pieces [Array] The list of bottom-side's pieces in hand.
    # @param topside_in_hand_pieces [Array] The list of top-side's pieces in hand.
    #
    # @return [String] The FEEN string representing the position.
    def self.call(active_side:, indexes:, pieces_in_hand_by_players:, squares:)
      [
        Board.new(*indexes).to_s(*squares),
        Turn.new(active_side, pieces_in_hand_by_players.length).to_i,
        PiecesInHand.dump(*pieces_in_hand_by_players)
      ].join(' ')
    end
  end
end
