# frozen_string_literal: true

require_relative "../shared/ascii"
require_relative "../shared/separators"

module Sashite
  module Feen
    module Dumper
      # Serializer for the FEEN Hands field (Field 2).
      #
      # Converts a Qi position's hands (piece → count maps) into the
      # canonical FEEN Hands string:
      #
      #   <FIRST-HAND>/<SECOND-HAND>
      #
      # Since Qi v13 stores hands as +{String => Integer}+ maps, pieces are
      # already aggregated. Serialization involves:
      # 1. Sorting items according to canonical ordering rules
      # 2. Formatting with multiplicity prefixes (count >= 2)
      #
      # @example Empty hands
      #   Hands.dump({}, {})
      #   # => "/"
      #
      # @example Hands with pieces
      #   Hands.dump({ "P" => 2, "N" => 1 }, { "p" => 1 })
      #   # => "2PN/p"
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module Hands
        # Serializes hands to a FEEN Hands field string.
        #
        # @param first_player_hand [Hash{String => Integer}] First player's pieces
        # @param second_player_hand [Hash{String => Integer}] Second player's pieces
        # @return [String] Canonical Hands field string
        def self.dump(first_player_hand, second_player_hand)
          first_str = dump_hand(first_player_hand)
          second_str = dump_hand(second_player_hand)

          "#{first_str}#{Separators::SEGMENT}#{second_str}"
        end

        class << self
          private

          # Serializes a single hand to a canonical string.
          #
          # @param hand [Hash{String => Integer}] Piece → count map
          # @return [String] Canonical hand string
          def dump_hand(hand)
            return "" if hand.empty?

            items = hand.map { |piece, count| [count, piece] }
            items.sort! { |a, b| compare_items(a, b) }

            result = String.new
            items.each do |count, piece|
              result << count.to_s if count >= 2
              result << piece
            end
            result
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
                             :compare_items,
                             :compare_pieces,
                             :decompose,
                             :case_rank

        freeze
      end
    end
  end
end
