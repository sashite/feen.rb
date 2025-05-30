# frozen_string_literal: true

module Feen
  module Dumper
    # Handles conversion of piece placement data to FEEN notation string
    module PiecePlacement
      # Error messages
      ERRORS = {
        invalid_type:       "Piece placement must be an Array, got %s",
        inconsistent_shape: "Inconsistent dimension structure detected",
        invalid_cell:       "Invalid cell content: %s (must be String)"
      }.freeze

      # Converts a piece placement structure to a FEEN-compliant string
      #
      # @param piece_placement [Array] Hierarchical array representing the board where:
      #   - Empty squares are represented by empty strings ("")
      #   - Pieces are represented by strings (e.g., "r", "R", "+P", "K'")
      #   - Dimensions are represented by nested arrays
      # @return [String] FEEN piece placement string
      # @raise [ArgumentError] If the piece placement structure is invalid
      #
      # @example 2D chess board
      #   PiecePlacement.dump([
      #     ["r", "n", "b", "q", "k", "b", "n", "r"],
      #     ["p", "p", "p", "p", "p", "p", "p", "p"],
      #     ["", "", "", "", "", "", "", ""],
      #     ["", "", "", "", "", "", "", ""],
      #     ["", "", "", "", "", "", "", ""],
      #     ["", "", "", "", "", "", "", ""],
      #     ["P", "P", "P", "P", "P", "P", "P", "P"],
      #     ["R", "N", "B", "Q", "K", "B", "N", "R"]
      #   ])
      #   # => "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
      #
      # @example 3D board
      #   PiecePlacement.dump([
      #     [["r", "n"], ["p", "p"]],
      #     [["", ""], ["P", "P"]],
      #     [["R", "N"], ["", ""]]
      #   ])
      #   # => "rn/pp//2/PP//RN/2"
      def self.dump(piece_placement)
        validate_input(piece_placement)
        format_placement(piece_placement)
      end

      # Validates the input piece placement structure
      #
      # @param piece_placement [Object] Structure to validate
      # @raise [ArgumentError] If the structure is invalid
      # @return [void]
      private_class_method def self.validate_input(piece_placement)
        raise ArgumentError, format(ERRORS[:invalid_type], piece_placement.class) unless piece_placement.is_a?(Array)

        validate_structure_consistency(piece_placement)
      end

      # Validates that the structure is consistent (all dimensions have same size)
      #
      # @param structure [Array] Structure to validate
      # @raise [ArgumentError] If structure is inconsistent
      # @return [void]
      private_class_method def self.validate_structure_consistency(structure)
        return if structure.empty?

        # Check if this is a rank (array of strings) or multi-dimensional
        if structure.all?(String)
          # This is a rank - validate each cell
          structure.each_with_index do |cell, _index|
            raise ArgumentError, format(ERRORS[:invalid_cell], cell.inspect) unless cell.is_a?(String)
          end
        elsif structure.all?(Array)
          # This is multi-dimensional - check consistency and validate recursively
          structure.each do |element|
            # Recursively validate sub-structures
            validate_structure_consistency(element)
          end
        else
          # Mixed types - check for non-string elements in what should be a rank
          non_string_elements = structure.reject { |element| element.is_a?(String) }
          raise ArgumentError, ERRORS[:inconsistent_shape] unless non_string_elements.any?

          # If we have non-string elements, report the first one as invalid cell content
          first_invalid = non_string_elements.first
          raise ArgumentError, format(ERRORS[:invalid_cell], first_invalid.inspect)

          # This shouldn't happen, but keep the original error as fallback

        end
      end

      # Formats the piece placement structure into a FEEN string
      #
      # @param placement [Array] Piece placement structure
      # @return [String] FEEN piece placement string
      private_class_method def self.format_placement(placement)
        return "" if placement.empty?

        # Check if this is a rank (1D array of strings)
        return format_rank(placement) if placement.all?(String)

        # This is multi-dimensional - determine separator depth
        depth = calculate_depth(placement) - 1
        separator = "/" * depth

        # Format each sub-element and join
        placement.map { |element| format_placement(element) }.join(separator)
      end

      # Formats a rank (1D array of cells) into FEEN notation
      #
      # @param rank [Array<String>] 1D array of cells
      # @return [String] FEEN rank string
      private_class_method def self.format_rank(rank)
        return "" if rank.empty?

        result = ""
        empty_count = 0

        rank.each do |cell|
          if cell.empty?
            empty_count += 1
          else
            # Add accumulated empty squares count
            if empty_count.positive?
              result += empty_count.to_s
              empty_count = 0
            end

            # Add the piece
            result += cell
          end
        end

        # Add any trailing empty squares
        result += empty_count.to_s if empty_count.positive?

        result
      end

      # Calculates the depth of a nested array structure
      #
      # @param structure [Array] Structure to analyze
      # @return [Integer] Depth of the structure
      private_class_method def self.calculate_depth(structure)
        return 0 unless structure.is_a?(Array) && !structure.empty?

        if structure.first.is_a?(Array)
          1 + calculate_depth(structure.first)
        else
          1
        end
      end
    end
  end
end
