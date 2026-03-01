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
      # Returns an expanded array of piece strings, ready for Qi's hand accessors.
      #
      # Provides a dual-path API:
      # - {.safe_parse} returns nil on invalid input (no exceptions)
      # - {.parse} raises {HandsError} on invalid input
      #
      # @example Parsing an empty hand
      #   Hand.safe_parse("")
      #   # => []
      #
      # @example Parsing a hand with pieces
      #   Hand.safe_parse("2PNR")
      #   # => ["P", "P", "N", "R"]
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module Hand
        # Parses a single hand string, returning nil on failure.
        #
        # @param input [String] The hand string to parse
        # @return [Array<String>, nil] Expanded array of piece strings, or nil if invalid
        def self.safe_parse(input)
          return [] if input.empty?

          items = safe_extract_items(input)
          return nil if items.nil?

          return nil unless aggregated?(items)
          return nil unless canonical_order?(items)

          to_expanded_array(items)
        end

        # Parses a single hand string, raising on failure.
        #
        # @param input [String] The hand string to parse
        # @return [Array<String>] Expanded array of piece strings
        # @raise [HandsError] If the input is not valid
        def self.parse(input)
          result = safe_parse(input)
          return result unless result.nil?

          # Re-validate to produce the specific error message
          raise_specific_error!(input)
        end

        class << self
          private

          # Extracts hand items without raising exceptions.
          #
          # Each item is a two-element array [count, piece_string].
          #
          # @param input [String] The hand string to parse
          # @return [Array<Array(Integer, String)>, nil] Array of [count, piece] pairs, or nil
          def safe_extract_items(input)
            items = []
            pos = 0

            while pos < input.bytesize
              count, pos = safe_extract_count(input, pos)
              return nil if count.nil?

              piece, pos = safe_extract_piece(input, pos)
              return nil if piece.nil?

              items << [count, piece]
            end

            items
          end

          # Extracts an optional count prefix starting at pos, without raising.
          #
          # @param str [String] The string to extract from
          # @param pos [Integer] Starting position
          # @return [Array(Integer, Integer), Array(nil, nil)] The count and new position, or [nil, nil]
          def safe_extract_count(str, pos)
            byte = str.getbyte(pos)
            return [1, pos] unless Ascii.digit?(byte)

            start_pos = pos
            pos += 1 while pos < str.bytesize && Ascii.digit?(str.getbyte(pos))

            count_str = str.byteslice(start_pos, pos - start_pos)

            # Leading zeros are forbidden
            return [nil, nil] if count_str.bytesize > 1 && count_str.getbyte(0) == Ascii::ZERO

            count = count_str.to_i

            # Count must be >= 2 when explicit (1 is implicit)
            return [nil, nil] if count < 2

            [count, pos]
          end

          # Extracts and validates an EPIN token starting at pos, without raising.
          #
          # EPIN structure: [+-]?[A-Za-z]\^?'?
          #
          # @param str [String] The string to extract from
          # @param pos [Integer] Starting position
          # @return [Array(String, Integer), Array(nil, nil)] The EPIN token and new position, or [nil, nil]
          def safe_extract_piece(str, pos)
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

            return [nil, nil] unless ::Sashite::Epin.valid?(epin_str)

            [epin_str, pos]
          end

          # Checks that identical pieces are aggregated (no duplicates).
          #
          # @param items [Array<Array(Integer, String)>] The hand items
          # @return [Boolean]
          def aggregated?(items)
            return true if items.size <= 1

            seen = {}

            items.each do |_count, piece|
              return false if seen[piece]

              seen[piece] = true
            end

            true
          end

          # Checks that hand items are in canonical order.
          #
          # @param items [Array<Array(Integer, String)>] The hand items
          # @return [Boolean]
          def canonical_order?(items)
            return true if items.size <= 1

            items.each_cons(2) do |(count_a, piece_a), (count_b, piece_b)|
              cmp = compare_items(count_a, piece_a, count_b, piece_b)
              return false if cmp >= 0
            end

            true
          end

          # Expands items into a flat array of piece strings.
          #
          # @param items [Array<Array(Integer, String)>] Validated [count, piece] pairs
          # @return [Array<String>]
          def to_expanded_array(items)
            result = []

            items.each do |count, piece|
              count.times { result << piece }
            end

            result
          end

          # Re-validates input to determine the specific error to raise.
          #
          # Only called on the error path (after safe_parse returned nil).
          #
          # @param input [String] The invalid input
          # @raise [HandsError] Always raises with a specific message
          def raise_specific_error!(input)
            items = []
            pos = 0

            while pos < input.bytesize
              count, pos = raise_extract_count!(input, pos)
              piece, pos = raise_extract_piece!(input, pos)
              items << [count, piece]
            end

            raise_aggregation!(items)
            raise_canonical_order!(items)
          end

          # Extracts count on the error path, raising on failure.
          #
          # @param str [String] The string to extract from
          # @param pos [Integer] Starting position
          # @return [Array(Integer, Integer)] The count and new position
          # @raise [HandsError] If count is invalid
          def raise_extract_count!(str, pos)
            byte = str.getbyte(pos)
            return [1, pos] unless Ascii.digit?(byte)

            start_pos = pos
            pos += 1 while pos < str.bytesize && Ascii.digit?(str.getbyte(pos))

            count_str = str.byteslice(start_pos, pos - start_pos)

            if count_str.bytesize > 1 && count_str.getbyte(0) == Ascii::ZERO
              raise HandsError, HandsError::INVALID_COUNT
            end

            count = count_str.to_i

            raise HandsError, HandsError::INVALID_COUNT if count < 2

            [count, pos]
          end

          # Extracts EPIN token on the error path, raising on failure.
          #
          # @param str [String] The string to extract from
          # @param pos [Integer] Starting position
          # @return [Array(String, Integer)] The EPIN token and new position
          # @raise [HandsError] If EPIN validation fails
          def raise_extract_piece!(str, pos)
            start_pos = pos
            byte = str.getbyte(pos)

            if byte == Ascii::PLUS || byte == Ascii::MINUS
              pos += 1
              byte = str.getbyte(pos)
            end

            if Ascii.letter?(byte)
              pos += 1
              byte = str.getbyte(pos)
            end

            if byte == Ascii::CARET
              pos += 1
              byte = str.getbyte(pos)
            end

            pos += 1 if byte == Ascii::APOSTROPHE

            epin_str = str.byteslice(start_pos, pos - start_pos)

            raise HandsError, HandsError::INVALID_PIECE_TOKEN unless ::Sashite::Epin.valid?(epin_str)

            [epin_str, pos]
          end

          # Validates aggregation on the error path, raising on failure.
          #
          # @param items [Array<Array(Integer, String)>] The hand items
          # @raise [HandsError] If duplicate pieces found
          def raise_aggregation!(items)
            return if items.size <= 1

            seen = {}

            items.each do |_count, piece|
              raise HandsError, HandsError::NOT_AGGREGATED if seen[piece]

              seen[piece] = true
            end
          end

          # Validates canonical order on the error path, raising on failure.
          #
          # @param items [Array<Array(Integer, String)>] The hand items
          # @raise [HandsError] If items are not in canonical order
          def raise_canonical_order!(items)
            return if items.size <= 1

            items.each_cons(2) do |(count_a, piece_a), (count_b, piece_b)|
              cmp = compare_items(count_a, piece_a, count_b, piece_b)

              raise HandsError, HandsError::NOT_CANONICAL if cmp >= 0
            end
          end

          # Compares two hand items according to canonical ordering rules.
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
          #
          # @param byte [Integer] Letter byte value
          # @return [Integer] Sort rank
          def case_rank(byte)
            Ascii.uppercase?(byte) ? 0 : 1
          end
        end

        private_class_method :safe_extract_items,
                             :safe_extract_count,
                             :safe_extract_piece,
                             :aggregated?,
                             :canonical_order?,
                             :to_expanded_array,
                             :raise_specific_error!,
                             :raise_extract_count!,
                             :raise_extract_piece!,
                             :raise_aggregation!,
                             :raise_canonical_order!,
                             :compare_items,
                             :compare_pieces,
                             :decompose,
                             :case_rank

        freeze
      end
    end
  end
end
