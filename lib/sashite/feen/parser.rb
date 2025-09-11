# frozen_string_literal: true

require_relative "parser/piece_placement"
require_relative "parser/pieces_in_hand"
require_relative "parser/style_turn"

module Sashite
  module Feen
    module Parser
      module_function

      def parse(feen)
        s = String(feen).strip
        raise Error::Syntax, "empty FEEN input" if s.empty?

        a, b, c = _split_3_fields(s)
        placement = PiecePlacement.parse(a)
        hands     = PiecesInHand.parse(b)
        styles    = StyleTurn.parse(c)

        Position.new(placement, hands, styles)
      end

      def _split_3_fields(s)
        parts = s.split(/\s+/, 3)
        unless parts.length == 3
          raise Error::Syntax,
                "FEEN must have 3 whitespace-separated fields (got #{parts.length})"
        end
        parts
      end
      private_class_method :_split_3_fields
    end
  end
end
