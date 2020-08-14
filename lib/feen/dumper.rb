# frozen_string_literal: true

require_relative 'dumper/board'
require_relative 'dumper/in_hand'
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
    def self.call(indexes, *squares, is_turn_to_topside:, bottomside_in_hand_pieces:, topside_in_hand_pieces:)
      [
        Board.new(*indexes).to_s(*squares),
        Turn.new(is_turn_to_topside).to_s,
        InHand.dump(bottomside_in_hand_pieces, topside_in_hand_pieces)
      ].join(' ')
    end
  end
end
