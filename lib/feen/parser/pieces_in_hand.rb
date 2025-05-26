# frozen_string_literal: true

require_relative File.join("pieces_in_hand", "errors")
require_relative File.join("pieces_in_hand", "pnn_patterns")

module Feen
  module Parser
    # Handles parsing of the pieces in hand section of a FEEN string.
    # Pieces in hand represent pieces available for dropping onto the board.
    # This implementation supports full PNN notation including prefixes and suffixes.
    # Format: "UPPERCASE_PIECES/LOWERCASE_PIECES"
    module PiecesInHand
      # Parses the pieces in hand section of a FEEN string.
      #
      # @param pieces_in_hand_str [String] FEEN pieces in hand string in format "UPPERCASE/lowercase"
      # @return [Array<String>] Array of piece identifiers in full PNN format,
      #   expanded based on their counts and sorted alphabetically.
      #   Empty array if no pieces are in hand.
      # @raise [ArgumentError] If the input string is invalid
      #
      # @example Parse no pieces in hand
      #   PiecesInHand.parse("/")
      #   # => []
      #
      # @example Parse pieces with case separation
      #   PiecesInHand.parse("3P2B/p")
      #   # => ["B", "B", "P", "P", "P", "p"]
      #
      # @example Parse complex pieces with counts and modifiers
      #   PiecesInHand.parse("10P5K3B/2p'+p-pbq")
      #   # => ["+p", "-p", "B", "B", "B", "K", "K", "K", "K", "K",
      #   #     "P", "P", "P", "P", "P", "P", "P", "P", "P", "P",
      #   #     "b", "p'", "p'", "q"]
      def self.parse(pieces_in_hand_str)
        # Validate input
        validate_input_type(pieces_in_hand_str)
        validate_format(pieces_in_hand_str)

        # Handle the no-pieces case early
        return [] if pieces_in_hand_str == "/"

        # Split by the separator to get uppercase and lowercase sections
        uppercase_section, lowercase_section = pieces_in_hand_str.split("/", 2)

        # Parse each section separately
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
      # Format must be: "UPPERCASE_PIECES/LOWERCASE_PIECES"
      #
      # @param str [String] Input string to validate
      # @raise [ArgumentError] If format is invalid
      # @return [void]
      private_class_method def self.validate_format(str)
        # Must contain exactly one "/" separator
        parts_count = str.count("/")
        raise ::ArgumentError, format(Errors[:invalid_format], str) unless parts_count == 1

        uppercase_section, lowercase_section = str.split("/", 2)

        # Each section can be empty, but if not empty, must follow PNN patterns
        validate_section_format(uppercase_section, :uppercase) unless uppercase_section.empty?
        validate_section_format(lowercase_section, :lowercase) unless lowercase_section.empty?
      end

      # Validates the format of a specific section (uppercase or lowercase)
      #
      # @param section [String] The section to validate
      # @param case_type [Symbol] Either :uppercase or :lowercase
      # @raise [ArgumentError] If the section format is invalid
      # @return [void]
      private_class_method def self.validate_section_format(section, case_type)
        return if section.empty?

        # Build the appropriate pattern based on case type
        case_pattern = case case_type
                       when :uppercase
                         PnnPatterns::UPPERCASE_SECTION_PATTERN
                       when :lowercase
                         PnnPatterns::LOWERCASE_SECTION_PATTERN
                       else
                         raise ArgumentError, "Invalid case type: #{case_type}"
                       end

        # Validate overall section pattern
        raise ::ArgumentError, format(Errors[:invalid_format], section) unless section.match?(case_pattern)

        # Validate individual pieces in the section
        validate_individual_pieces_in_section(section, case_type)
      end

      # Validates each individual piece in a section for PNN compliance
      #
      # @param section [String] FEEN pieces section string
      # @param case_type [Symbol] Either :uppercase or :lowercase
      # @raise [ArgumentError] If any piece is invalid PNN format
      # @return [void]
      private_class_method def self.validate_individual_pieces_in_section(section, case_type)
        position = 0

        while position < section.length
          match = section[position..].match(PnnPatterns::PIECE_WITH_COUNT_PATTERN)

          unless match
            remaining = section[position..]
            raise ::ArgumentError, format(Errors[:invalid_format], remaining)
          end

          count_str, piece = match.captures

          # Skip empty matches (shouldn't happen with our pattern, but safety check)
          if piece.nil? || piece.empty?
            position += 1
            next
          end

          # Validate the piece follows PNN specification
          unless piece.match?(PnnPatterns::PNN_PIECE_PATTERN)
            raise ::ArgumentError, format(Errors[:invalid_pnn_piece], piece)
          end

          # Validate count format (no "0" or "1" prefixes allowed)
          if count_str && !count_str.match?(PnnPatterns::VALID_COUNT_PATTERN)
            raise ::ArgumentError, format(Errors[:invalid_count], count_str)
          end

          # Validate that the piece matches the expected case
          piece_case = piece_is_uppercase?(piece) ? :uppercase : :lowercase
          unless piece_case == case_type
            case_name = case_type == :uppercase ? "uppercase" : "lowercase"
            raise ::ArgumentError, "#{case_name.capitalize} section contains #{piece_case} piece: '#{piece}'"
          end

          position += match[0].length
        end
      end

      # Determines if a piece belongs to the uppercase group
      #
      # @param piece [String] Piece identifier (e.g., "P", "+P", "P'", "+P'")
      # @return [Boolean] True if the piece's main letter is uppercase
      private_class_method def self.piece_is_uppercase?(piece)
        # Extract the main letter (skip prefixes like + or -)
        main_letter = piece.gsub(/\A[+-]/, "").gsub(/'\z/, "")
        main_letter.match?(/[A-Z]/)
      end

      # Parses a specific section (uppercase or lowercase) and returns expanded pieces
      #
      # @param section [String] The section string to parse
      # @param case_type [Symbol] Either :uppercase or :lowercase (for validation)
      # @return [Array<String>] Array of expanded pieces from this section
      private_class_method def self.parse_pieces_section(section, _case_type)
        return [] if section.empty?

        # Extract pieces with their counts
        pieces_with_counts = extract_pieces_with_counts_from_section(section)

        # Expand the pieces into an array (no canonical order validation needed)
        expand_pieces(pieces_with_counts)
      end

      # Extracts pieces with their counts from a section string.
      #
      # @param section [String] FEEN pieces section string
      # @return [Array<Hash>] Array of hashes with :piece and :count keys
      private_class_method def self.extract_pieces_with_counts_from_section(section)
        result = []
        position = 0

        while position < section.length
          match = section[position..].match(PnnPatterns::PIECE_WITH_COUNT_PATTERN)
          break unless match

          count_str, piece = match.captures
          count = count_str ? count_str.to_i : 1

          # Add to our result with piece type and count
          result << { piece: piece, count: count }

          # Move position forward
          position += match[0].length
        end

        result
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
