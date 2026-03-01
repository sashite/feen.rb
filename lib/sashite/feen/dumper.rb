# frozen_string_literal: true

require_relative "dumper/piece_placement"
require_relative "dumper/hands"
require_relative "dumper/style_turn"

module Sashite
  module Feen
    # Serializer for FEEN strings. Converts a Qi position into a
    # canonical FEEN string with three space-separated fields.
    #
    # @api private
    module Dumper
      # Serializes a Qi position to a canonical FEEN string.
      #
      # @param position [Qi] The position to serialize
      # @return [String] Canonical FEEN string
      def self.dump(position)
        pp = PiecePlacement.dump(position.board, position.shape)
        hands = Hands.dump(position.first_player_hand, position.second_player_hand)
        st = StyleTurn.dump(position.first_player_style, position.second_player_style, position.turn)

        "#{pp} #{hands} #{st}"
      end

      freeze
    end
  end
end
