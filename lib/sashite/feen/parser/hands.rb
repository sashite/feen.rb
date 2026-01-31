# frozen_string_literal: true

require "sashite/epin"

require_relative "../constants"
require_relative "../errors"

module Sashite
  module Feen
    module Parser
      # Parser for FEEN Hands field (Field 2).
      #
      # The Hands field encodes off-board pieces held by each player:
      #
      #   <FIRST-HAND>/<SECOND-HAND>
      #
      # Each hand is a concatenation of hand items with no separators:
      #
      #   [<count>]<piece>
      #
      # Where:
      # - <piece> is a valid EPIN token
      # - <count> is an optional multiplicity (≥ 2 if present, absent = 1)
      #
      # Hand items MUST be in canonical order:
      # 1. By multiplicity — descending (larger counts first)
      # 2. By base letter — case-insensitive alphabetical order
      # 3. By letter case — uppercase before lowercase
      # 4. By state modifier — `-` before `+` before none
      # 5. By terminal marker — absent before present
      # 6. By derivation marker — absent before present
      #
      # Additionally, identical EPIN tokens MUST be aggregated (not repeated).
      #
      # @api private
      #
      # @example Empty hands
      #   Hands.parse("/")
      #   # => { first: [], second: [] }
      #
      # @example Hands with pieces
      #   Hands.parse("2P/p")
      #   # => { first: [{ piece: <P>, count: 2 }], second: [{ piece: <p>, count: 1 }] }
      #
      # @example Complex canonical order
      #   Hands.parse("3B2PNR/2qp")
      #   # => { first: [{ piece: <B>, count: 3 }, { piece: <P>, count: 2 },
      #   #              { piece: <N>, count: 1 }, { piece: <R>, count: 1 }],
      #   #      second: [{ piece: <q>, count: 2 }, { piece: <p>, count: 1 }] }
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      module Hands
        # Parses a FEEN Hands field string.
        #
        # @param input [String] The Hands field string
        # @return [Hash] A hash with :first and :second keys
        # @raise [Errors::Argument] If the input is not valid
        def self.parse(input)
          validate_delimiter!(input)

          first_str, second_str = input.split(Constants::SEGMENT_SEPARATOR, -1)

          first_items = parse_hand(first_str)
          second_items = parse_hand(second_str)

          validate_aggregation!(first_items)
          validate_aggregation!(second_items)
          validate_canonical_order!(first_items)
          validate_canonical_order!(second_items)

          { first: first_items, second: second_items }
        end

        class << self
          private

          # ASCII byte constants for efficient parsing.
          ZERO = 0x30        # '0'
          NINE = 0x39        # '9'
          UPPER_A = 0x41     # 'A'
          UPPER_Z = 0x5A     # 'Z'
          LOWER_A = 0x61     # 'a'
          LOWER_Z = 0x7A     # 'z'
          PLUS = 0x2B        # '+'
          MINUS = 0x2D       # '-'
          CARET = 0x5E       # '^'
          APOSTROPHE = 0x27  # "'"

          # Validates that the input contains exactly one delimiter.
          #
          # @param input [String] The input to validate
          # @raise [Errors::Argument] If delimiter is missing or duplicated
          def validate_delimiter!(input)
            return if input.count(Constants::SEGMENT_SEPARATOR) == 1

            raise Errors::Argument, Errors::Argument::Messages::INVALID_HANDS_DELIMITER
          end

          # Parses a single hand string into an array of hand items.
          #
          # @param hand_str [String] The hand string to parse
          # @return [Array<Hash>] Array of hand items with :piece and :count keys
          def parse_hand(hand_str)
            return [] if hand_str.empty?

            items = []
            pos = 0

            while pos < hand_str.bytesize
              count, pos = extract_count(hand_str, pos)
              piece, pos = extract_piece(hand_str, pos)
              items << { piece:, count: }
            end

            items
          end

          # Extracts an optional count prefix starting at pos.
          #
          # @param str [String] The string to extract from
          # @param pos [Integer] Starting position
          # @return [Array(Integer, Integer)] The count (1 if absent) and new position
          # @raise [Errors::Argument] If count is invalid
          def extract_count(str, pos)
            byte = str.getbyte(pos)
            return [1, pos] unless digit?(byte)

            start_pos = pos
            pos += 1 while pos < str.bytesize && digit?(str.getbyte(pos))

            count_str = str.byteslice(start_pos, pos - start_pos)
            validate_count!(count_str)

            [count_str.to_i, pos]
          end

          # Validates a count string.
          #
          # @param count_str [String] The count string to validate
          # @raise [Errors::Argument] If count is 0, 1, or has leading zeros
          def validate_count!(count_str)
            # Leading zeros are forbidden
            if count_str.bytesize > 1 && count_str.getbyte(0) == ZERO
              raise Errors::Argument, Errors::Argument::Messages::INVALID_HAND_COUNT
            end

            count = count_str.to_i

            # Count must be >= 2 when explicit (1 is implicit)
            return if count >= 2

            raise Errors::Argument, Errors::Argument::Messages::INVALID_HAND_COUNT
          end

          # Extracts and parses an EPIN token starting at pos.
          #
          # EPIN structure: [+-]?[A-Za-z]\^?'?
          #
          # @param str [String] The string to extract from
          # @param pos [Integer] Starting position
          # @return [Array(Sashite::Epin::Identifier, Integer)] The parsed EPIN and new position
          # @raise [Errors::Argument] If EPIN parsing fails
          def extract_piece(str, pos)
            start_pos = pos
            byte = str.getbyte(pos)

            # Optional state modifier: + or -
            if byte == PLUS || byte == MINUS
              pos += 1
              byte = str.getbyte(pos)
            end

            # Required letter: A-Z or a-z
            if letter?(byte)
              pos += 1
              byte = str.getbyte(pos)
            end

            # Optional terminal marker: ^
            if byte == CARET
              pos += 1
              byte = str.getbyte(pos)
            end

            # Optional derivation marker: '
            pos += 1 if byte == APOSTROPHE

            epin_str = str.byteslice(start_pos, pos - start_pos)

            begin
              piece = ::Sashite::Epin.parse(epin_str)
            rescue ::ArgumentError
              raise Errors::Argument, Errors::Argument::Messages::INVALID_PIECE_TOKEN
            end

            [piece, pos]
          end

          # Validates that identical pieces are aggregated.
          #
          # @param items [Array<Hash>] The hand items to validate
          # @raise [Errors::Argument] If duplicate pieces found
          def validate_aggregation!(items)
            return if items.size <= 1

            seen = {}

            items.each do |item|
              key = item[:piece].to_s

              if seen[key]
                raise Errors::Argument, Errors::Argument::Messages::HAND_ITEMS_NOT_AGGREGATED
              end

              seen[key] = true
            end
          end

          # Validates that hand items are in canonical order.
          #
          # @param items [Array<Hash>] The hand items to validate
          # @raise [Errors::Argument] If items are not in canonical order
          def validate_canonical_order!(items)
            return if items.size <= 1

            items.each_cons(2) do |item_a, item_b|
              comparison = compare_hand_items(item_a, item_b)

              if comparison >= 0
                raise Errors::Argument, Errors::Argument::Messages::HAND_ITEMS_NOT_CANONICAL
              end
            end
          end

          # Compares two hand items according to canonical ordering rules.
          #
          # Returns negative if a < b, zero if a == b, positive if a > b.
          #
          # Ordering rules:
          # 1. By multiplicity — descending (larger counts first)
          # 2. By base letter — case-insensitive alphabetical order
          # 3. By letter case — uppercase before lowercase
          # 4. By state modifier — `-` before `+` before none
          # 5. By terminal marker — absent before present
          # 6. By derivation marker — absent before present
          #
          # @param item_a [Hash] First hand item
          # @param item_b [Hash] Second hand item
          # @return [Integer] Comparison result
          def compare_hand_items(item_a, item_b)
            # 1. By multiplicity — descending
            cmp = item_b[:count] <=> item_a[:count]
            return cmp unless cmp == 0

            compare_pieces(item_a[:piece], item_b[:piece])
          end

          # Compares two EPIN pieces according to canonical ordering.
          #
          # @param piece_a [Sashite::Epin::Identifier] First piece
          # @param piece_b [Sashite::Epin::Identifier] Second piece
          # @return [Integer] Comparison result
          def compare_pieces(piece_a, piece_b)
            pin_a = piece_a.pin
            pin_b = piece_b.pin

            # 2. By base letter — case-insensitive alphabetical
            cmp = pin_a.abbr.to_s.downcase <=> pin_b.abbr.to_s.downcase
            return cmp unless cmp == 0

            # 3. By letter case — uppercase before lowercase (first before second)
            cmp = side_order(pin_a.side) <=> side_order(pin_b.side)
            return cmp unless cmp == 0

            # 4. By state modifier — `-` before `+` before none
            cmp = state_order(pin_a.state) <=> state_order(pin_b.state)
            return cmp unless cmp == 0

            # 5. By terminal marker — absent before present
            cmp = terminal_order(pin_a.terminal?) <=> terminal_order(pin_b.terminal?)
            return cmp unless cmp == 0

            # 6. By derivation marker — absent before present
            derived_order(piece_a.derived?) <=> derived_order(piece_b.derived?)
          end

          # Returns sort order for side (uppercase/first = 0, lowercase/second = 1).
          #
          # @param side [Symbol] :first or :second
          # @return [Integer] Sort order value
          def side_order(side)
            side == :first ? 0 : 1
          end

          # Returns sort order for state modifier.
          # Order: diminished (-) = 0, enhanced (+) = 1, normal = 2
          #
          # @param state [Symbol] :diminished, :enhanced, or :normal
          # @return [Integer] Sort order value
          def state_order(state)
            case state
            when :diminished then 0
            when :enhanced then 1
            else 2
            end
          end

          # Returns sort order for terminal marker.
          # Order: absent = 0, present = 1
          #
          # @param terminal [Boolean] Terminal status
          # @return [Integer] Sort order value
          def terminal_order(terminal)
            terminal ? 1 : 0
          end

          # Returns sort order for derivation marker.
          # Order: absent = 0, present = 1
          #
          # @param derived [Boolean] Derived status
          # @return [Integer] Sort order value
          def derived_order(derived)
            derived ? 1 : 0
          end

          # Checks if byte is an ASCII digit (0-9).
          #
          # @param byte [Integer, nil] The byte to check
          # @return [Boolean]
          def digit?(byte)
            byte && byte >= ZERO && byte <= NINE
          end

          # Checks if byte is an ASCII letter (A-Z or a-z).
          #
          # @param byte [Integer, nil] The byte to check
          # @return [Boolean]
          def letter?(byte)
            byte && ((byte >= UPPER_A && byte <= UPPER_Z) || (byte >= LOWER_A && byte <= LOWER_Z))
          end
        end
      end
    end
  end
end
