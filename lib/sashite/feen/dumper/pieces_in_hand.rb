# frozen_string_literal: true

module Sashite
  module Feen
    module Dumper
      module PiecesInHand
        # Separator between hand entries
        ENTRY_SEPARATOR = ","

        module_function

        # Dump a Hands multiset to FEEN (e.g., "-", "P,2xN,R")
        #
        # Canonicalization:
        #   - entries sorted lexicographically by EPIN token
        #   - counts rendered as "NxTOKEN" when N > 1
        #
        # @param hands [Sashite::Feen::Hands]
        # @return [String]
        def dump(hands)
          h = _coerce_hands(hands)

          map = h.map
          raise Error::Count, "negative counts are not allowed" if map.values.any? { |v| Integer(v).negative? }

          return "-" if map.empty?

          entries = map.map do |epin_value, count|
            c = Integer(count)
            raise Error::Count, "hand count must be >= 1, got #{c}" if c <= 0

            token = begin
              ::Sashite::Epin.dump(epin_value)
            rescue StandardError => e
              raise Error::Piece, "invalid EPIN value in hands: #{e.message}"
            end

            [token, c]
          end

          # Sort by EPIN token for deterministic output
          entries.sort_by! { |(token, _)| token }

          entries.map { |token, c| c == 1 ? token : "#{c}x#{token}" }
                 .join(ENTRY_SEPARATOR)
        end

        # -- helpers -----------------------------------------------------------

        def _coerce_hands(obj)
          return obj if obj.is_a?(Hands)

          raise TypeError, "expected Sashite::Feen::Hands, got #{obj.class}"
        end
        private_class_method :_coerce_hands
      end
    end
  end
end
