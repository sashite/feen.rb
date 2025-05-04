# frozen_string_literal: true

require_relative File.join("piece_placement", "shape_validator")
require_relative File.join("piece_placement", "shape_detector")

module Feen
  module Parser
    # Handles parsing of the piece placement section of a FEEN string
    module PiecePlacement
      # Error messages
      ERRORS = {
        invalid_type:       "Piece placement must be a string, got %s",
        empty_string:       "Piece placement string cannot be empty",
        invalid_format:     "Invalid piece placement format",
        invalid_prefix:     "Expected piece identifier after prefix",
        invalid_piece:      "Invalid piece identifier at position %d: %s",
        trailing_separator: "Unexpected separator at the end of string or dimension group"
      }.freeze

      # Empty string for initialization
      EMPTY_STRING = ""

      # Dimension separator character
      DIMENSION_SEPARATOR = "/"

      # Piece prefixes
      PREFIX_PROMOTION = "+"
      PREFIX_DIMINISHED = "-"
      VALID_PREFIXES = [PREFIX_PROMOTION, PREFIX_DIMINISHED].freeze

      # Valid piece suffixes
      SUFFIX_EQUALS = "="
      SUFFIX_LEFT = "<"
      SUFFIX_RIGHT = ">"
      VALID_SUFFIXES = [SUFFIX_EQUALS, SUFFIX_LEFT, SUFFIX_RIGHT].freeze

      # Build validation pattern step by step to match BNF
      # <letter> ::= <letter-lowercase> | <letter-uppercase>
      LETTER = "[a-zA-Z]"

      # <prefix> ::= "+" | "-"
      PREFIX = "[+-]"

      # <suffix> ::= "=" | "<" | ">"
      SUFFIX = "[=<>]"

      # <piece> ::= <letter> | <prefix> <letter> | <letter> <suffix> | <prefix> <letter> <suffix>
      PIECE = "(?:#{PREFIX}?#{LETTER}#{SUFFIX}?)"

      # <number> ::= <non-zero-digit> | <non-zero-digit> <digits>
      NUMBER = "[1-9][0-9]*"

      # <cell> ::= <piece> | <number>
      CELL = "(?:#{PIECE}|#{NUMBER})"

      # <rank> ::= <cell> | <cell> <rank>
      RANK = "#{CELL}+"

      # <dim-separator> ::= <slash> <separator-tail>
      # <separator-tail> ::= "" | <slash> <separator-tail>
      # This creates patterns like /, //, ///, etc.
      DIM_SEPARATOR = "/+"

      # <dim-element> ::= <dim-group> | <rank>
      # <dim-group> ::= <dim-element> | <dim-element> <dim-separator> <dim-group>
      # <piece-placement> ::= <dim-group>
      # This recursive pattern matches: rank or rank/rank or rank//rank, etc.
      VALID_PIECE_PLACEMENT_PATTERN = /\A#{RANK}(?:#{DIM_SEPARATOR}#{RANK})*\z/

      # Parses the piece placement section of a FEEN string
      #
      # @param piece_placement_str [String] FEEN piece placement string
      # @return [Array] Hierarchical array structure representing the board
      # @raise [ArgumentError] If the input string is invalid
      def self.parse(piece_placement_str)
        validate_all(piece_placement_str)

        # Parse the structure
        separator_types = find_separator_types(piece_placement_str)
        parsed_structure = if separator_types.empty?
                             parse_rank(piece_placement_str)
                           else
                             parse_dimension_group(piece_placement_str)
                           end

        # Validate the shape of the parsed structure
        ShapeValidator.validate_shape(parsed_structure)

        parsed_structure
      end

      # Validates all preconditions before parsing
      #
      # @param str [String] FEEN piece placement string
      # @raise [ArgumentError] If any validation fails
      # @return [void]
      private_class_method def self.validate_all(str)
        validate_piece_placement_string(str)
        validate_no_trailing_separator(str)
      end

      # Validates the piece placement string for basic syntax
      #
      # @param str [String] FEEN piece placement string
      # @raise [ArgumentError] If the string is invalid
      # @return [void]
      private_class_method def self.validate_piece_placement_string(str)
        raise ::ArgumentError, format(ERRORS[:invalid_type], str.class) unless str.is_a?(::String)
        raise ::ArgumentError, ERRORS[:empty_string] if str.empty?
        raise ::ArgumentError, ERRORS[:invalid_format] unless str.match?(VALID_PIECE_PLACEMENT_PATTERN)
      end

      # Validates that the string has no trailing separator
      #
      # @param str [String] FEEN piece placement string
      # @raise [ArgumentError] If trailing separator is found
      # @return [void]
      private_class_method def self.validate_no_trailing_separator(str)
        raise ::ArgumentError, ERRORS[:trailing_separator] if str.end_with?(DIMENSION_SEPARATOR)
      end

      # Finds all separator types present in the string (e.g., /, //, ///)
      #
      # @param str [String] FEEN dimension group string
      # @return [Array<Integer>] Sorted array of separator depths (1 for /, 2 for //, etc.)
      private_class_method def self.find_separator_types(str)
        separators = str.scan(%r{/+})
        return [] if separators.empty?

        separators.map(&:length).uniq.sort
      end

      # Recursively parses a dimension group using functional approach
      #
      # @param str [String] FEEN dimension group string
      # @return [Array] Hierarchical array structure representing the dimension group
      private_class_method def self.parse_dimension_group(str)
        validate_no_trailing_separator(str)

        separator_types = find_separator_types(str)
        return parse_rank(str) if separator_types.empty?

        max_depth = separator_types.fetch(-1)
        separator = DIMENSION_SEPARATOR * max_depth

        parts = split_by_separator(str, separator)

        parts.map do |part|
          validate_no_trailing_separator(part)
          max_depth == 1 ? parse_rank(part) : parse_dimension_group(part)
        end
      end

      # Splits a string by a given separator using functional approach
      #
      # @param str [String] String to split
      # @param separator [String] Separator to split by (e.g., "/", "//")
      # @return [Array<String>] Array of split parts
      private_class_method def self.split_by_separator(str, separator)
        return [str] unless str.include?(separator)

        split_recursive(str, separator)
      end

      # Recursively splits a string by separator
      #
      # @param str [String] String to process
      # @param separator [String] Target separator
      # @param index [Integer] Current position in string
      # @param current_part [String] Current part being built
      # @param parts [Array<String>] Accumulated parts
      # @return [Array<String>] Split parts
      private_class_method def self.split_recursive(str, separator, index = 0, current_part = "", parts = [])
        return parts + [current_part] if index >= str.length
        return parts if index >= str.length && current_part.empty?

        if str[index] == DIMENSION_SEPARATOR && can_match_separator?(str, index, separator)
          new_parts = current_part.empty? ? parts : parts + [current_part]
          split_recursive(str, separator, index + separator.length, "", new_parts)
        else
          next_separator_end = find_next_separator_end(str, index)
          new_part = current_part + str[index...next_separator_end]
          split_recursive(str, separator, next_separator_end, new_part, parts)
        end
      end

      # Checks if a separator can be matched at the given position
      #
      # @param str [String] String to check
      # @param index [Integer] Starting position
      # @param separator [String] Separator to match
      # @return [Boolean] True if separator matches
      private_class_method def self.can_match_separator?(str, index, separator)
        index <= str.length - separator.length && str[index, separator.length] == separator
      end

      # Finds the end of the next separator sequence
      #
      # @param str [String] String to search
      # @param start_index [Integer] Starting position
      # @return [Integer] End position of separator sequence
      private_class_method def self.find_next_separator_end(str, start_index)
        return start_index + 1 unless str[start_index] == DIMENSION_SEPARATOR

        end_index = start_index
        end_index += 1 while end_index < str.length && str[end_index] == DIMENSION_SEPARATOR
        end_index
      end

      # Parses a rank using functional approach
      #
      # @param str [String] FEEN rank string
      # @return [Array] Array of cells (nil for empty, hash for piece)
      private_class_method def self.parse_rank(str)
        return [] if str.nil? || str.empty?

        parse_rank_recursive(str)
      end

      # Recursively parses a rank
      #
      # @param str [String] Remaining rank string
      # @param index [Integer] Current position
      # @param cells [Array] Accumulated cells
      # @return [Array] Parsed cells
      private_class_method def self.parse_rank_recursive(str, index = 0, cells = [])
        return cells if index >= str.length

        char = str[index]

        if char.match?(/[1-9]/)
          empty_count_data = extract_empty_count(str, index)
          new_cells = cells + ::Array.new(empty_count_data[:count], nil)
          parse_rank_recursive(str, empty_count_data[:next_index], new_cells)
        else
          piece_data = extract_piece(str, index)
          new_cells = cells + [piece_data[:piece]]
          parse_rank_recursive(str, piece_data[:next_index], new_cells)
        end
      end

      # Extracts empty cell count from string
      #
      # @param str [String] Rank string
      # @param start_index [Integer] Starting position
      # @return [Hash] Count and next index
      private_class_method def self.extract_empty_count(str, start_index)
        count_str = extract_consecutive_digits(str, start_index)
        {
          count:      count_str.to_i,
          next_index: start_index + count_str.length
        }
      end

      # Extracts consecutive digits from string
      #
      # @param str [String] String to search
      # @param start_index [Integer] Starting position
      # @return [String] Extracted digits
      private_class_method def self.extract_consecutive_digits(str, start_index)
        end_index = start_index
        end_index += 1 while end_index < str.length && str[end_index].match?(/[0-9]/)
        str[start_index...end_index]
      end

      # Extracts a piece from the string
      #
      # @param str [String] Rank string
      # @param start_index [Integer] Starting position
      # @return [Hash] Piece hash and next index
      private_class_method def self.extract_piece(str, start_index)
        piece = {}
        current_index = start_index
        char = str[current_index]

        # Check for prefix
        if VALID_PREFIXES.include?(char)
          piece[:prefix] = char
          current_index += 1

          # Ensure there's a piece identifier after the prefix
          if current_index >= str.length || !str[current_index].match?(/[a-zA-Z]/)
            raise ::ArgumentError, ERRORS[:invalid_prefix]
          end

          char = str[current_index]
        end

        # Get the piece identifier
        raise ::ArgumentError, format(ERRORS[:invalid_piece], current_index, char) unless char.match?(/[a-zA-Z]/)

        piece[:id] = char
        current_index += 1

        # Check for suffix
        if current_index < str.length && VALID_SUFFIXES.include?(str[current_index])
          piece[:suffix] = str[current_index]
          current_index += 1
        end

        {
          piece:      piece,
          next_index: current_index
        }
      end
    end
  end
end
