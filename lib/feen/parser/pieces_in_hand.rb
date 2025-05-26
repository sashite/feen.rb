# frozen_string_literal: true

require_relative File.join("pieces_in_hand", "errors")
require_relative File.join("pieces_in_hand", "no_pieces")
require_relative File.join("pieces_in_hand", "pnn_patterns")
require_relative File.join("pieces_in_hand", "canonical_sorter")

module Feen
  module Parser
    # Handles parsing of the pieces in hand section of a FEEN string.
    # Pieces in hand represent pieces available for dropping onto the board.
    # This implementation supports full PNN notation including prefixes and suffixes.
    module PiecesInHand
      # Parses the pieces in hand section of a FEEN string.
      #
      # @param pieces_in_hand_str [String] FEEN pieces in hand string
      # @return [Array<String>] Array of piece identifiers in full PNN format,
      #   expanded based on their counts and sorted according to FEEN specification:
      #   1. By quantity (descending)
      #   2. By complete PNN representation (alphabetically ascending)
      #   Empty array if no pieces are in hand.
      # @raise [ArgumentError] If the input string is invalid
      #
      # @example Parse no pieces in hand
      #   PiecesInHand.parse("-")
      #   # => []
      #
      # @example Parse pieces with modifiers
      #   PiecesInHand.parse("3+P2B'Pn")
      #   # => ["+P", "+P", "+P", "B'", "B'", "P", "n"]
      #
      # @example Parse complex pieces with counts and modifiers
      #   PiecesInHand.parse("10P5K3B2p'+P-pBRbq")
      #   # => ["P", "P", "P", "P", "P", "P", "P", "P", "P", "P",
      #   #     "K", "K", "K", "K", "K",
      #   #     "B", "B", "B",
      #   #     "p'", "p'",
      #   #     "+P", "-p", "B", "R", "b", "q"]
      def self.parse(pieces_in_hand_str)
        # Validate input
        validate_input_type(pieces_in_hand_str)
        validate_format(pieces_in_hand_str)

        # Handle the no-pieces case early
        return [] if pieces_in_hand_str == NoPieces

        # Extract pieces with their counts and validate the format
        pieces_with_counts = extract_pieces_with_counts(pieces_in_hand_str)

        # Validate canonical ordering according to FEEN specification
        validate_canonical_order(pieces_with_counts)

        # Expand the pieces into an array maintaining the canonical order
        expand_pieces(pieces_with_counts)
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
      # This includes validation of individual PNN pieces and overall structure.
      #
      # @param str [String] Input string to validate
      # @raise [ArgumentError] If format is invalid
      # @return [void]
      private_class_method def self.validate_format(str)
        return if str == NoPieces

        # First, validate overall structure using the updated pattern
        raise ::ArgumentError, format(Errors[:invalid_format], str) unless str.match?(PnnPatterns::VALID_FORMAT_PATTERN)

        # Additional validation: ensure each piece component is valid PNN
        # This catches cases like "++P" that might pass the overall pattern
        validate_individual_pieces(str)
      end

      # Validates each individual piece in the string for PNN compliance
      #
      # @param str [String] FEEN pieces in hand string
      # @raise [ArgumentError] If any piece is invalid PNN format
      # @return [void]
      private_class_method def self.validate_individual_pieces(str)
        original_string = str
        position = 0

        while position < str.length
          match = str[position..].match(PnnPatterns::PIECE_WITH_COUNT_PATTERN)

          unless match
            # Find the problematic part
            remaining = str[position..]
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

          position += match[0].length
        end

        # Final check: verify that we can reconstruct the string correctly
        # by re-extracting all pieces and comparing with original
        reconstructed_pieces = extract_pieces_with_counts(original_string)
        reconstructed = reconstructed_pieces.map do |item|
          count = item[:count]
          piece = item[:piece]
          count == 1 ? piece : "#{count}#{piece}"
        end.join

        # If reconstruction doesn't match original, there's an invalid format
        return if reconstructed == original_string
        # Find the first discrepancy to provide better error message
        # This will catch cases like "++P" where we extract "+P" but original has extra "+"
        unless original_string.length > reconstructed.length
          raise ::ArgumentError, format(Errors[:invalid_format], original_string)
        end

        # There are extra characters - find what's invalid
        original_string.sub(reconstructed, "")
        # Try to identify the problematic piece
        problematic_part = find_problematic_piece(original_string, reconstructed)
        raise ::ArgumentError, format(Errors[:invalid_pnn_piece], problematic_part)
      end

      # Finds the problematic piece in the original string by comparing with reconstruction
      #
      # @param original [String] Original input string
      # @param reconstructed [String] Reconstructed string from extracted pieces
      # @return [String] The problematic piece or sequence
      private_class_method def self.find_problematic_piece(original, reconstructed)
        # Simple heuristic: find the first part that doesn't match
        min_length = [original.length, reconstructed.length].min

        # Find first difference
        diff_pos = 0
        diff_pos += 1 while diff_pos < min_length && original[diff_pos] == reconstructed[diff_pos]

        # If difference is at start, likely extra prefix
        # Look for a sequence that starts with invalid pattern like "++"
        if (diff_pos == 0) && original.match?(/\A\+\+/)
          return "++P" # Common case
        end

        # Extract a reasonable chunk around the problematic area
        start_pos = [0, diff_pos - 2].max
        end_pos = [original.length, diff_pos + 4].min
        original[start_pos...end_pos]
      end

      # Extracts pieces with their counts from the FEEN string.
      # Supports full PNN notation including prefixes and suffixes.
      #
      # @param str [String] FEEN pieces in hand string
      # @return [Array<Hash>] Array of hashes with :piece and :count keys
      private_class_method def self.extract_pieces_with_counts(str)
        result = []
        position = 0

        while position < str.length
          match = str[position..].match(PnnPatterns::PIECE_WITH_COUNT_PATTERN)
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

      # Validates that pieces are in canonical order according to FEEN specification:
      # 1. By quantity (descending)
      # 2. By complete PNN representation (alphabetically ascending)
      #
      # @param pieces_with_counts [Array<Hash>] Array of pieces with their counts
      # @raise [ArgumentError] If pieces are not in canonical order
      # @return [void]
      private_class_method def self.validate_canonical_order(pieces_with_counts)
        return if pieces_with_counts.size <= 1

        CanonicalSorter.validate_order(pieces_with_counts)
      end

      # Expands the pieces based on their counts into an array.
      # Maintains the canonical ordering from the input.
      #
      # @param pieces_with_counts [Array<Hash>] Array of pieces with their counts
      # @return [Array<String>] Array of expanded pieces in canonical order
      private_class_method def self.expand_pieces(pieces_with_counts)
        pieces_with_counts.flat_map do |item|
          Array.new(item[:count], item[:piece])
        end
      end
    end
  end
end
