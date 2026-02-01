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
      # - <count> is an optional multiplicity (≥ 2 if present, absent = 1)
      #
      # Hand items MUST be in canonical order:
      # 1. By multiplicity – descending (larger counts first)
      # 2. By base letter – case-insensitive alphabetical order
      # 3. By letter case – uppercase before lowercase
      # 4. By state modifier – `-` before `+` before none
      # 5. By terminal marker – absent before present
      # 6. By derivation marker – absent before present
      #
      # Additionally, identical EPIN tokens MUST be aggregated (not repeated).
      #
      # @example Parsing an empty hand
      #   Hand.parse("")
      #   # => []
      #
      # @example Parsing a hand with pieces
      #   Hand.parse("2PNR")
      #   # => [{ piece: <P>, count: 2 }, { piece: <N>, count: 1 }, { piece: <R>, count: 1 }]
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module Hand
        # Parses a single hand string into an array of hand items.
        #
        # @param input [String] The hand string to parse
        # @return [Array<Hash>] Array of hand items with :piece and :count keys
        # @raise [HandsError] If the input is not valid
        def self.parse(input)
          return [] if input.empty?

          items = extract_items(input)

          validate_aggregation!(items)
          validate_canonical_order!(items)

          items
        end

        class << self
          private

          # Extracts hand items from the input string.
          #
          # @param input [String] The hand string to parse
          # @return [Array<Hash>] Array of hand items
          def extract_items(input)
            items = []
            pos = 0

            while pos < input.bytesize
              count, pos = extract_count(input, pos)
              piece, pos = extract_piece(input, pos)
              items << { piece:, count: }
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

          # Extracts and parses an EPIN token starting at pos.
          #
          # EPIN structure: [+-]?[A-Za-z]\^?'?
          #
          # @param str [String] The string to extract from
          # @param pos [Integer] Starting position
          # @return [Array(Sashite::Epin::Identifier, Integer)] The parsed EPIN and new position
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
              piece = ::Sashite::Epin.parse(epin_str)
            rescue ::ArgumentError
              raise HandsError, HandsError::INVALID_PIECE_TOKEN
            end

            [piece, pos]
          end

          # Validates that identical pieces are aggregated.
          #
          # @param items [Array<Hash>] The hand items to validate
          # @raise [HandsError] If duplicate pieces found
          def validate_aggregation!(items)
            return if items.size <= 1

            seen = {}

            items.each do |item|
              key = item[:piece].to_s

              raise HandsError, HandsError::NOT_AGGREGATED if seen[key]

              seen[key] = true
            end
          end

          # Validates that hand items are in canonical order.
          #
          # @param items [Array<Hash>] The hand items to validate
          # @raise [HandsError] If items are not in canonical order
          def validate_canonical_order!(items)
            return if items.size <= 1

            items.each_cons(2) do |item_a, item_b|
              comparison = compare_items(item_a, item_b)

              raise HandsError, HandsError::NOT_CANONICAL if comparison >= 0
            end
          end

          # Compares two hand items according to canonical ordering rules.
          #
          # Returns negative if a < b, zero if a == b, positive if a > b.
          #
          # Ordering rules:
          # 1. By multiplicity – descending (larger counts first)
          # 2. By base letter – case-insensitive alphabetical order
          # 3. By letter case – uppercase before lowercase
          # 4. By state modifier – `-` before `+` before none
          # 5. By terminal marker – absent before present
          # 6. By derivation marker – absent before present
          #
          # @param item_a [Hash] First hand item
          # @param item_b [Hash] Second hand item
          # @return [Integer] Comparison result
          def compare_items(item_a, item_b)
            # 1. By multiplicity – descending
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
            str_a = piece_a.to_s
            str_b = piece_b.to_s

            # Extract components from EPIN strings
            comp_a = extract_components(str_a)
            comp_b = extract_components(str_b)

            # 2. By base letter – case-insensitive alphabetical
            cmp = comp_a[:letter].downcase <=> comp_b[:letter].downcase
            return cmp unless cmp == 0

            # 3. By letter case – uppercase before lowercase
            cmp = case_order(comp_a[:letter]) <=> case_order(comp_b[:letter])
            return cmp unless cmp == 0

            # 4. By state modifier – `-` before `+` before none
            cmp = state_order(comp_a[:state]) <=> state_order(comp_b[:state])
            return cmp unless cmp == 0

            # 5. By terminal marker – absent before present
            cmp = marker_order(comp_a[:terminal]) <=> marker_order(comp_b[:terminal])
            return cmp unless cmp == 0

            # 6. By derivation marker – absent before present
            marker_order(comp_a[:derived]) <=> marker_order(comp_b[:derived])
          end

          # Extracts components from an EPIN string.
          #
          # @param str [String] EPIN string
          # @return [Hash] Components: :state, :letter, :terminal, :derived
          def extract_components(str)
            pos = 0

            # State modifier
            state = :normal
            if str[pos] == "+" || str[pos] == "-"
              state = str[pos] == "-" ? :diminished : :enhanced
              pos += 1
            end

            # Letter
            letter = str[pos]
            pos += 1

            # Terminal marker
            terminal = false
            if str[pos] == "^"
              terminal = true
              pos += 1
            end

            # Derivation marker
            derived = str[pos] == "'"

            { state:, letter:, terminal:, derived: }
          end

          # Returns sort order for letter case (uppercase = 0, lowercase = 1).
          #
          # @param letter [String] Single letter
          # @return [Integer] Sort order value
          def case_order(letter)
            letter == letter.upcase ? 0 : 1
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

          # Returns sort order for boolean marker.
          # Order: absent (false) = 0, present (true) = 1
          #
          # @param present [Boolean] Marker presence
          # @return [Integer] Sort order value
          def marker_order(present)
            present ? 1 : 0
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
                             :extract_components,
                             :case_order,
                             :state_order,
                             :marker_order

        freeze
      end
    end
  end
end
