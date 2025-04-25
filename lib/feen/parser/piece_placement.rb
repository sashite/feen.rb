# frozen_string_literal: true

module Feen
  module Parser
    # Handles parsing of the piece placement section of a FEEN string
    module PiecePlacement
      # Error messages
      ERRORS = {
        invalid_type:       "Piece placement must be a string, got %s",
        empty_string:       "Piece placement string cannot be empty",
        invalid_chars:      "Invalid characters in piece placement: %s",
        invalid_prefix:     "Expected piece identifier after '+' prefix",
        invalid_piece:      "Invalid piece identifier at position %d: %s",
        trailing_separator: "Unexpected separator at the end of string or dimension group"
      }.freeze

      # Valid characters for validation
      VALID_CHARS_PATTERN = %r{\A[a-zA-Z0-9/+<=>\s]+\z}

      # Empty string for initialization
      EMPTY_STRING = ""

      # Dimension separator character
      DIMENSION_SEPARATOR = "/"

      # Piece promotion prefix
      PREFIX_PROMOTION = "+"

      # Valid piece suffixes
      SUFFIX_EQUALS = "="
      SUFFIX_LEFT = "<"
      SUFFIX_RIGHT = ">"
      VALID_SUFFIXES = [SUFFIX_EQUALS, SUFFIX_LEFT, SUFFIX_RIGHT].freeze

      # Parses the piece placement section of a FEEN string
      #
      # @param piece_placement_str [String] FEEN piece placement string
      # @return [Array] Hierarchical array structure representing the board
      # @raise [ArgumentError] If the input string is invalid
      def self.parse(piece_placement_str)
        validate_piece_placement_string(piece_placement_str)

        # Check for trailing separators that don't contribute to dimension structure
        raise ArgumentError, ERRORS[:trailing_separator] if piece_placement_str.end_with?(DIMENSION_SEPARATOR)

        parse_dimension_group(piece_placement_str)
      end

      # Validates the piece placement string for basic syntax
      #
      # @param str [String] FEEN piece placement string
      # @raise [ArgumentError] If the string is invalid
      # @return [void]
      def self.validate_piece_placement_string(str)
        raise ArgumentError, format(ERRORS[:invalid_type], str.class) unless str.is_a?(String)

        raise ArgumentError, ERRORS[:empty_string] if str.empty?

        # Check for valid characters
        return if str.match?(VALID_CHARS_PATTERN)

        invalid_chars = str.scan(%r{[^a-zA-Z0-9/+<=>]}).uniq.join(", ")
        raise ArgumentError, format(ERRORS[:invalid_chars], invalid_chars)
      end

      # Finds all separator types present in the string (e.g., /, //, ///)
      #
      # @param str [String] FEEN dimension group string
      # @return [Array<Integer>] Sorted array of separator depths (1 for /, 2 for //, etc.)
      def self.find_separator_types(str)
        # Find all consecutive sequences of '/'
        separators = str.scan(%r{/+})
        return [] if separators.empty?

        # Return a unique sorted array of separator lengths
        separators.map(&:length).uniq.sort
      end

      # Finds the minimum dimension depth in the string
      #
      # @param str [String] FEEN dimension group string
      # @return [Integer] Minimum dimension depth (defaults to 1)
      def self.find_min_dimension_depth(str)
        separator_types = find_separator_types(str)
        separator_types.empty? ? 1 : separator_types.first
      end

      # Recursively parses a dimension group
      #
      # @param str [String] FEEN dimension group string
      # @return [Array] Hierarchical array structure representing the dimension group
      def self.parse_dimension_group(str)
        # Check for trailing separators at each level
        raise ArgumentError, ERRORS[:trailing_separator] if str.end_with?(DIMENSION_SEPARATOR)

        # Find all separator types present in the string
        separator_types = find_separator_types(str)
        return parse_rank(str) if separator_types.empty?

        # Start with the deepest separator (largest number of consecutive /)
        max_depth = separator_types.last
        separator = DIMENSION_SEPARATOR * max_depth

        # Split the string by this separator depth
        parts = split_by_separator(str, separator)

        # Create the hierarchical structure
        parts.map do |part|
          # Check each part for trailing separators of lower depths
          raise ArgumentError, ERRORS[:trailing_separator] if part.end_with?(DIMENSION_SEPARATOR)

          if max_depth == 1
            # If this is the lowest level separator, parse as ranks
            parse_rank(part)
          else
            # Otherwise, continue recursively with lower level separators
            parse_dimension_group(part)
          end
        end
      end

      # Splits a string by a given separator, preserving separators of different depths
      #
      # @param str [String] String to split
      # @param separator [String] Separator to split by (e.g., "/", "//")
      # @return [Array<String>] Array of split parts
      def self.split_by_separator(str, separator)
        return [str] unless str.include?(separator)

        parts = []
        current_part = ""
        i = 0

        while i < str.length
          # Si nous trouvons le début d'un séparateur potentiel
          if str[i] == DIMENSION_SEPARATOR[0]
            # Vérifier si c'est notre séparateur exact
            if i <= str.length - separator.length && str[i, separator.length] == separator
              # C'est notre séparateur, ajouter la partie actuelle à la liste
              parts << current_part unless current_part.empty?
              current_part = ""
              i += separator.length
            else
              # Ce n'est pas notre séparateur exact, compter combien de '/' consécutifs
              start = i
              i += 1 while i < str.length && str[i] == DIMENSION_SEPARATOR[0]
              # Ajouter ces '/' à la partie actuelle
              current_part += str[start...i]
            end
          else
            # Caractère normal, l'ajouter à la partie actuelle
            current_part += str[i]
            i += 1
          end
        end

        # Ajouter la dernière partie si elle n'est pas vide
        parts << current_part unless current_part.empty?

        parts
      end

      # Parses a rank (sequence of cells)
      #
      # @param str [String] FEEN rank string
      # @return [Array] Array of cells (nil for empty, hash for piece)
      def self.parse_rank(str)
        return [] if str.nil? || str.empty?

        cells = []
        i = 0

        while i < str.length
          char = str[i]

          if char.match?(/[1-9]/)
            # Handle empty cells (digits represent consecutive empty squares)
            empty_count = EMPTY_STRING
            while i < str.length && str[i].match?(/[0-9]/)
              empty_count += str[i]
              i += 1
            end

            empty_count.to_i.times { cells << nil }
          else
            # Handle pieces
            piece = {}

            # Check for prefix
            if char == PREFIX_PROMOTION
              piece[:prefix] = PREFIX_PROMOTION
              i += 1

              # Ensure there's a piece identifier after the prefix
              raise ArgumentError, ERRORS[:invalid_prefix] if i >= str.length || !str[i].match?(/[a-zA-Z]/)

              char = str[i]
            end

            # Get the piece identifier
            raise ArgumentError, format(ERRORS[:invalid_piece], i, char) unless char.match?(/[a-zA-Z]/)

            piece[:id] = char
            i += 1

            # Check for suffix
            if i < str.length && VALID_SUFFIXES.include?(str[i])
              piece[:suffix] = str[i]
              i += 1
            end

            cells << piece

          end
        end

        cells
      end
    end
  end
end
