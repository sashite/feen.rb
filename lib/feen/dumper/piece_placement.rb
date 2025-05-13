# frozen_string_literal: true

module Feen
  module Dumper
    module PiecePlacement
      # Converts a piece placement structure to a FEEN-compliant string
      #
      # @param piece_placement [Array] Hierarchical array representing the board where:
      #   - Empty squares are represented by empty strings ("")
      #   - Pieces are represented by strings (e.g., "r", "R'", "+P")
      #   - Dimensions are represented by nested arrays
      # @return [String] FEEN piece placement string
      # @raise [ArgumentError] If the piece placement structure is invalid
      def self.dump(piece_placement)
        # Détecter la forme du tableau directement à partir de la structure
        detect_shape(piece_placement)

        # Formater directement la structure en chaîne FEEN
        format_placement(piece_placement)
      end

      # Detects the shape of the board based on the piece_placement structure
      #
      # @param piece_placement [Array] Hierarchical array structure representing the board
      # @return [Array<Integer>] Array of dimension sizes
      # @raise [ArgumentError] If the piece_placement structure is invalid
      def self.detect_shape(piece_placement)
        return [] if piece_placement.empty?

        dimensions = []
        current = piece_placement

        # Traverse the structure to determine shape
        while current.is_a?(Array) && !current.empty?
          dimensions << current.size

          # Check if all elements at this level have the same structure
          validate_dimension_uniformity(current)

          # Check if we've reached the leaf level (array of strings)
          break if current.first.is_a?(String) ||
                   (current.first.is_a?(Array) && current.first.empty?)

          current = current.first
        end

        dimensions
      end

      # Validates that all elements in a dimension have the same structure
      #
      # @param dimension [Array] Array of elements at a particular dimension level
      # @raise [ArgumentError] If elements have inconsistent structure
      def self.validate_dimension_uniformity(dimension)
        return if dimension.empty?

        first_type = dimension.first.class
        first_size = dimension.first.is_a?(Array) ? dimension.first.size : nil

        dimension.each do |element|
          unless element.class == first_type
            raise ArgumentError, "Inconsistent element types in dimension: #{first_type} vs #{element.class}"
          end

          if element.is_a?(Array) && element.size != first_size
            raise ArgumentError, "Inconsistent dimension sizes: expected #{first_size}, got #{element.size}"
          end
        end
      end

      # Formats the piece placement structure into a FEEN string
      #
      # @param placement [Array] Piece placement structure
      # @return [String] FEEN piece placement string
      def self.format_placement(placement)
        # For 1D arrays (ranks), format directly
        if !placement.is_a?(Array) ||
           (placement.is_a?(Array) && (placement.empty? || !placement.first.is_a?(Array)))
          return format_rank(placement)
        end

        # For 2D+ arrays, format each sub-element and join with appropriate separator
        depth = calculate_depth(placement) - 1
        separator = "/" * depth

        # Important: Ne pas inverser le tableau - nous voulons maintenir l'ordre original
        elements = placement
        elements.map { |element| format_placement(element) }.join(separator)
      end

      # Formats a rank (1D array of cells)
      #
      # @param rank [Array] 1D array of cells
      # @return [String] FEEN rank string
      def self.format_rank(rank)
        return "" if !rank.is_a?(Array) || rank.empty?

        result = ""
        empty_count = 0

        rank.each do |cell|
          if cell.empty?
            empty_count += 1
          else
            # Add accumulated empty squares
            result += empty_count.to_s if empty_count > 0
            empty_count = 0

            # Add the piece
            result += cell
          end
        end

        # Add any trailing empty squares
        result += empty_count.to_s if empty_count > 0

        result
      end

      # Calculates the depth of a nested structure
      #
      # @param structure [Array] Structure to analyze
      # @return [Integer] Depth of the structure
      def self.calculate_depth(structure)
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
