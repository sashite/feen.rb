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
      # decoding board configuration from EPIN notation with empty square
      # compression and multi-dimensional separator support.
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      module PiecePlacement
        # Rank separator for 2D boards.
        RANK_SEPARATOR = "/"

        # Pattern to match EPIN pieces (optional state prefix, letter, optional derivation suffix).
        EPIN_PATTERN = /\A[-+]?[A-Za-z]'?\z/

        # Parse a FEEN piece placement string into a Placement object.
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
        def self.parse(string)
          dimension = detect_dimension(string)
          rank_strings, section_sizes = split_ranks(string, dimension)
          ranks = rank_strings.map { |rank_str| parse_rank(rank_str) }

          Placement.new(ranks, dimension, section_sizes)
        end

        # Detect board dimensionality from separator patterns.
        #
        # Counts consecutive separators to determine dimension:
        # - "/" = 2D
        # - "//" = 3D
        # - "///" = 4D
        #
        # @param string [String] Piece placement string
        # @return [Integer] Board dimension (minimum 2)
        #
        # @example 2D board
        #   detect_dimension("8/8")  # => 2
        #
        # @example 3D board
        #   detect_dimension("5/5/5//5/5/5")  # => 3
        private_class_method def self.detect_dimension(string)
          max_consecutive = string.scan(/\/+/).map(&:length).max || 0
          max_consecutive + 1
        end

        # Split placement string into rank strings based on dimension.
        #
        # @param string [String] Piece placement string
        # @param dimension [Integer] Board dimensionality
        # @return [Array<String>, Array<Integer>] Array of rank strings and section sizes
        #
        # @example 1D board
        #   split_ranks("k+p4+PK", 1)  # => [["k+p4+PK"], nil]
        #
        # @example 2D board
        #   split_ranks("8/8/8", 2)  # => [["8", "8", "8"], nil]
        #
        # @example 3D board
        #   split_ranks("5/5//5/5", 3)  # => [["5", "5", "5", "5"], [2, 2]]
        private_class_method def self.split_ranks(string, dimension)
          if dimension == 1
            # 1D board: single rank, no separators
            [[string], nil]
          elsif dimension == 2
            # 2D board: split by single separator
            [string.split(RANK_SEPARATOR), nil]
          else
            # Multi-dimensional: split by dimension separator, track section sizes
            dimension_separator = RANK_SEPARATOR * (dimension - 1)
            sections = string.split(dimension_separator)

            # Each section contains ranks separated by single "/"
            section_sizes = []
            all_ranks = sections.flat_map do |section|
              ranks = section.split(RANK_SEPARATOR)
              section_sizes << ranks.size
              ranks
            end

            [all_ranks, section_sizes]
          end
        end

        # Parse a single rank string into an array of pieces and nils.
        #
        # @param rank_str [String] Single rank string (e.g., "rnbqkbnr" or "4p3")
        # @return [Array] Array containing piece objects and nils
        # @raise [Error::Syntax] If rank format is invalid
        # @raise [Error::Piece] If EPIN notation is invalid
        #
        # @example Rank with pieces
        #   parse_rank("rnbqkbnr")  # => [piece, piece, ..., piece]
        #
        # @example Rank with empty squares
        #   parse_rank("4p3")  # => [nil, nil, nil, nil, piece, nil, nil, nil]
        #
        # @example Rank with large empty count
        #   parse_rank("100")  # => [nil, nil, ..., nil] (100 times)
        private_class_method def self.parse_rank(rank_str)
          result = []
          chars = rank_str.chars
          i = 0

          while i < chars.size
            char = chars[i]

            # Skip whitespace and separators (commas)
            if char =~ /\s/ || char == ","
              i += 1
              next
            end

            # Dot represents single empty square (legacy support)
            if char == "."
              result << nil
              i += 1
              next
            end

            if first_digit?(char)
              # Empty squares - extract all consecutive digits
              count_str, consumed = extract_number(chars, i)
              count = count_str.to_i

              raise ::Sashite::Feen::Error::Syntax, "invalid empty square count: #{count_str}" if count < 1

              count.times { result << nil }
              i += consumed
            elsif char == "[" || letter?(char) || char == "+" || char == "-"
              # EPIN piece notation (bare or bracketed)
              piece_str, consumed = extract_epin(chars, i)
              piece = parse_piece(piece_str)
              result << piece
              i += consumed
            else
              # Invalid character
              raise ::Sashite::Feen::Error::Syntax,
                    "unexpected character #{char.inspect} at position #{i} in rank"
            end
          end

          result
        end

        # Extract a complete number (all consecutive digits) from character array.
        #
        # Implements greedy parsing: reads all consecutive digits until a non-digit
        # character is encountered.
        #
        # @param chars [Array<String>] Array of characters
        # @param start_index [Integer] Starting index
        # @return [Array(String, Integer)] Number string and number of characters consumed
        #
        # @example Single digit
        #   extract_number(['8', 'K'], 0)  # => ["8", 1]
        #
        # @example Multi-digit number
        #   extract_number(['1', '2', '3', 'K'], 0)  # => ["123", 3]
        #
        # @example Large number
        #   extract_number(['1', '0', '0', '/'], 0)  # => ["100", 3]
        private_class_method def self.extract_number(chars, start_index)
          i = start_index
          digits = []

          # First digit must be 1-9 (non-zero)
          if i < chars.size && first_digit?(chars[i])
            digits << chars[i]
            i += 1
          end

          # Subsequent digits can be 0-9
          while i < chars.size && any_digit?(chars[i])
            digits << chars[i]
            i += 1
          end

          number_str = digits.join
          consumed = i - start_index

          [number_str, consumed]
        end

        # Check if character is a non-zero digit (1-9).
        # Used for the first digit of a number.
        #
        # @param char [String] Single character
        # @return [Boolean] True if character is 1-9
        private_class_method def self.first_digit?(char)
          char >= "1" && char <= "9"
        end

        # Check if character is any digit (0-9).
        # Used for subsequent digits after the first.
        #
        # @param char [String] Single character
        # @return [Boolean] True if character is 0-9
        private_class_method def self.any_digit?(char)
          char >= "0" && char <= "9"
        end

        # Extract EPIN notation from character array.
        #
        # Handles state prefixes (+/-), base letter, and derivation suffix (').
        # Also supports bracketed EPIN notation for legacy compatibility.
        #
        # @param chars [Array<String>] Array of characters
        # @param start_index [Integer] Starting index
        # @return [Array(String, Integer)] EPIN string and number of characters consumed
        # @raise [Error::Syntax] If EPIN format is incomplete
        #
        # @example Simple piece
        #   extract_epin(['K', 'Q'], 0)  # => ["K", 1]
        #
        # @example Enhanced piece with derivation
        #   extract_epin(['+', 'R', "'", 'B'], 0)  # => ["+R'", 3]
        #
        # @example Bracketed piece (legacy)
        #   extract_epin(['[', 'K', ']', 'Q'], 0)  # => ["K", 3]
        private_class_method def self.extract_epin(chars, start_index)
          i = start_index

          # Check for bracketed EPIN (legacy support)
          if chars[i] == "["
            return extract_bracketed_epin(chars, start_index)
          end

          piece_chars = []

          # Optional state prefix
          if chars[i] == "+" || chars[i] == "-"
            piece_chars << chars[i]
            i += 1
          end

          # Base letter (required)
          if i >= chars.size || !letter?(chars[i])
            raise ::Sashite::Feen::Error::Syntax, "expected letter in EPIN notation at position #{start_index}"
          end

          piece_chars << chars[i]
          i += 1

          # Optional derivation suffix
          if i < chars.size && chars[i] == "'"
            piece_chars << chars[i]
            i += 1
          end

          piece_str = piece_chars.join
          consumed = i - start_index

          [piece_str, consumed]
        end

        # Extract bracketed EPIN notation (legacy support).
        #
        # Supports balanced brackets for complex piece identifiers.
        #
        # @param chars [Array<String>] Array of characters
        # @param start_index [Integer] Starting index (should point to '[')
        # @return [Array(String, Integer)] EPIN string (without brackets) and chars consumed
        # @raise [Error::Syntax] If brackets are unbalanced
        #
        # @example
        #   extract_bracketed_epin(['[', 'K', 'i', 'n', 'g', ']'], 0)  # => ["King", 6]
        private_class_method def self.extract_bracketed_epin(chars, start_index)
          i = start_index + 1  # Skip opening '['
          depth = 1
          content_chars = []

          while i < chars.size && depth.positive?
            case chars[i]
            when "["
              depth += 1
              content_chars << chars[i] if depth > 1
            when "]"
              depth -= 1
              content_chars << chars[i] if depth.positive?
            else
              content_chars << chars[i]
            end
            i += 1
          end

          if depth.positive?
            raise ::Sashite::Feen::Error::Syntax,
                  "unterminated bracket at position #{start_index}"
          end

          content = content_chars.join
          consumed = i - start_index

          [content, consumed]
        end

        # Check if character is a letter.
        #
        # @param char [String] Single character
        # @return [Boolean] True if character is A-Z or a-z
        private_class_method def self.letter?(char)
          (char >= "A" && char <= "Z") || (char >= "a" && char <= "z")
        end

        # Parse EPIN string into a piece object.
        #
        # @param epin_str [String] EPIN notation string
        # @return [Object] Piece identifier object
        # @raise [Error::Piece] If EPIN is invalid
        #
        # @example
        #   parse_piece("K")    # => Epin::Identifier
        #   parse_piece("+R'")  # => Epin::Identifier
        private_class_method def self.parse_piece(epin_str)
          unless EPIN_PATTERN.match?(epin_str)
            raise ::Sashite::Feen::Error::Piece, "invalid EPIN notation: #{epin_str}"
          end

          ::Sashite::Epin.parse(epin_str)
        rescue ::StandardError => e
          raise ::Sashite::Feen::Error::Piece, "failed to parse EPIN '#{epin_str}': #{e.message}"
        end
      end
    end
  end
end
