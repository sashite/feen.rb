# frozen_string_literal: true

require_relative "shared/separators"
require_relative "dumper/piece_placement"
require_relative "dumper/hands"
require_relative "dumper/style_turn"

module Sashite
  module Feen
    # Serializer for FEEN (Field Expression Encoding Notation) strings.
    #
    # Converts a Qi::Position into a canonical FEEN string.
    # A FEEN string consists of three fields separated by single ASCII spaces:
    #
    #   <PIECE-PLACEMENT> <HANDS> <STYLE-TURN>
    #
    # This module orchestrates the three sub-dumpers:
    # - {Dumper::PiecePlacement} for Field 1 (board → piece placement)
    # - {Dumper::Hands} for Field 2 (hands → hands field)
    # - {Dumper::StyleTurn} for Field 3 (styles + turn → style-turn field)
    #
    # @example Dumping a Qi::Position
    #   position = Qi.new(
    #     Array.new(8) { Array.new(8) },
    #     { first: [], second: [] },
    #     { first: "C", second: "c" },
    #     :first
    #   )
    #   Dumper.dump(position)
    #   # => "8/8/8/8/8/8/8/8 / C/c"
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    # @api private
    module Dumper
      # Serializes a Qi::Position to a canonical FEEN string.
      #
      # @param position [Qi::Position] The position to serialize
      # @return [String] Canonical FEEN string
      def self.dump(position)
        piece_placement_str = PiecePlacement.dump(position.board)
        hands_str = Hands.dump(position.hands)
        style_turn_str = StyleTurn.dump(position.styles, position.turn)

        "#{piece_placement_str}#{Separators::FIELD}#{hands_str}#{Separators::FIELD}#{style_turn_str}"
      end

      freeze
    end
  end
end
