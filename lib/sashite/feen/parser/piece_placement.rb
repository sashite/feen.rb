# frozen_string_literal: true

require_relative "../error"
require_relative "../placement"

require "sashite/epin"

module Sashite
  module Feen
    module Parser
      # Parser for the piece placement field (first field of FEEN).
      #
      # Converts a FEEN piece placement string into a Placement object,
      # decoding board configuration from EPIN notation with:
      # - Empty square compression (numbers → consecutive nils)
      # - Multi-dimensional separator preservation (exact "/" counts)
      # - Support for any irregular board structure
      #
      # The parser preserves the exact separator structure, enabling
      # perfect round-trip conversion (parse → dump → parse).
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      module PiecePlacement
        # Rank separator character.
        RANK_SEPARATOR = "/"

        # Parse a FEEN piece placement string into a Placement object.
        #
        # Supports any valid FEEN structure:
        # - 1D: Single rank, no separators (e.g., "K2P")
        # - 2D: Ranks separated by "/" (e.g., "8/8/8")
        # - 3D+: Ranks separated by multiple "/" (e.g., "5/5//5/5")
        # - Irregular: Any combination of rank sizes and separators
        #
        # @param string [String] FEEN piece placement field string
        # @return [Placement] Parsed placement object
        # @raise [Error::Syntax] If placement format is invalid
        # @raise [Error::Piece] If EPIN notation is invalid
        #
        # @example Chess starting position
        #   parse("+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R")
        #
        # @example Empty 8x8 board
        #   parse("8/8/8/8/8/8/8/8")
        #
        # @example 1D board
        #   parse("K2P3k")
        #
        # @example Irregular structure
        #   parse("99999/3///K/k//r")
        def self.parse(string)
          # Detect dimension before parsing
          dimension = detect_dimension(string)

          # Handle 1D case (no separators)
          if dimension == 1
            rank = parse_rank(string)
            return Placement.new([rank], [], 1)
          end

          # Parse multi-dimensional structure with separators
          ranks, separators = parse_with_separators(string)

          Placement.new(ranks, separators, dimension)
        end

        # Detect board dimensionality from separator patterns.
        #
        # Scans for consecutive "/" characters and returns:
        #   1 + (maximum consecutive "/" count)
        #
        # @param string [String] Piece placement string
        # @return [Integer] Board dimension (minimum 1)
        #
        # @example 1D board (no separators)
        #   detect_dimension("K2P")  # => 1
        #
        # @example 2D board (single "/")
        #   detect_dimension("8/8")  # => 2
        #
        # @example 3D board (contains "//")
        #   detect_dimension("5/5/5//5/5/5")  # => 3
        #
        # @example 4D board (contains "///")
        #   detect_dimension("2/2///2/2")  # => 4
        private_class_method def self.detect_dimension(string)
          return 1 unless string.include?(RANK_SEPARATOR)

          max_consecutive = string.scan(%r{/+}).map(&:length).max || 0
          max_consecutive + 1
        end

        # Parse string while preserving exact separators.
        #
        # Uses split with capture group to preserve both ranks and separators.
        # The regex /(\/+)/ captures one or more consecutive "/" characters.
        #
        # Result pattern: [rank, separator, rank, separator, ..., rank]
        # - Even indices (0, 2, 4, ...) are ranks
        # - Odd indices (1, 3, 5, ...) are separators
        #
        # Empty strings are parsed as empty ranks (valid in FEEN).
        #
        # @param string [String] Piece placement string
        # @return [Array<Array<Array>, Array<String>>] [ranks, separators]
        #
        # @example Simple split
        #   parse_with_separators("K/Q/R")
        #   # => [[[K], [Q], [R]], ["/", "/"]]
        #
        # @example Multi-dimensional split
        #   parse_with_separators("K//Q/R")
        #   # => [[[K], [Q], [R]], ["//", "/"]]
        #
        # @example Trailing separator (empty rank at end)
        #   parse_with_separators("K///")
        #   # => [[[K], []], ["///"]]
        #
        # @example Leading separator (empty rank at start)
        #   parse_with_separators("///K")
        #   # => [[[], [K]], ["///"]]
        private_class_method def self.parse_with_separators(string)
          ranks = []
          separators = []

          # Split with capture group to preserve separators
          # Use limit=-1 to include trailing empty substrings
          parts = string.split(%r{(/+)}, -1)

          parts.each_with_index do |part, idx|
            if idx.even?
              # Even index = rank content (can be empty string)
              ranks << parse_rank(part)
            else
              # Odd index = separator
              separators << part
            end
          end

          [ranks, separators]
        end

        # Parse a single rank string into an array of pieces and nils.
        #
        # Processes rank content character by character:
        # - Empty string → empty rank (empty array)
        # - Digits (1-9) start a number → count of empty squares (nils)
        # - Letters (A-Z, a-z) start EPIN → piece object
        # - Numbers are parsed greedily (123 = one hundred twenty-three)
        #
        # @param rank_str [String] Single rank string (e.g., "rnbqkbnr" or "4p3" or "")
        # @return [Array] Array containing piece objects and nils (empty if rank_str is empty)
        # @raise [Error::Syntax] If rank format is invalid
        # @raise [Error::Piece] If EPIN notation is invalid
        #
        # @example Empty rank
        #   parse_rank("")
        #   # => []
        #
        # @example Rank with only pieces
        #   parse_rank("rnbqkbnr")
        #   # => [r, n, b, q, k, b, n, r]
        #
        # @example Rank with empty squares
        #   parse_rank("4p3")
        #   # => [nil, nil, nil, nil, p, nil, nil, nil]
        #
        # @example Rank with large empty count
        #   parse_rank("100")
        #   # => [nil, nil, ..., nil] (100 nils)
        #
        # @example Mixed rank
        #   parse_rank("+K2+Q")
        #   # => [+K, nil, nil, +Q]
        private_class_method def self.parse_rank(rank_str)
          # Handle empty rank (valid in FEEN)
          return [] if rank_str.empty?

          result = []
          chars = rank_str.chars
          i = 0

          while i < chars.size
            char = chars[i]

            if digit?(char)
              # Parse complete number (greedy)
              num_str, consumed = extract_number(chars, i)
              count = num_str.to_i

              validate_empty_count!(count, num_str)

              # Add empty squares
              count.times { result << nil }
              i += consumed
            else
              # Parse EPIN piece notation
              piece_str, consumed = extract_epin(chars, i)
              piece = parse_piece(piece_str)
              result << piece
              i += consumed
            end
          end

          result
        end

        # Check if character is a digit (1-9 for starting digit).
        #
        # Note: Leading zero not allowed in FEEN numbers.
        #
        # @param char [String] Single character
        # @return [Boolean] True if character is 1-9
        private_class_method def self.digit?(char)
          char >= "1" && char <= "9"
        end

        # Extract a complete number from character array (greedy parsing).
        #
        # Reads all consecutive digits starting from start_index.
        # First digit must be 1-9, subsequent digits can be 0-9.
        #
        # @param chars [Array<String>] Array of characters
        # @param start_index [Integer] Starting index
        # @return [Array(String, Integer)] Number string and characters consumed
        #
        # @example Single digit
        #   extract_number(['8', 'K'], 0)  # => ["8", 1]
        #
        # @example Multi-digit
        #   extract_number(['1', '2', '3', 'K'], 0)  # => ["123", 3]
        #
        # @example Large number
        #   extract_number(['9', '9', '9', '9', '9'], 0)  # => ["99999", 5]
        private_class_method def self.extract_number(chars, start_index)
          num_str = chars[start_index]
          i = start_index + 1

          # Continue reading digits (including 0)
          while i < chars.size && chars[i] >= "0" && chars[i] <= "9"
            num_str += chars[i]
            i += 1
          end

          consumed = i - start_index
          [num_str, consumed]
        end

        # Validate empty square count.
        #
        # Count must be at least 1 (FEEN doesn't allow "0" for zero squares).
        #
        # @param count [Integer] Parsed count value
        # @param count_str [String] Original string for error message
        # @raise [Error::Syntax] If count is less than 1
        private_class_method def self.validate_empty_count!(count, count_str)
          return if count >= 1

          raise ::Sashite::Feen::Error::Syntax,
                "Empty square count must be at least 1, got #{count_str}"
        end

        # Extract EPIN notation from character array.
        #
        # EPIN format: [state][letter][terminal][derivation]
        # - state: optional "+" or "-" prefix
        # - letter: required A-Z or a-z
        # - terminal: optional "^" suffix
        # - derivation: optional "'" suffix (comes after "^" if both are present)
        #
        # @param chars [Array<String>] Array of characters
        # @param start_index [Integer] Starting index
        # @return [Array(String, Integer)] EPIN string and characters consumed
        # @raise [Error::Syntax] If EPIN format is incomplete or invalid
        #
        # @example Simple piece
        #   extract_epin(['K', 'Q'], 0)  # => ["K", 1]
        #
        # @example Enhanced piece
        #   extract_epin(['+', 'R', 'B'], 0)  # => ["+R", 2]
        #
        # @example Foreign piece
        #   extract_epin(['K', "'", 'Q'], 0)  # => ["K'", 2]
        #
        # @example Terminal piece
        #   extract_epin(['K', '^', 'Q'], 0)  # => ["K^", 2]
        #
        # @example Foreign terminal piece
        #   extract_epin(['K', '^', "'", 'Q'], 0)  # => ["K^'", 3]
        #
        # @example Complex piece
        #   extract_epin(['-', 'p', "'", 'K'], 0)  # => ["-p'", 3]
        private_class_method def self.extract_epin(chars, start_index)
          i = start_index
          piece_chars = []

          # Optional state prefix (+ or -)
          if i < chars.size && ["+", "-"].include?(chars[i])
            piece_chars << chars[i]
            i += 1
          end

          # Base letter (required)
          if i >= chars.size || !letter?(chars[i])
            raise ::Sashite::Feen::Error::Syntax,
                  "Expected letter in EPIN notation at position #{start_index}"
          end

          piece_chars << chars[i]
          i += 1

          # Optional terminal suffix (^)
          if i < chars.size && chars[i] == "^"
            piece_chars << chars[i]
            i += 1
          end

          # Optional derivation suffix (')
          if i < chars.size && chars[i] == "'"
            piece_chars << chars[i]
            i += 1
          end

          piece_str = piece_chars.join
          consumed  = i - start_index

          [piece_str, consumed]
        end

        # Check if character is a letter.
        #
        # @param char [String] Single character
        # @return [Boolean] True if character is A-Z or a-z
        private_class_method def self.letter?(char)
          (char >= "A" && char <= "Z") || (char >= "a" && char <= "z")
        end

        # Parse EPIN string into a piece identifier object.
        #
        # Delegates to Sashite::Epin for actual parsing and validation.
        #
        # @param epin_str [String] EPIN notation string
        # @return [Object] Piece identifier object (Epin::Identifier)
        # @raise [Error::Piece] If EPIN is invalid or parsing fails
        #
        # @example Valid pieces
        #   parse_piece("K")     # => Epin::Identifier (King)
        #   parse_piece("+R")    # => Epin::Identifier (Enhanced Rook)
        #   parse_piece("-p'")   # => Epin::Identifier (Diminished foreign pawn)
        #
        # @example Invalid piece
        #   parse_piece("X#")    # => raises Error::Piece
        private_class_method def self.parse_piece(epin_str)
          # Pre-validate format
          unless ::Sashite::Epin.valid?(epin_str)
            raise ::Sashite::Feen::Error::Piece,
                  "Invalid EPIN notation: #{epin_str}"
          end

          # Parse using EPIN library
          ::Sashite::Epin.parse(epin_str)
        rescue ::StandardError => e
          raise ::Sashite::Feen::Error::Piece,
                "Failed to parse EPIN '#{epin_str}': #{e.message}"
        end
      end
    end
  end
end
