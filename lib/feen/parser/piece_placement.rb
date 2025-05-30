# frozen_string_literal: true

module Feen
  module Parser
    # Handles parsing of the piece placement section of a FEEN string
    #
    # This module is responsible for converting the first field of a FEEN string
    # (piece placement) into a hierarchical array structure representing the board.
    # It supports arbitrary dimensions and handles both pieces (with optional PNN modifiers)
    # and empty squares (represented by numbers).
    #
    # @see https://sashite.dev/documents/feen/1.0.0/ FEEN Specification
    # @see https://sashite.dev/documents/pnn/1.0.0/ PNN Specification
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
      # Converts a FEEN piece placement string into a hierarchical array structure
      # representing the board where empty squares are represented by empty strings
      # and pieces are represented by strings containing their PNN identifier and
      # optional modifiers.
      #
      # @param piece_placement_str [String] FEEN piece placement string
      # @return [Array] Hierarchical array structure representing the board where:
      #   - Empty squares are represented by empty strings ("")
      #   - Pieces are represented by strings containing their identifier and optional modifiers
      # @raise [ArgumentError] If the input string is invalid
      #
      # @example Parse a simple 2D chess position (initial position)
      #   PiecePlacement.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
      #   # => [
      #   #      ["r", "n", "b", "q", "k", "b", "n", "r"],
      #   #      ["p", "p", "p", "p", "p", "p", "p", "p"],
      #   #      ["", "", "", "", "", "", "", ""],
      #   #      ["", "", "", "", "", "", "", ""],
      #   #      ["", "", "", "", "", "", "", ""],
      #   #      ["", "", "", "", "", "", "", ""],
      #   #      ["P", "P", "P", "P", "P", "P", "P", "P"],
      #   #      ["R", "N", "B", "Q", "K", "B", "N", "R"]
      #   #    ]
      #
      # @example Parse a single rank with mixed pieces and empty squares
      #   PiecePlacement.parse("r2k1r")
      #   # => ["r", "", "", "k", "", "r"]
      #
      # @example Parse pieces with PNN modifiers (promoted pieces in Shogi)
      #   PiecePlacement.parse("+P+Bk")
      #   # => ["+P", "+B", "k"]
      #
      # @example Parse a 3D board structure (2 planes of 2x2)
      #   PiecePlacement.parse("rn/pp//RN/PP")
      #   # => [
      #   #      [["r", "n"], ["p", "p"]],
      #   #      [["R", "N"], ["P", "P"]]
      #   #    ]
      #
      # @example Parse complex Shogi position with promoted pieces
      #   PiecePlacement.parse("9/9/9/9/4+P4/9/5+B3/9/9")
      #   # => [
      #   #      ["", "", "", "", "", "", "", "", ""],
      #   #      ["", "", "", "", "", "", "", "", ""],
      #   #      ["", "", "", "", "", "", "", "", ""],
      #   #      ["", "", "", "", "", "", "", "", ""],
      #   #      ["", "", "", "", "+P", "", "", "", ""],
      #   #      ["", "", "", "", "", "", "", "", ""],
      #   #      ["", "", "", "", "", "+B", "", "", ""],
      #   #      ["", "", "", "", "", "", "", "", ""],
      #   #      ["", "", "", "", "", "", "", "", ""]
      #   #    ]
      #
      # @example Parse irregular board shapes (different rank sizes)
      #   PiecePlacement.parse("rnbqkbnr/ppppppp/8")
      #   # => [
      #   #      ["r", "n", "b", "q", "k", "b", "n", "r"],  # 8 cells
      #   #      ["p", "p", "p", "p", "p", "p", "p"],       # 7 cells
      #   #      ["", "", "", "", "", "", "", ""]           # 8 cells
      #   #    ]
      #
      # @example Parse large numbers of empty squares
      #   PiecePlacement.parse("15")
      #   # => ["", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]
      #
      # @example Parse pieces with all PNN modifier types
      #   PiecePlacement.parse("+P'-R'k")
      #   # => ["+P'", "-R'", "k"]
      #   # Where:
      #   # - "+P'" = enhanced state with intermediate suffix
      #   # - "-R'" = diminished state with intermediate suffix
      #   # - "k"   = base piece without modifiers
      def self.parse(piece_placement_str)
        validate_input(piece_placement_str)
        parse_structure(piece_placement_str)
      end

      # Validates the input string for basic requirements
      #
      # Ensures the input is a non-empty string containing only valid FEEN characters.
      # Valid characters include: letters (a-z, A-Z), digits (0-9), and modifiers (+, -, ').
      #
      # @param str [String] Input string to validate
      # @raise [ArgumentError] If the string is invalid
      # @return [void]
      #
      # @example Valid input
      #   validate_input("rnbqkbnr/pppppppp/8/8")
      #   # => (no error)
      #
      # @example Invalid input (empty string)
      #   validate_input("")
      #   # => ArgumentError: Piece placement string cannot be empty
      #
      # @example Invalid input (wrong type)
      #   validate_input(123)
      #   # => ArgumentError: Piece placement must be a string, got Integer
      def self.validate_input(str)
        raise ArgumentError, format(ERRORS[:invalid_type], str.class) unless str.is_a?(String)
        raise ArgumentError, ERRORS[:empty_string] if str.empty?

        # Basic format validation
        return if str.match?(%r{\A[a-zA-Z0-9+\-'/]+\z})

        raise ArgumentError, ERRORS[:invalid_format]
      end

      # Parses the structure recursively
      #
      # Determines the dimensionality of the board by analyzing separator patterns
      # and recursively parses nested structures. Uses the longest separator sequence
      # to determine the highest dimension level.
      #
      # @param str [String] FEEN piece placement string
      # @return [Array] Parsed structure (1D array for ranks, nested arrays for higher dimensions)
      #
      # @example 1D structure (single rank)
      #   parse_structure("rnbq")
      #   # => ["r", "n", "b", "q"]
      #
      # @example 2D structure (multiple ranks)
      #   parse_structure("rn/pq")
      #   # => [["r", "n"], ["p", "q"]]
      #
      # @example 3D structure (multiple planes)
      #   parse_structure("r/p//R/P")
      #   # => [[["r"], ["p"]], [["R"], ["P"]]]
      private_class_method def self.parse_structure(str)
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
      # Intelligently splits a string by a specific separator pattern while
      # ensuring that shorter separator patterns within the string are preserved
      # for recursive parsing of nested dimensions.
      #
      # @param str [String] String to split
      # @param separator [String] Separator to split by (e.g., "/", "//", "///")
      # @return [Array<String>] Split parts, with empty parts removed
      #
      # @example Split by single separator
      #   smart_split("a/b/c", "/")
      #   # => ["a", "b", "c"]
      #
      # @example Split by double separator, preserving single separators
      #   smart_split("a/b//c/d", "//")
      #   # => ["a/b", "c/d"]
      private_class_method def self.smart_split(str, separator)
        return [str] unless str.include?(separator)

        parts = str.split(separator)
        parts.reject(&:empty?)
      end

      # Parses a rank (sequence of cells)
      #
      # Processes a 1D sequence of cells, expanding numeric values to empty squares
      # and extracting pieces with their PNN modifiers. Numbers represent consecutive
      # empty squares, while letters (with optional modifiers) represent pieces.
      #
      # @param str [String] FEEN rank string
      # @return [Array<String>] Array of cells (empty strings for empty squares, piece strings for pieces)
      #
      # @example Simple pieces
      #   parse_rank("rnbq")
      #   # => ["r", "n", "b", "q"]
      #
      # @example Mixed pieces and empty squares
      #   parse_rank("r2k1r")
      #   # => ["r", "", "", "k", "", "r"]
      #
      # @example All empty squares
      #   parse_rank("8")
      #   # => ["", "", "", "", "", "", "", ""]
      #
      # @example Pieces with modifiers
      #   parse_rank("+P-R'")
      #   # => ["+P", "-R'"]
      private_class_method def self.parse_rank(str)
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
      # Parses a piece identifier with optional PNN modifiers starting at the specified
      # position in the string. Handles prefix modifiers (+, -), the required letter,
      # and suffix modifiers (').
      #
      # @param str [String] String to parse
      # @param start_index [Integer] Starting position in the string
      # @return [Hash] Hash with :piece and :next_index keys
      #   - :piece [String] The complete piece identifier with modifiers
      #   - :next_index [Integer] Position after the piece in the string
      #
      # @example Extract simple piece
      #   extract_piece("Kqr", 0)
      #   # => { piece: "K", next_index: 1 }
      #
      # @example Extract piece with prefix modifier
      #   extract_piece("+Pqr", 0)
      #   # => { piece: "+P", next_index: 2 }
      #
      # @example Extract piece with suffix modifier
      #   extract_piece("K'qr", 0)
      #   # => { piece: "K'", next_index: 2 }
      #
      # @example Extract piece with both prefix and suffix modifiers
      #   extract_piece("+P'qr", 0)
      #   # => { piece: "+P'", next_index: 3 }
      private_class_method def self.extract_piece(str, start_index)
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
