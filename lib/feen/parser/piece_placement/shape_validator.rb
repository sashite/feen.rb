# frozen_string_literal: true

module Feen
  module Parser
    module PiecePlacement
      # Validates shape uniformity for piece placement
      module ShapeValidator
        # Error messages for shape validation
        SHAPE_ERRORS = {
          inconsistent_rank_size:      "Inconsistent rank size: expected %d cells, got %d cells in rank '%s'",
          inconsistent_dimension_size: "Inconsistent dimension %d size: expected %d elements, got %d elements"
        }.freeze

        # Validates that the parsed structure has a consistent shape
        #
        # @param structure [Array] Parsed hierarchical structure
        # @raise [ArgumentError] If shape is inconsistent
        # @return [void]
        def self.validate_shape(structure)
          # Step 1: Determine the expected shape
          expected_shape = determine_shape(structure)

          # Step 2: Validate that each dimension strictly matches the expected shape
          validate_against_shape(structure, expected_shape)
        end

        # Determines the expected shape from the structure
        #
        # @param structure [Array] Parsed hierarchical structure
        # @return [Array<Integer>] Array of dimension sizes
        def self.determine_shape(structure)
          return [] unless structure.is_a?(::Array) && !structure.empty?

          # If it's a rank (array of cells), return its size
          return [structure.size] if is_rank?(structure)

          # Otherwise, get the size of this dimension and recurse
          current_size = structure.size
          sub_shape = determine_shape(structure.fetch(0))

          [current_size] + sub_shape
        end

        # Validates that the structure matches the expected shape
        #
        # @param structure [Array] Current structure level
        # @param expected_shape [Array<Integer>] Expected dimension sizes
        # @param depth [Integer] Current depth in the structure
        # @raise [ArgumentError] If shape doesn't match
        def self.validate_against_shape(structure, expected_shape, depth = 0)
          return if expected_shape.empty?

          expected_size = expected_shape.fetch(depth)

          # Handle rank validation
          if is_rank?(structure)
            actual_size = structure.size
            if actual_size != expected_size
              rank_str = rank_to_string(structure)
              raise ::ArgumentError, format(SHAPE_ERRORS[:inconsistent_rank_size],
                                            expected_size, actual_size, rank_str)
            end
            return
          end

          # Validate current dimension size
          actual_size = structure.size
          if actual_size != expected_size
            raise ::ArgumentError, format(SHAPE_ERRORS[:inconsistent_dimension_size],
                                          depth + 1, expected_size, actual_size)
          end

          # Recursively validate each sub-structure
          structure.each do |sub_structure|
            validate_against_shape(sub_structure, expected_shape, depth + 1)
          end
        end

        # Checks if a structure is a rank (array of cells)
        #
        # @param structure [Array] Structure to check
        # @return [Boolean] True if it's a rank
        def self.is_rank?(structure)
          structure.is_a?(::Array) &&
            (structure.empty? || structure.fetch(0).nil? || structure.fetch(0).is_a?(::Hash))
        end

        # Converts a rank back to string representation for error messages
        #
        # @param rank [Array] Rank array
        # @return [String] String representation
        def self.rank_to_string(rank)
          rank_to_string_recursive(rank)
        end

        # Recursively converts a rank to string representation
        #
        # @param remaining_cells [Array] Remaining cells to process
        # @param accumulated_result [String] Result accumulated so far
        # @param empty_count [Integer] Current count of consecutive empty cells
        # @return [String] String representation of the rank
        def self.rank_to_string_recursive(remaining_cells, accumulated_result = "", empty_count = 0)
          return accumulated_result + format_empty_count(empty_count) if remaining_cells.empty?

          current_cell = remaining_cells.fetch(0)
          rest_cells = remaining_cells.drop(1)

          if current_cell.nil?
            # Empty cell - increment counter
            rank_to_string_recursive(rest_cells, accumulated_result, empty_count + 1)
          else
            # Piece cell - format accumulated empty cells then the piece
            new_result = accumulated_result + format_empty_count(empty_count) + format_piece(current_cell)
            rank_to_string_recursive(rest_cells, new_result, 0)
          end
        end

        # Formats empty count for string representation
        #
        # @param count [Integer] Number of empty cells
        # @return [String] Formatted empty count (empty string if count is 0)
        def self.format_empty_count(count)
          count.zero? ? "" : count.to_s
        end

        # Formats a piece for string representation
        #
        # @param piece [Hash] Piece hash with optional prefix, id, and suffix
        # @return [String] Formatted piece string
        def self.format_piece(piece)
          result = ""
          result += piece[:prefix] if piece.key?(:prefix)
          result += piece.fetch(:id)
          result += piece[:suffix] if piece.key?(:suffix)
          result
        end
      end
    end
  end
end
