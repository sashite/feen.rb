# frozen_string_literal: true

require "pnn"

module Feen
  module Parser
    # Handles parsing of the pieces in hand section of a FEEN string.
    # Pieces in hand represent pieces available for dropping onto the board.
    # According to FEEN v1.0.0 specification, pieces in hand MAY include PNN modifiers.
    # Format: "UPPERCASE_PIECES/LOWERCASE_PIECES"
    module PiecesInHand
      # Error messages for validation
      ERRORS = {
        invalid_type:      "Pieces in hand must be a string, got %s",
        empty_string:      "Pieces in hand string cannot be empty",
        invalid_format:    "Invalid pieces in hand format: %s",
        missing_separator: "Pieces in hand format must contain exactly one '/' separator. Got: %s",
        invalid_pnn:       "Invalid PNN piece notation: '%s'",
        invalid_count:     "Invalid count format: '%s'. Count cannot be '0' or '1'"
      }.freeze

      # Valid count pattern: 2-9 or any number with 2+ digits (no 0, 1, or leading zeros)
      VALID_COUNT_PATTERN = /\A(?:[2-9]|[1-9]\d+)\z/

      # Pattern for piece with optional count in pieces in hand (with full PNN support)
      PIECE_WITH_COUNT_PATTERN = /(?:([2-9]|[1-9]\d+))?([-+]?[a-zA-Z]'?)/

      # Complete validation pattern for pieces in hand string (with PNN modifier support)
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
      # @return [Array<String>] Array of piece identifiers (may include PNN modifiers),
      #   expanded based on their counts. Pieces are returned in the order they appear
      #   in the canonical FEEN string (not sorted alphabetically).
      # @raise [ArgumentError] If the input string is invalid
      #
      # @example Parse no pieces in hand
      #   PiecesInHand.parse("/")
      #   # => []
      #
      # @example Parse pieces with case separation
      #   PiecesInHand.parse("3P2B/p")
      #   # => ["P", "P", "P", "B", "B", "p"]
      #
      # @example Parse pieces with PNN modifiers
      #   PiecesInHand.parse("2+B5BK3-P-P'3+P'9PR2SS'/bp")
      #   # => ["+B", "+B", "B", "B", "B", "B", "B", "K", "-P", "-P", "-P", "-P'", "+P'", "+P'", "+P'", "P", "P", "P", "P", "P", "P", "P", "P", "P", "R", "S", "S", "S'", "b", "p"]
      def self.parse(pieces_in_hand_str)
        validate_input_type(pieces_in_hand_str)
        validate_format(pieces_in_hand_str)

        # Handle the no-pieces case early
        return [] if pieces_in_hand_str == "/"

        # Split by the separator to get uppercase and lowercase sections
        uppercase_section, lowercase_section = pieces_in_hand_str.split("/", 2)

        # Parse each section separately
        uppercase_pieces = parse_pieces_section(uppercase_section || "", :uppercase)
        lowercase_pieces = parse_pieces_section(lowercase_section || "", :lowercase)

        # Combine all pieces in order (uppercase first, then lowercase)
        # Do NOT sort - preserve the canonical order from the FEEN string
        uppercase_pieces + lowercase_pieces
      end

      # Validates that the input is a non-empty string.
      #
      # @param str [String] Input string to validate
      # @raise [ArgumentError] If input is not a string or is empty
      # @return [void]
      private_class_method def self.validate_input_type(str)
        raise ArgumentError, format(ERRORS[:invalid_type], str.class) unless str.is_a?(::String)
        raise ArgumentError, ERRORS[:empty_string] if str.empty?
      end

      # Validates that the input string matches the expected format according to FEEN specification.
      # Format must be: "UPPERCASE_PIECES/LOWERCASE_PIECES" with optional PNN modifiers.
      #
      # @param str [String] Input string to validate
      # @raise [ArgumentError] If format is invalid
      # @return [void]
      private_class_method def self.validate_format(str)
        # Must contain exactly one "/" separator
        parts_count = str.count("/")
        raise ArgumentError, format(ERRORS[:missing_separator], parts_count) unless parts_count == 1

        # Must match the overall pattern
        raise ArgumentError, format(ERRORS[:invalid_format], str) unless str.match?(VALID_FORMAT_PATTERN)
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
      # @raise [ArgumentError] If pieces contain invalid PNN notation
      private_class_method def self.extract_pieces_with_counts_from_section(section, case_type)
        result = []
        position = 0

        while position < section.length
          match = section[position..].match(PIECE_WITH_COUNT_PATTERN)
          break unless match

          count_str, piece_with_modifiers = match.captures
          count = count_str ? count_str.to_i : 1

          # Validate PNN format using the PNN gem
          # @see https://rubygems.org/gems/pnn
          unless ::Pnn.valid?(piece_with_modifiers)
            raise ::ArgumentError, format(ERRORS[:invalid_pnn], piece_with_modifiers)
          end

          # Validate count format
          if count_str && !count_str.match?(VALID_COUNT_PATTERN)
            raise ::ArgumentError, format(ERRORS[:invalid_count], count_str)
          end

          # Validate that the piece matches the expected case (based on base letter)
          base_letter = extract_base_letter(piece_with_modifiers)
          piece_case = base_letter.match?(/[A-Z]/) ? :uppercase : :lowercase
          unless piece_case == case_type
            case_name = case_type == :uppercase ? "uppercase" : "lowercase"
            raise ::ArgumentError, "Piece '#{piece_with_modifiers}' has wrong case for #{case_name} section"
          end

          # Add to our result with piece type and count
          result << { piece: piece_with_modifiers, count: count }

          # Move position forward
          position += match[0].length
        end

        result
      end

      # Extracts the base letter from a PNN piece identifier
      #
      # @param piece [String] PNN piece identifier (e.g., "+P'", "-R", "K")
      # @return [String] Base letter (e.g., "P", "R", "K")
      private_class_method def self.extract_base_letter(piece)
        piece.match(/[a-zA-Z]/)[0]
      end

      # Expands the pieces based on their counts into an array.
      #
      # @param pieces_with_counts [Array<Hash>] Array of pieces with their counts
      # @return [Array<String>] Array of expanded pieces preserving order
      private_class_method def self.expand_pieces(pieces_with_counts)
        pieces_with_counts.flat_map do |item|
          ::Array.new(item[:count], item[:piece])
        end
      end
    end
  end
end
