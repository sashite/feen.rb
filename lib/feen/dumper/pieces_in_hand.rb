# frozen_string_literal: true

module Feen
  module Dumper
    # Handles conversion of pieces in hand data to FEEN notation string
    module PiecesInHand
      # Error messages for validation
      ERRORS = {
        invalid_type:   "Piece at index %d must be a String, got %s",
        invalid_format: "Piece at index %d must be base form only (single letter): '%s'",
        has_modifiers:  "Piece at index %d cannot contain modifiers: '%s'. Pieces in hand must be base form only"
      }.freeze

      # Converts an array of piece identifiers to a FEEN-formatted pieces in hand string
      #
      # @param piece_chars [Array<String>] Array of piece identifiers in base form only (e.g., ["P", "p", "B", "B", "p"])
      # @return [String] FEEN-formatted pieces in hand string following the format:
      #   - Groups pieces by case: uppercase first, then lowercase, separated by "/"
      #   - Within each group, sorts by quantity (descending), then alphabetically (ascending)
      #   - Uses count notation for quantities > 1 (e.g., "3P" instead of "PPP")
      # @raise [ArgumentError] If any piece identifier is invalid or contains modifiers
      #
      # @example Valid pieces in hand
      #   PiecesInHand.dump("P", "P", "P", "B", "B", "p", "p", "p", "p", "p")
      #   # => "3P2B/5p"
      #
      # @example Valid pieces in hand with mixed order
      #   PiecesInHand.dump("p", "P", "B")
      #   # => "BP/p"
      #
      # @example No pieces in hand
      #   PiecesInHand.dump()
      #   # => "/"
      #
      # @example Invalid - modifiers not allowed
      #   PiecesInHand.dump("+P", "p")
      #   # => ArgumentError: Piece at index 0 cannot contain modifiers: '+P'
      def self.dump(*piece_chars)
        # Validate each piece character according to FEEN specification (base form only)
        validated_chars = validate_piece_chars(piece_chars)

        # Group pieces by case
        uppercase_pieces, lowercase_pieces = group_pieces_by_case(validated_chars)

        # Format each group according to FEEN specification
        uppercase_formatted = format_pieces_group(uppercase_pieces)
        lowercase_formatted = format_pieces_group(lowercase_pieces)

        # Combine with separator
        "#{uppercase_formatted}/#{lowercase_formatted}"
      end

      # Groups pieces by case (uppercase vs lowercase)
      #
      # @param pieces [Array<String>] Array of validated piece identifiers
      # @return [Array<Array<String>, Array<String>>] Two arrays: [uppercase_pieces, lowercase_pieces]
      private_class_method def self.group_pieces_by_case(pieces)
        uppercase_pieces = pieces.grep(/[A-Z]/)
        lowercase_pieces = pieces.grep(/[a-z]/)

        [uppercase_pieces, lowercase_pieces]
      end

      # Formats a group of pieces according to FEEN specification
      #
      # @param pieces [Array<String>] Array of pieces from the same case group
      # @return [String] Formatted string for this group (e.g., "3P2B", "5pq")
      private_class_method def self.format_pieces_group(pieces)
        return "" if pieces.empty?

        # Count occurrences of each piece type
        piece_counts = pieces.each_with_object(Hash.new(0)) do |piece, counts|
          counts[piece] += 1
        end

        # Sort by count (descending) then alphabetically (ascending)
        sorted_pieces = piece_counts.sort do |a, b|
          piece_a, count_a = a
          piece_b, count_b = b

          # Primary sort: by count (descending)
          count_comparison = count_b <=> count_a
          next count_comparison unless count_comparison.zero?

          # Secondary sort: by piece name (ascending)
          piece_a <=> piece_b
        end

        # Format each piece with its count
        sorted_pieces.map do |piece, count|
          if count == 1
            piece
          else
            "#{count}#{piece}"
          end
        end.join
      end

      # Validates all piece characters according to FEEN specification (base form only)
      #
      # @param piece_chars [Array<Object>] Array of piece character candidates
      # @return [Array<String>] Array of validated piece characters
      # @raise [ArgumentError] If any piece character is invalid or contains modifiers
      private_class_method def self.validate_piece_chars(piece_chars)
        piece_chars.each_with_index.map do |char, index|
          validate_piece_char(char, index)
        end
      end

      # Validates a single piece character according to FEEN specification
      # For pieces in hand, only base form is allowed: single letter (a-z or A-Z)
      # NO modifiers (+, -, ') are allowed in pieces in hand
      #
      # @param char [Object] Piece character candidate
      # @param index [Integer] Index of the character in the original array
      # @return [String] Validated piece character
      # @raise [ArgumentError] If the piece character is invalid or contains modifiers
      private_class_method def self.validate_piece_char(char, index)
        # Validate type
        raise ArgumentError, format(ERRORS[:invalid_type], index, char.class) unless char.is_a?(String)

        # Check for forbidden modifiers first (clearer error message)
        raise ArgumentError, format(ERRORS[:has_modifiers], index, char) if char.match?(/[+\-']/)

        # Validate format: must be exactly one letter (base form only)
        raise ArgumentError, format(ERRORS[:invalid_format], index, char) unless char.match?(/\A[a-zA-Z]\z/)

        char
      end
    end
  end
end
