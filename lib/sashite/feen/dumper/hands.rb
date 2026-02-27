# frozen_string_literal: true

require_relative "../shared/ascii"
require_relative "../shared/separators"

module Sashite
  module Feen
    module Dumper
      # Serializer for the FEEN Hands field (Field 2).
      #
      # Converts Qi::Position's hands (flat arrays of EPIN token strings)
      # into the canonical FEEN Hands string:
      #
      #   <FIRST-HAND>/<SECOND-HAND>
      #
      # Serialization involves:
      # 1. Aggregating identical EPIN tokens with counts
      # 2. Sorting items according to canonical ordering rules
      # 3. Formatting with multiplicity prefixes (count >= 2)
      #
      # @example Empty hands
      #   Hands.dump({ first: [], second: [] })
      #   # => "/"
      #
      # @example Hands with pieces
      #   Hands.dump({ first: ["P", "P", "N"], second: ["p"] })
      #   # => "2PN/p"
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module Hands
        # Serializes hands to a FEEN Hands field string.
        #
        # @param hands [Hash] Hash with :first and :second (arrays of EPIN strings)
        # @return [String] Canonical Hands field string
        def self.dump(hands)
          first_str = dump_hand(hands[:first])
          second_str = dump_hand(hands[:second])

          "#{first_str}#{Separators::SEGMENT}#{second_str}"
        end

        class << self
          private

          # Serializes a single hand to a canonical string.
          #
          # @param pieces [Array<String>] Flat array of EPIN token strings
          # @return [String] Canonical hand string
          def dump_hand(pieces)
            return "" if pieces.empty?

            items = aggregate(pieces)
            items.sort! { |a, b| compare_items(a, b) }

            result = String.new
            items.each do |count, piece|
              result << count.to_s if count >= 2
              result << piece
            end
            result
          end

          # Aggregates identical EPIN tokens into [count, piece] pairs.
          #
          # @param pieces [Array<String>] Flat array of EPIN token strings
          # @return [Array<Array(Integer, String)>] Aggregated [count, piece] pairs
          def aggregate(pieces)
            counts = Hash.new(0)

            pieces.each { |piece| counts[piece] += 1 }

            counts.map { |piece, count| [count, piece] }
          end

          # Compares two hand items according to canonical ordering rules.
          #
          # Returns negative if a < b, zero if a == b, positive if a > b.
          #
          # @param item_a [Array(Integer, String)] First [count, piece] pair
          # @param item_b [Array(Integer, String)] Second [count, piece] pair
          # @return [Integer] Comparison result
          def compare_items(item_a, item_b)
            count_a, piece_a = item_a
            count_b, piece_b = item_b

            # 1. By multiplicity -- descending
            cmp = count_b <=> count_a
            return cmp unless cmp == 0

            compare_pieces(piece_a, piece_b)
          end

          # Compares two EPIN strings according to canonical ordering.
          #
          # Ordering rules (after multiplicity):
          # 2. By base letter -- case-insensitive alphabetical order
          # 3. By letter case -- uppercase before lowercase
          # 4. By state modifier -- `-` before `+` before none
          # 5. By terminal marker -- absent before present
          # 6. By derivation marker -- absent before present
          #
          # @param str_a [String] First EPIN string
          # @param str_b [String] Second EPIN string
          # @return [Integer] Comparison result
          def compare_pieces(str_a, str_b)
            state_a, letter_a, terminal_a, derived_a = decompose(str_a)
            state_b, letter_b, terminal_b, derived_b = decompose(str_b)

            # 2. By base letter -- case-insensitive alphabetical
            cmp = (letter_a | 0x20) <=> (letter_b | 0x20)
            return cmp unless cmp == 0

            # 3. By letter case -- uppercase before lowercase
            cmp = case_rank(letter_a) <=> case_rank(letter_b)
            return cmp unless cmp == 0

            # 4. By state modifier -- `-` before `+` before none
            cmp = state_a <=> state_b
            return cmp unless cmp == 0

            # 5. By terminal marker -- absent before present
            cmp = terminal_a <=> terminal_b
            return cmp unless cmp == 0

            # 6. By derivation marker -- absent before present
            derived_a <=> derived_b
          end

          # Decomposes an EPIN string into sortable numeric components.
          #
          # Returns four integers for direct comparison:
          # - state: 0 = diminished, 1 = enhanced, 2 = normal
          # - letter: raw byte value
          # - terminal: 0 = absent, 1 = present
          # - derived: 0 = absent, 1 = present
          #
          # @param str [String] EPIN string
          # @return [Array(Integer, Integer, Integer, Integer)] Sortable components
          def decompose(str)
            pos = 0
            byte = str.getbyte(pos)

            # State modifier
            if byte == Ascii::MINUS
              state = 0
              pos += 1
              byte = str.getbyte(pos)
            elsif byte == Ascii::PLUS
              state = 1
              pos += 1
              byte = str.getbyte(pos)
            else
              state = 2
            end

            # Letter
            letter = byte
            pos += 1
            byte = str.getbyte(pos)

            # Terminal marker
            if byte == Ascii::CARET
              terminal = 1
              pos += 1
              byte = str.getbyte(pos)
            else
              terminal = 0
            end

            # Derivation marker
            derived = byte == Ascii::APOSTROPHE ? 1 : 0

            [state, letter, terminal, derived]
          end

          # Returns sort rank for letter case.
          # Uppercase = 0 (first), lowercase = 1 (second).
          #
          # @param byte [Integer] Letter byte value
          # @return [Integer] Sort rank
          def case_rank(byte)
            Ascii.uppercase?(byte) ? 0 : 1
          end
        end

        private_class_method :dump_hand,
                             :aggregate,
                             :compare_items,
                             :compare_pieces,
                             :decompose,
                             :case_rank

        freeze
      end
    end
  end
end
