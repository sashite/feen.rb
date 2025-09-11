# frozen_string_literal: true

module Sashite
  module Feen
    module Parser
      module PiecesInHand
        module_function

        # Parse the pieces-in-hand field into a Hands value object.
        #
        # Strictness:
        #   - "-"  => empty hands (valid)
        #   - ""   => invalid (raises Error::Syntax)
        #
        # Grammar (tolerant for counts notation):
        #   hands   := "-" | entry ("," entry)*
        #   entry   := epin | int ("x"|"*") epin | epin ("x"|"*") int
        #   int     := [1-9][0-9]*
        #
        # @param field [String]
        # @return [Sashite::Feen::Hands]
        def parse(field)
          src = String(field).strip
          raise Error::Syntax, "empty hands field" if src.empty?
          return Hands.new({}.freeze) if src == "-"

          entries = src.split(",").map(&:strip).reject(&:empty?)
          raise Error::Syntax, "malformed hands field" if entries.empty?

          counts = Hash.new(0)

          entries.each_with_index do |entry, idx|
            epin_token, qty = _parse_hand_entry(entry, idx)
            epin_id = _parse_epin(epin_token, idx)
            counts[epin_id] += qty
          end

          frozen_counts = {}
          counts.each { |k, v| frozen_counts[k] = Integer(v) }

          Hands.new(frozen_counts.freeze)
        end

        # Accepts forms: "P", "2xP", "P*2", "10*R", "[Shogi:P]*3"
        def _parse_hand_entry(str, _idx)
          s = str.strip

          if (m = /\A(\d+)\s*[x*]\s*(.+)\z/.match(s))
            n = Integer(m[1])
            raise Error::Count, "hand count must be >= 1, got #{n}" if n <= 0

            return [m[2].strip, n]
          end

          if (m = /\A(.+?)\s*[x*]\s*(\d+)\z/.match(s))
            n = Integer(m[2])
            raise Error::Count, "hand count must be >= 1, got #{n}" if n <= 0

            return [m[1].strip, n]
          end

          # Default: single piece
          [s, 1]
        end
        module_function :_parse_hand_entry
        private_class_method :_parse_hand_entry

        def _parse_epin(token, idx)
          ::Sashite::Epin.parse(token)
        rescue StandardError => e
          raise Error::Piece, "invalid EPIN token in hands (entry #{idx + 1}): #{token.inspect} (#{e.message})"
        end
        private_class_method :_parse_epin
      end
    end
  end
end
