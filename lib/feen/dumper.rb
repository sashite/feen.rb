# frozen_string_literal: true

require_relative 'dumper/board'
require_relative 'dumper/in_hand'
require_relative 'dumper/turn'

module FEEN
  # The dumper module.
  module Dumper
    # Dump position params into a FEEN string.
    #
    # @return [String] The FEEN string representing the position.
    def self.call(indexes, *squares, is_turn_to_topside:, bottomside_in_hand_pieces:, topside_in_hand_pieces:)
      [
        Board.new(*indexes).call(*squares),
        Turn.new(is_turn_to_topside).call,
        InHand.dump(bottomside_in_hand_pieces, topside_in_hand_pieces)
      ].join(' ')
    end
  end
end
