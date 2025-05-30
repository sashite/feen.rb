# frozen_string_literal: true

module Feen
  module Parser
    # Handles parsing of the piece placement section of a FEEN string
    module PiecePlacement
      # Simplified error messages
      ERRORS = {
        invalid_type:   "Piece placement must be a string, got %s",
        empty_string:   "Piece placement string cannot be empty",
        invalid_format: "Invalid piece placement format"
      }.freeze

      # Dimension separator character
      DIMENSION_SEPARATOR = "/"

      # Parses the piece placement section of a FEEN string
      #
      # @param piece_placement_str [String] FEEN piece placement string
      # @return [Array] Hierarchical array structure representing the board where:
      #   - Empty squares are represented by empty strings ("")
      #   - Pieces are represented by strings containing their identifier and optional modifiers
      # @raise [ArgumentError] If the input string is invalid
      def self.parse(piece_placement_str)
        validate_input(piece_placement_str)
        parse_structure(piece_placement_str)
      end

      # Validates the input string for basic requirements
      #
      # @param str [String] Input string to validate
      # @raise [ArgumentError] If the string is invalid
      # @return [void]
      def self.validate_input(str)
        raise ArgumentError, format(ERRORS[:invalid_type], str.class) unless str.is_a?(String)
        raise ArgumentError, ERRORS[:empty_string] if str.empty?

        # Basic format validation
        return if str.match?(%r{\A[a-zA-Z0-9+\-'/]+\z})

        raise ArgumentError, ERRORS[:invalid_format]
      end

      # Parses the structure recursively
      #
      # @param str [String] FEEN piece placement string
      # @return [Array] Parsed structure
      def self.parse_structure(str)
        # Handle trailing separators
        raise ArgumentError, ERRORS[:invalid_format] if str.end_with?(DIMENSION_SEPARATOR)

        # Find the longest separator sequence to determine dimension depth
        separators = str.scan(%r{/+}).uniq.sort_by(&:length).reverse

        return parse_rank(str) if separators.empty?

        # Use the longest separator to split at the highest dimension
        main_separator = separators.first
        parts = smart_split(str, main_separator)

        # Recursively parse each part
        parts.map { |part| parse_structure(part) }
      end

      # Splits string by separator while preserving shorter separators
      #
      # @param str [String] String to split
      # @param separator [String] Separator to split by
      # @return [Array<String>] Split parts
      def self.smart_split(str, separator)
        return [str] unless str.include?(separator)

        parts = str.split(separator)
        parts.reject(&:empty?)
      end

      # Parses a rank (sequence of cells)
      #
      # @param str [String] FEEN rank string
      # @return [Array] Array of cells
      def self.parse_rank(str)
        return [] if str.empty?

        cells = []
        i = 0

        while i < str.length
          char = str[i]

          case char
          when /[1-9]/
            # Parse number for empty cells
            number_str = ""
            while i < str.length && str[i].match?(/[0-9]/)
              number_str += str[i]
              i += 1
            end

            # Add empty cells
            empty_count = number_str.to_i
            cells.concat(Array.new(empty_count, ""))
          when /[a-zA-Z+\-']/
            # Parse piece
            piece = extract_piece(str, i)
            cells << piece[:piece]
            i = piece[:next_index]
          else
            raise ArgumentError, ERRORS[:invalid_format]
          end
        end

        cells
      end

      # Extracts a piece starting at given position
      #
      # @param str [String] String to parse
      # @param start_index [Integer] Starting position
      # @return [Hash] Hash with :piece and :next_index keys
      def self.extract_piece(str, start_index)
        piece = ""
        i = start_index

        # Optional prefix
        if i < str.length && ["+", "-"].include?(str[i])
          piece += str[i]
          i += 1
        end

        # Required letter
        raise ArgumentError, ERRORS[:invalid_format] unless i < str.length && str[i].match?(/[a-zA-Z]/)

        piece += str[i]
        i += 1

        # Optional suffix
        if i < str.length && str[i] == "'"
          piece += str[i]
          i += 1
        end

        { piece: piece, next_index: i }
      end
    end
  end
end
