# frozen_string_literal: true

require_relative "shared/separators"
require_relative "dumper/piece_placement"
require_relative "dumper/hands"
require_relative "dumper/style_turn"

module Sashite
  module Feen
    # Serializer for FEEN (Field Expression Encoding Notation) strings.
    #
    # Converts structured position data into a canonical FEEN string.
    # A FEEN string consists of three fields separated by single ASCII spaces:
    #
    #   <PIECE-PLACEMENT> <HANDS> <STYLE-TURN>
    #
    # This module orchestrates the three sub-dumpers:
    # - {Dumper::PiecePlacement} for Field 1
    # - {Dumper::Hands} for Field 2
    # - {Dumper::StyleTurn} for Field 3
    #
    # @example Dumping a complete position
    #   Dumper.dump(
    #     piece_placement: { segments: [[8], [8], ...], separators: ["/", "/", ...] },
    #     hands: { first: [], second: [] },
    #     style_turn: { active: "C", inactive: "c" }
    #   )
    #   # => "8/8/8/8/8/8/8/8 / C/c"
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    # @api private
    module Dumper
      # Serializes position data to a FEEN string.
      #
      # @param piece_placement [Hash] Piece placement with :segments and :separators
      # @param hands [Hash] Hands with :first and :second
      # @param style_turn [Hash] Style-turn with :active and :inactive
      # @return [String] Canonical FEEN string
      def self.dump(piece_placement:, hands:, style_turn:)
        piece_placement_str = PiecePlacement.dump(**piece_placement)
        hands_str = Hands.dump(**hands)
        style_turn_str = StyleTurn.dump(**style_turn)

        [piece_placement_str, hands_str, style_turn_str].join(Separators::FIELD)
      end

      freeze
    end
  end
end
