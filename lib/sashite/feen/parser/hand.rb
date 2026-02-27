# frozen_string_literal: true

require "sashite/epin"

require_relative "../shared/ascii"
require_relative "../errors/hands_error"

module Sashite
  module Feen
    module Parser
      # Parser for a single hand within the FEEN Hands field.
      #
      # A hand is a concatenation of hand items with no separators:
      #
      #   [<count>]<piece>
      #
      # Where:
      # - <piece> is a valid EPIN token
      # - <count> is an optional multiplicity (>= 2 if present, absent = 1)
      #
      # Hand items MUST be in canonical order:
      # 1. By multiplicity -- descending (larger counts first)
      # 2. By base letter -- case-insensitive alphabetical order
      # 3. By letter case -- uppercase before lowercase
      # 4. By state modifier -- `-` before `+` before none
      # 5. By terminal marker -- absent before present
      # 6. By derivation marker -- absent before present
      #
      # Additionally, identical EPIN tokens MUST be aggregated (not repeated).
      #
      # Returns a flat array of EPIN token strings, with each piece repeated
      # according to its multiplicity, ready for Qi::Position hands.
      #
      # @example Parsing an empty hand
      #   Hand.parse("")
      #   # => []
      #
      # @example Parsing a hand with pieces
      #   Hand.parse("2PNR")
      #   # => ["P", "P", "N", "R"]
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module Hand
        # Parses a single hand string into a flat array of EPIN token strings.
        #
        # @param input [String] The hand string to parse
        # @return [Array<String>] Flat array of EPIN token strings
        # @raise [HandsError] If the input is not valid
        def self.parse(input)
          return [] if input.empty?

          items = extract_items(input)

          validate_aggregation!(items)
          validate_canonical_order!(items)

          expand(items)
        end

        class << self
          private

          # Extracts hand items from the input string.
          #
          # Each item is a two-element array [count, piece_string].
          #
          # @param input [String] The hand string to parse
          # @return [Array<Array(Integer, String)>] Array of [count, piece] pairs
          def extract_items(input)
            items = []
            pos = 0

            while pos < input.bytesize
              count, pos = extract_count(input, pos)
              piece, pos = extract_piece(input, pos)
              items << [count, piece]
            end

            items
          end

          # Extracts an optional count prefix starting at pos.
          #
          # @param str [String] The string to extract from
          # @param pos [Integer] Starting position
          # @return [Array(Integer, Integer)] The count (1 if absent) and new position
          # @raise [HandsError] If count is invalid
          def extract_count(str, pos)
            byte = str.getbyte(pos)
            return [1, pos] unless Ascii.digit?(byte)

            start_pos = pos
            pos += 1 while pos < str.bytesize && Ascii.digit?(str.getbyte(pos))

            count_str = str.byteslice(start_pos, pos - start_pos)
            validate_count!(count_str)

            [count_str.to_i, pos]
          end

          # Validates a count string.
          #
          # @param count_str [String] The count string to validate
          # @raise [HandsError] If count is 0, 1, or has leading zeros
          def validate_count!(count_str)
            # Leading zeros are forbidden
            if count_str.bytesize > 1 && count_str.getbyte(0) == Ascii::ZERO
              raise HandsError, HandsError::INVALID_COUNT
            end

            count = count_str.to_i

            # Count must be >= 2 when explicit (1 is implicit)
            return if count >= 2

            raise HandsError, HandsError::INVALID_COUNT
          end

          # Extracts and validates an EPIN token starting at pos.
          #
          # Returns the raw EPIN string rather than an Identifier object
          # for performance. Validation is delegated to sashite-epin.
          #
          # EPIN structure: [+-]?[A-Za-z]\^?'?
          #
          # @param str [String] The string to extract from
          # @param pos [Integer] Starting position
          # @return [Array(String, Integer)] The EPIN token string and new position
          # @raise [HandsError] If EPIN parsing fails
          def extract_piece(str, pos)
            start_pos = pos
            byte = str.getbyte(pos)

            # Optional state modifier: + or -
            if byte == Ascii::PLUS || byte == Ascii::MINUS
              pos += 1
              byte = str.getbyte(pos)
            end

            # Required letter: A-Z or a-z
            if Ascii.letter?(byte)
              pos += 1
              byte = str.getbyte(pos)
            end

            # Optional terminal marker: ^
            if byte == Ascii::CARET
              pos += 1
              byte = str.getbyte(pos)
            end

            # Optional derivation marker: '
            pos += 1 if byte == Ascii::APOSTROPHE

            epin_str = str.byteslice(start_pos, pos - start_pos)

            begin
              ::Sashite::Epin.parse(epin_str)
            rescue ::ArgumentError
              raise HandsError, HandsError::INVALID_PIECE_TOKEN
            end

            [epin_str, pos]
          end

          # Validates that identical pieces are aggregated.
          #
          # @param items [Array<Array(Integer, String)>] The hand items to validate
          # @raise [HandsError] If duplicate pieces found
          def validate_aggregation!(items)
            return if items.size <= 1

            seen = {}

            items.each do |_count, piece|
              raise HandsError, HandsError::NOT_AGGREGATED if seen[piece]

              seen[piece] = true
            end
          end

          # Validates that hand items are in canonical order.
          #
          # @param items [Array<Array(Integer, String)>] The hand items to validate
          # @raise [HandsError] If items are not in canonical order
          def validate_canonical_order!(items)
            return if items.size <= 1

            items.each_cons(2) do |(count_a, piece_a), (count_b, piece_b)|
              cmp = compare_items(count_a, piece_a, count_b, piece_b)

              raise HandsError, HandsError::NOT_CANONICAL if cmp >= 0
            end
          end

          # Compares two hand items according to canonical ordering rules.
          #
          # Returns negative if a < b, zero if a == b, positive if a > b.
          #
          # @param count_a [Integer] First item count
          # @param piece_a [String] First item EPIN string
          # @param count_b [Integer] Second item count
          # @param piece_b [String] Second item EPIN string
          # @return [Integer] Comparison result
          def compare_items(count_a, piece_a, count_b, piece_b)
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
          # - letter: raw byte value (for case-insensitive: use `| 0x20`)
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

          # Expands aggregated items into a flat array of EPIN strings.
          #
          # @param items [Array<Array(Integer, String)>] Aggregated [count, piece] pairs
          # @return [Array<String>] Flat array with each piece repeated by count
          def expand(items)
            result = []

            items.each do |count, piece|
              count.times { result << piece }
            end

            result
          end
        end

        private_class_method :extract_items,
                             :extract_count,
                             :validate_count!,
                             :extract_piece,
                             :validate_aggregation!,
                             :validate_canonical_order!,
                             :compare_items,
                             :compare_pieces,
                             :decompose,
                             :case_rank,
                             :expand

        freeze
      end
    end
  end
end
