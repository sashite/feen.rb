# frozen_string_literal: true

require "pnn"

module Feen
  module Dumper
    # Handles conversion of pieces in hand data to FEEN notation string
    module PiecesInHand
      # Error messages for validation
      ERRORS = {
        invalid_type: "Piece at index %d must be a String, got %s",
        invalid_pnn:  "Piece at index %d must be valid PNN notation: '%s'"
      }.freeze

      # Converts an array of piece identifiers to a FEEN-formatted pieces in hand string
      #
      # @param piece_chars [Array<String>] Array of piece identifiers following PNN notation.
      #   May include modifiers (per FEEN v1.0.0 specification): prefixes (+, -) and suffixes (')
      # @return [String] FEEN-formatted pieces in hand string following the canonical sorting:
      #   - Groups pieces by case: uppercase first, then lowercase, separated by "/"
      #   - Within each group, sorts by quantity (descending), then base letter (ascending),
      #     then prefix (-, +, none), then suffix (none, ')
      #   - Uses count notation for quantities > 1 (e.g., "3P" instead of "PPP")
      # @raise [ArgumentError] If any piece identifier is invalid PNN notation
      #
      # @example Valid pieces in hand with modifiers
      #   PiecesInHand.dump("+B", "+B", "B", "B", "B", "B", "B", "K", "-P", "-P", "-P", "-P'", "+P'", "+P'", "+P'", "P", "P", "P", "P", "P", "P", "P", "P", "P", "R", "S", "S", "S'", "b", "p")
      #   # => "2+B5BK3-P-P'3+P'9PR2SS'/bp"
      #
      # @example Valid pieces in hand without modifiers
      #   PiecesInHand.dump("P", "P", "P", "B", "B", "p", "p", "p", "p", "p")
      #   # => "3P2B/5p"
      #
      # @example No pieces in hand
      #   PiecesInHand.dump()
      #   # => "/"
      def self.dump(*piece_chars)
        # Validate each piece character according to PNN specification
        validated_chars = validate_piece_chars(piece_chars)

        # Group pieces by case
        uppercase_pieces, lowercase_pieces = group_pieces_by_case(validated_chars)

        # Format each group according to FEEN canonical sorting specification
        uppercase_formatted = format_pieces_group(uppercase_pieces)
        lowercase_formatted = format_pieces_group(lowercase_pieces)

        # Combine with separator
        "#{uppercase_formatted}/#{lowercase_formatted}"
      end

      # Groups pieces by case (uppercase vs lowercase base letter)
      #
      # @param pieces [Array<String>] Array of validated piece identifiers
      # @return [Array<Array<String>, Array<String>>] Two arrays: [uppercase_pieces, lowercase_pieces]
      private_class_method def self.group_pieces_by_case(pieces)
        uppercase_pieces = pieces.select { |piece| extract_base_letter(piece).match?(/[A-Z]/) }
        lowercase_pieces = pieces.select { |piece| extract_base_letter(piece).match?(/[a-z]/) }

        [uppercase_pieces, lowercase_pieces]
      end

      # Formats a group of pieces according to FEEN canonical sorting specification
      #
      # Sorting algorithm (FEEN v1.0.0):
      # 1. By quantity (descending)
      # 2. By base letter (ascending)
      # 3. By prefix (-, +, none)
      # 4. By suffix (none, ')
      #
      # @param pieces [Array<String>] Array of pieces from the same case group
      # @return [String] Formatted string for this group (e.g., "2+B5BK3-P-P'3+P'9PR2SS'")
      private_class_method def self.format_pieces_group(pieces)
        return "" if pieces.empty?

        # Count occurrences of each unique piece (including modifiers)
        piece_counts = pieces.each_with_object(::Hash.new(0)) do |piece, counts|
          counts[piece] += 1
        end

        # Sort according to FEEN canonical sorting algorithm
        sorted_pieces = piece_counts.sort do |a, b|
          piece_a, count_a = a
          piece_b, count_b = b

          # Primary sort: by count (descending)
          count_comparison = count_b <=> count_a
          next count_comparison unless count_comparison.zero?

          # Secondary sort: by base letter (ascending)
          base_a = extract_base_letter(piece_a)
          base_b = extract_base_letter(piece_b)
          base_comparison = base_a <=> base_b
          next base_comparison unless base_comparison.zero?

          # Tertiary sort: by prefix (-, +, none)
          prefix_a = extract_prefix(piece_a)
          prefix_b = extract_prefix(piece_b)
          prefix_comparison = compare_prefixes(prefix_a, prefix_b)
          next prefix_comparison unless prefix_comparison.zero?

          # Quaternary sort: by suffix (none, ')
          suffix_a = extract_suffix(piece_a)
          suffix_b = extract_suffix(piece_b)
          compare_suffixes(suffix_a, suffix_b)
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

      # Extracts the base letter from a PNN piece identifier
      #
      # @param piece [String] PNN piece identifier (e.g., "+P'", "-R", "K")
      # @return [String] Base letter (e.g., "P", "R", "K")
      private_class_method def self.extract_base_letter(piece)
        piece.match(/[a-zA-Z]/)[0]
      end

      # Extracts the prefix from a PNN piece identifier
      #
      # @param piece [String] PNN piece identifier
      # @return [String, nil] Prefix ("+" or "-") or nil if no prefix
      private_class_method def self.extract_prefix(piece)
        match = piece.match(/\A([+-])/)
        match ? match[1] : nil
      end

      # Extracts the suffix from a PNN piece identifier
      #
      # @param piece [String] PNN piece identifier
      # @return [String, nil] Suffix ("'") or nil if no suffix
      private_class_method def self.extract_suffix(piece)
        piece.end_with?("'") ? "'" : nil
      end

      # Compares prefixes according to FEEN sorting order: -, +, none
      #
      # @param prefix_a [String, nil] First prefix
      # @param prefix_b [String, nil] Second prefix
      # @return [Integer] Comparison result (-1, 0, 1)
      private_class_method def self.compare_prefixes(prefix_a, prefix_b)
        prefix_order = { "-" => 0, "+" => 1, nil => 2 }
        prefix_order[prefix_a] <=> prefix_order[prefix_b]
      end

      # Compares suffixes according to FEEN sorting order: none, '
      #
      # @param suffix_a [String, nil] First suffix
      # @param suffix_b [String, nil] Second suffix
      # @return [Integer] Comparison result (-1, 0, 1)
      private_class_method def self.compare_suffixes(suffix_a, suffix_b)
        suffix_order = { nil => 0, "'" => 1 }
        suffix_order[suffix_a] <=> suffix_order[suffix_b]
      end

      # Validates all piece characters according to PNN specification
      #
      # @param piece_chars [Array<Object>] Array of piece character candidates
      # @return [Array<String>] Array of validated piece characters
      # @raise [ArgumentError] If any piece character is invalid PNN notation
      private_class_method def self.validate_piece_chars(piece_chars)
        piece_chars.each_with_index.map do |char, index|
          validate_piece_char(char, index)
        end
      end

      # Validates a single piece character according to PNN specification
      # Per FEEN v1.0.0: pieces in hand may include PNN modifiers (prefixes and suffixes)
      #
      # @param char [Object] Piece character candidate
      # @param index [Integer] Index of the character in the original array
      # @return [String] Validated piece character
      # @raise [ArgumentError] If the piece character is invalid PNN notation
      private_class_method def self.validate_piece_char(char, index)
        # Validate type
        raise ::ArgumentError, format(ERRORS[:invalid_type], index, char.class) unless char.is_a?(::String)

        # Validate PNN format using the PNN gem
        # @see https://rubygems.org/gems/pnn
        raise ::ArgumentError, format(ERRORS[:invalid_pnn], index, char) unless ::Pnn.valid?(char)

        char
      end
    end
  end
end
