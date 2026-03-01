# frozen_string_literal: true

require_relative "../shared/ascii"

module Sashite
  module Feen
    module Dumper
      # Serializer for the FEEN Hands field (Field 2).
      #
      # Converts hand maps (piece → count) into the canonical FEEN string.
      #
      # @api private
      module Hands
        # Serializes hands to a FEEN Hands field string.
        #
        # @param first_player_hand [Hash{String => Integer}] First player's pieces
        # @param second_player_hand [Hash{String => Integer}] Second player's pieces
        # @return [String] Canonical Hands field string
        def self.dump(first_player_hand, second_player_hand)
          "#{dump_hand(first_player_hand)}/#{dump_hand(second_player_hand)}"
        end

        class << self
          private

          def dump_hand(hand)
            return "" if hand.empty?

            items = hand.to_a

            items.sort! do |a, b|
              # a = [piece, count], b = [piece, count]
              cmp = b[1] <=> a[1]
              cmp == 0 ? compare_pieces(a[0], b[0]) : cmp
            end

            result = String.new
            items.each do |piece, count|
              result << count.to_s if count >= 2
              result << piece
            end
            result
          end

          # Compares two EPIN strings according to canonical ordering.
          def compare_pieces(str_a, str_b)
            pos_a = 0
            byte_a = str_a.getbyte(pos_a)

            if byte_a == Ascii::MINUS
              state_a = 0; pos_a += 1; byte_a = str_a.getbyte(pos_a)
            elsif byte_a == Ascii::PLUS
              state_a = 1; pos_a += 1; byte_a = str_a.getbyte(pos_a)
            else
              state_a = 2
            end

            pos_b = 0
            byte_b = str_b.getbyte(pos_b)

            if byte_b == Ascii::MINUS
              state_b = 0; pos_b += 1; byte_b = str_b.getbyte(pos_b)
            elsif byte_b == Ascii::PLUS
              state_b = 1; pos_b += 1; byte_b = str_b.getbyte(pos_b)
            else
              state_b = 2
            end

            # 2. By base letter -- case-insensitive
            cmp = (byte_a | 0x20) <=> (byte_b | 0x20)
            return cmp unless cmp == 0

            # 3. By letter case -- uppercase before lowercase
            cmp = (byte_a < Ascii::LOWER_A ? 0 : 1) <=> (byte_b < Ascii::LOWER_A ? 0 : 1)
            return cmp unless cmp == 0

            # 4. By state modifier
            cmp = state_a <=> state_b
            return cmp unless cmp == 0

            pos_a += 1; byte_a = str_a.getbyte(pos_a)
            pos_b += 1; byte_b = str_b.getbyte(pos_b)

            # 5. By terminal marker
            ta = byte_a == Ascii::CARET ? 1 : 0
            tb = byte_b == Ascii::CARET ? 1 : 0
            cmp = ta <=> tb
            return cmp unless cmp == 0

            if ta == 1; byte_a = str_a.getbyte(pos_a + 1); end
            if tb == 1; byte_b = str_b.getbyte(pos_b + 1); end

            # 6. By derivation marker
            (byte_a == Ascii::APOSTROPHE ? 1 : 0) <=> (byte_b == Ascii::APOSTROPHE ? 1 : 0)
          end
        end

        private_class_method :dump_hand,
                             :compare_pieces

        freeze
      end
    end
  end
end
