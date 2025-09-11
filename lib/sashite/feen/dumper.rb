# frozen_string_literal: true

# FEEN Dumper (entry point)
# -------------------------
# Serializes a Position object into its canonical FEEN string by delegating
# each field to its dedicated sub-dumper.
#
# Sub-dumpers:
#   dumper/piece_placement.rb
#   dumper/pieces_in_hand.rb
#   dumper/style_turn.rb

require_relative "dumper/piece_placement"
require_relative "dumper/pieces_in_hand"
require_relative "dumper/style_turn"

module Sashite
  module Feen
    module Dumper
      # Separator used between the three FEEN fields
      FIELD_SEPARATOR = " "

      module_function

      # Dump a Position into a FEEN string
      #
      # @param position [Sashite::Feen::Position]
      # @return [String]
      def dump(position)
        pos = _coerce_position(position)

        [
          PiecePlacement.dump(pos.placement),
          PiecesInHand.dump(pos.hands),
          StyleTurn.dump(pos.styles)
        ].join(FIELD_SEPARATOR)
      end

      # -- helpers -------------------------------------------------------------

      def _coerce_position(obj)
        return obj if obj.is_a?(Position)

        raise TypeError, "expected Sashite::Feen::Position, got #{obj.class}"
      end
      private_class_method :_coerce_position
    end
  end
end
