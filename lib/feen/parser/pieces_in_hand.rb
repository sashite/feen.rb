# frozen_string_literal: true

module Feen
  module Parser
    # Handles parsing of the pieces in hand section of a FEEN string.
    # Pieces in hand represent pieces available for dropping onto the board.
    # According to FEEN specification, pieces in hand MUST be in base form only (no modifiers).
    # Format: "UPPERCASE_PIECES/LOWERCASE_PIECES"
    module PiecesInHand
      # Error messages for validation
      Errors = {
        invalid_type:          "Pieces in hand must be a string, got %s",
        empty_string:          "Pieces in hand string cannot be empty",
        invalid_format:        "Invalid pieces in hand format: %s",
        missing_separator:     "Pieces in hand format must contain exactly one '/' separator. Got: %s",
        modifiers_not_allowed: 'Pieces in hand cannot contain modifiers: "%s"'
      }.freeze

      # Base piece pattern: single letter only (no modifiers allowed in hand)
      BASE_PIECE_PATTERN = /\A[a-zA-Z]\z/

      # Valid count pattern: 2-9 or any number with 2+ digits (no 0, 1, or leading zeros)
      VALID_COUNT_PATTERN = /\A(?:[2-9]|[1-9]\d+)\z/

      # Pattern for piece with optional count in pieces in hand
      PIECE_WITH_COUNT_PATTERN = /(?:([2-9]|[1-9]\d+))?([-+]?[a-zA-Z]'?)/

      # Complete validation pattern for pieces in hand string
      VALID_FORMAT_PATTERN = %r{\A
        (?:                                     # Uppercase section (optional)
          (?:(?:[2-9]|[1-9]\d+)?[-+]?[A-Z]'?)*  # Zero or more uppercase pieces with optional counts and modifiers
        )
        /                                       # Mandatory separator
        (?:                                     # Lowercase section (optional)
          (?:(?:[2-9]|[1-9]\d+)?[-+]?[a-z]'?)*  # Zero or more lowercase pieces with optional counts and modifiers
        )
      \z}x

      # Parses the pieces in hand section of a FEEN string.
      #
      # @param pieces_in_hand_str [String] FEEN pieces in hand string in format "UPPERCASE/lowercase"
      # @return [Array<String>] Array of piece identifiers in base form only,
      #   expanded based on their counts and sorted alphabetically.
      #   Empty array if no pieces are in hand.
      # @raise [ArgumentError] If the input string is invalid or contains modifiers
      #
      # @example Parse no pieces in hand
      #   PiecesInHand.parse("/")
      #   # => []
      #
      # @example Parse pieces with case separation
      #   PiecesInHand.parse("3P2B/p")
      #   # => ["B", "B", "P", "P", "P", "p"]
      #
      # @example Invalid - modifiers not allowed in hand
      #   PiecesInHand.parse("+P/p")
      #   # => ArgumentError: Pieces in hand cannot contain modifiers: '+P'
      def self.parse(pieces_in_hand_str)
        validate_input_type(pieces_in_hand_str)
        validate_format(pieces_in_hand_str)

        # Handle the no-pieces case early
        return [] if pieces_in_hand_str == "/"

        # Split by the separator to get uppercase and lowercase sections
        uppercase_section, lowercase_section = pieces_in_hand_str.split("/", 2)

        # Parse each section separately and validate no modifiers
        uppercase_pieces = parse_pieces_section(uppercase_section || "", :uppercase)
        lowercase_pieces = parse_pieces_section(lowercase_section || "", :lowercase)

        # Combine all pieces and sort them alphabetically
        all_pieces = uppercase_pieces + lowercase_pieces
        all_pieces.sort
      end

      # Validates that the input is a non-empty string.
      #
      # @param str [String] Input string to validate
      # @raise [ArgumentError] If input is not a string or is empty
      # @return [void]
      private_class_method def self.validate_input_type(str)
        raise ::ArgumentError, format(Errors[:invalid_type], str.class) unless str.is_a?(::String)
        raise ::ArgumentError, Errors[:empty_string] if str.empty?
      end

      # Validates that the input string matches the expected format according to FEEN specification.
      # Format must be: "UPPERCASE_PIECES/LOWERCASE_PIECES" with base pieces only (no modifiers).
      #
      # @param str [String] Input string to validate
      # @raise [ArgumentError] If format is invalid or contains modifiers
      # @return [void]
      private_class_method def self.validate_format(str)
        # Must contain exactly one "/" separator
        parts_count = str.count("/")
        raise ::ArgumentError, format(Errors[:missing_separator], parts_count) unless parts_count == 1

        # Must match the overall pattern (including potential modifiers for detection)
        raise ::ArgumentError, format(Errors[:invalid_format], str) unless str.match?(VALID_FORMAT_PATTERN)

        # Additional validation: check for any modifiers (forbidden in hand)
        validate_no_modifiers(str)
      end

      # Validates that no modifiers are present in the pieces in hand string
      #
      # @param str [String] Input string to validate
      # @raise [ArgumentError] If modifiers are found
      # @return [void]
      private_class_method def self.validate_no_modifiers(str)
        # Check for any modifier characters that are forbidden in pieces in hand
        return unless str.match?(/[+\-']/)

        # Find the specific invalid piece to provide a better error message
        invalid_pieces = str.scan(/(?:[2-9]|[1-9]\d+)?[-+]?[a-zA-Z]'?/).grep(/[+\-']/)

        raise ::ArgumentError, format(Errors[:modifiers_not_allowed], invalid_pieces.first)
      end

      # Parses a specific section (uppercase or lowercase) and returns expanded pieces
      #
      # @param section [String] The section string to parse
      # @param case_type [Symbol] Either :uppercase or :lowercase (for validation)
      # @return [Array<String>] Array of expanded pieces from this section
      private_class_method def self.parse_pieces_section(section, case_type)
        return [] if section.empty?

        # Extract pieces with their counts
        pieces_with_counts = extract_pieces_with_counts_from_section(section, case_type)

        # Expand the pieces into an array
        expand_pieces(pieces_with_counts)
      end

      # Extracts pieces with their counts from a section string.
      #
      # @param section [String] FEEN pieces section string
      # @param case_type [Symbol] Either :uppercase or :lowercase
      # @return [Array<Hash>] Array of hashes with :piece and :count keys
      # @raise [ArgumentError] If pieces don't match the expected case or contain modifiers
      private_class_method def self.extract_pieces_with_counts_from_section(section, case_type)
        result = []
        position = 0

        while position < section.length
          match = section[position..].match(PIECE_WITH_COUNT_PATTERN)
          break unless match

          count_str, piece_with_modifiers = match.captures
          count = count_str ? count_str.to_i : 1

          # Extract just the base piece (remove any modifiers)
          base_piece = extract_base_piece(piece_with_modifiers)

          # Validate piece is base form only (single letter)
          unless base_piece.match?(BASE_PIECE_PATTERN)
            raise ::ArgumentError, "Pieces in hand must be base form only: '#{base_piece}'"
          end

          # Validate count format
          if count_str && !count_str.match?(VALID_COUNT_PATTERN)
            raise ::ArgumentError, "Invalid count format: '#{count_str}'. Count cannot be '0' or '1', use the piece without count instead"
          end

          # Validate that the piece matches the expected case
          piece_case = base_piece.match?(/[A-Z]/) ? :uppercase : :lowercase
          unless piece_case == case_type
            case_name = case_type == :uppercase ? "uppercase" : "lowercase"
            raise ::ArgumentError, "Piece '#{base_piece}' has wrong case for #{case_name} section"
          end

          # Add to our result with piece type and count
          result << { piece: base_piece, count: count }

          # Move position forward
          position += match[0].length
        end

        result
      end

      # Extracts the base piece from a piece string that may contain modifiers
      #
      # @param piece_str [String] Piece string potentially with modifiers
      # @return [String] Base piece without modifiers
      private_class_method def self.extract_base_piece(piece_str)
        # Remove prefix modifiers (+ or -)
        without_prefix = piece_str.gsub(/^[-+]/, "")

        # Remove suffix modifiers (')
        without_prefix.gsub(/'$/, "")
      end

      # Expands the pieces based on their counts into an array.
      #
      # @param pieces_with_counts [Array<Hash>] Array of pieces with their counts
      # @return [Array<String>] Array of expanded pieces
      private_class_method def self.expand_pieces(pieces_with_counts)
        pieces_with_counts.flat_map do |item|
          Array.new(item[:count], item[:piece])
        end
      end
    end
  end
end
