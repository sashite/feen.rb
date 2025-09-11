# frozen_string_literal: true

module Sashite
  module Feen
    module Parser
      module StyleTurn
        module_function

        # Strict FEEN + SIN:
        #   style_turn := LETTER "/" LETTER              # no whitespace
        #   semantics :
        #     - Uppercase marks the side to move.
        #     - Exactly one uppercase among the two.
        #     - Each letter is a SIN style code (validated via Sashite::Sin.parse).
        #
        # Examples (valid):
        #   "C/c"  -> first to move,  first_style="C", second_style="C" (Chess vs Chess)
        #   "c/C"  -> second to move
        #   "S/o"  -> first to move,  first_style="S" (Shogi), second_style="O" (Ōgi)
        #
        # Examples (invalid):
        #   "w" , "C / c", "Cc", "c/c", "C/C", "x/y "  (wrong pattern or spaces)
        #
        # @param field [String]
        # @return [Sashite::Feen::Styles] with signature Styles.new(first_style, second_style, turn)
        def parse(field)
          s = String(field)
          raise Error::Syntax, "empty style/turn field" if s.empty?
          raise Error::Syntax, "whitespace not allowed in style/turn" if s.match?(/\s/)

          m = %r{\A([A-Za-z])/([A-Za-z])\z}.match(s)
          raise Error::Syntax, "invalid style/turn format" unless m

          a_raw = m[1]
          b_raw = m[2]
          a_is_up = a_raw.between?("A", "Z")
          b_is_up = b_raw.between?("A", "Z")

          # Exactly one uppercase marks side to move
          raise Error::Style, "ambiguous side-to-move: exactly one letter must be uppercase" unless a_is_up ^ b_is_up

          # Canonical SIN tokens are uppercase (style identity is case-insensitive in FEEN)
          a_tok = a_raw.upcase
          b_tok = b_raw.upcase

          first_style = begin
            ::Sashite::Sin.parse(a_tok)
          rescue StandardError => e
            raise Error::Style, "invalid SIN token for first side #{a_tok.inspect}: #{e.message}"
          end

          second_style = begin
            ::Sashite::Sin.parse(b_tok)
          rescue StandardError => e
            raise Error::Style, "invalid SIN token for second side #{b_tok.inspect}: #{e.message}"
          end

          turn = a_is_up ? :first : :second
          Styles.new(first_style, second_style, turn)
        end
      end
    end
  end
end
