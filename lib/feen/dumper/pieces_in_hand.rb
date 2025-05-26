# frozen_string_literal: true

require_relative File.join("pieces_in_hand", "errors")

module Feen
  module Dumper
    # Handles conversion of pieces in hand data to FEEN notation string
    module PiecesInHand
      # Converts an array of piece identifiers to a FEEN-formatted pieces in hand string
      #
      # @param piece_chars [Array<String>] Array of piece identifiers (e.g., ["P", "p", "B", "B", "p", "+P"])
      # @return [String] FEEN-formatted pieces in hand string following the format:
      #   - Groups pieces by case: uppercase first, then lowercase, separated by "/"
      #   - Within each group, sorts by quantity (descending), then alphabetically (ascending)
      #   - Uses count notation for quantities > 1 (e.g., "3P" instead of "PPP")
      # @raise [ArgumentError] If any piece identifier is invalid
      # @example
      #   PiecesInHand.dump("P", "P", "P", "B", "B", "p", "p", "p", "p", "p")
      #   # => "3P2B/5p"
      #
      #   PiecesInHand.dump("p", "P", "B")
      #   # => "BP/p"
      #
      #   PiecesInHand.dump
      #   # => "/"
      def self.dump(*piece_chars)
        # Validate each piece character according to the FEEN specification
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
        uppercase_pieces = pieces.select { |piece| piece_is_uppercase?(piece) }
        lowercase_pieces = pieces.select { |piece| piece_is_lowercase?(piece) }

        [uppercase_pieces, lowercase_pieces]
      end

      # Determines if a piece belongs to the uppercase group
      # A piece is considered uppercase if its main letter is uppercase (ignoring prefixes/suffixes)
      #
      # @param piece [String] Piece identifier (e.g., "P", "+P", "P'", "+P'")
      # @return [Boolean] True if the piece's main letter is uppercase
      private_class_method def self.piece_is_uppercase?(piece)
        # Extract the main letter (skip prefixes like + or -)
        main_letter = piece.gsub(/\A[+-]/, "").gsub(/'\z/, "")
        main_letter.match?(/[A-Z]/)
      end

      # Determines if a piece belongs to the lowercase group
      # A piece is considered lowercase if its main letter is lowercase (ignoring prefixes/suffixes)
      #
      # @param piece [String] Piece identifier (e.g., "p", "+p", "p'", "+p'")
      # @return [Boolean] True if the piece's main letter is lowercase
      private_class_method def self.piece_is_lowercase?(piece)
        # Extract the main letter (skip prefixes like + or -)
        main_letter = piece.gsub(/\A[+-]/, "").gsub(/'\z/, "")
        main_letter.match?(/[a-z]/)
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

      # Validates all piece characters according to FEEN specification
      #
      # @param piece_chars [Array<Object>] Array of piece character candidates
      # @return [Array<String>] Array of validated piece characters
      # @raise [ArgumentError] If any piece character is invalid
      private_class_method def self.validate_piece_chars(piece_chars)
        piece_chars.each_with_index.map do |char, index|
          validate_piece_char(char, index)
        end
      end

      # Validates a single piece character according to FEEN specification
      # Supports full PNN notation: [prefix]letter[suffix] where:
      # - prefix can be "+" or "-"
      # - letter must be a-z or A-Z
      # - suffix can be "'"
      #
      # @param char [Object] Piece character candidate
      # @param index [Integer] Index of the character in the original array
      # @return [String] Validated piece character
      # @raise [ArgumentError] If the piece character is invalid
      private_class_method def self.validate_piece_char(char, index)
        # Validate type
        unless char.is_a?(::String)
          raise ::ArgumentError, format(
            Errors[:invalid_type],
            index: index,
            type:  char.class
          )
        end

        # Validate format using PNN pattern: [prefix]letter[suffix]
        # where prefix is +/-, letter is a-zA-Z, suffix is '
        unless char.match?(/\A[+-]?[a-zA-Z]'?\z/)
          raise ::ArgumentError, format(
            Errors[:invalid_format],
            index: index,
            value: char
          )
        end

        char
      end
    end
  end
end
