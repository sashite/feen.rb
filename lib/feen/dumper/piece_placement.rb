# frozen_string_literal: true

module Feen
  module Dumper
    # Handles conversion of piece placement data structure to FEEN notation string
    module PiecePlacement
      # Error messages
      ERRORS = {
        empty_input: "Piece placement cannot be empty"
      }.freeze

      # Empty string for initialization
      EMPTY_STRING = ""

      # Dimension separator character
      DIMENSION_SEPARATOR = "/"

      # Converts the internal piece placement representation to a FEEN string
      #
      # @param piece_placement [Array] Hierarchical array structure representing the board
      # @return [String] FEEN-formatted piece placement string
      # @example
      #   piece_placement = [[{id: 'r'}, {id: 'n'}, nil, nil]]
      #   PiecePlacement.dump(piece_placement)
      #   # => "rn2"
      def self.dump(piece_placement)
        return EMPTY_STRING if piece_placement.nil? || piece_placement.empty?

        # Step 1: Calculate the total depth of the structure
        depth = calculate_depth(piece_placement)

        # Step 2: Convert the structure to a string
        dump_recursive(piece_placement, depth)
      end

      # Calculates the maximum depth of the data structure
      #
      # @param data [Array] Data structure to evaluate
      # @return [Integer] Maximum depth
      def self.calculate_depth(data)
        return 0 unless data.is_a?(Array) && !data.empty?

        if data.first.is_a?(Array)
          1 + calculate_depth(data.first)
        else
          1
        end
      end

      # Recursively converts the structure to FEEN notation
      #
      # @param data [Array] Data to convert
      # @param max_depth [Integer] Maximum depth of the structure
      # @param current_depth [Integer] Current recursion depth
      # @return [String] FEEN representation
      def self.dump_recursive(data, max_depth, current_depth = 1)
        return EMPTY_STRING if data.nil? || data.empty?

        if data.first.is_a?(Array)
          parts = data.map { |subdata| dump_recursive(subdata, max_depth, current_depth + 1) }

          # The number of separators depends on the current depth
          # The lowest level uses a single '/', then increases progressively
          separator_count = max_depth - current_depth
          separator = DIMENSION_SEPARATOR * separator_count

          parts.join(separator)
        else
          # This is a simple row (rank)
          dump_rank(data)
        end
      end

      # Converts a single rank (row/array of cells) to FEEN notation
      #
      # @param cells [Array] Array of cell values (nil for empty, hash for piece)
      # @return [String] FEEN representation of this rank
      # @example
      #   cells = [{id: 'r'}, {id: 'n'}, nil, nil]
      #   PiecePlacement.dump_rank(cells)
      #   # => "rn2"
      def self.dump_rank(cells)
        return EMPTY_STRING if cells.nil? || cells.empty?

        # Use chunk_while to group consecutive empty/non-empty cells
        cells.chunk_while { |a, b| a.nil? == b.nil? }.map do |chunk|
          if chunk.first.nil?
            # Group of empty cells -> count
            chunk.size.to_s
          else
            # Group of pieces -> concatenate FEEN representations
            chunk.map { |cell| dump_cell(cell) }.join(EMPTY_STRING)
          end
        end.join(EMPTY_STRING)
      end

      # Converts a single piece cell to its FEEN representation
      #
      # @param cell [Hash] Hash with :id and optional :prefix and :suffix
      # @return [String] FEEN representation of this piece
      # @example
      #   cell = {id: 'P', suffix: '='}
      #   PiecePlacement.dump_cell(cell)
      #   # => "P="
      def self.dump_cell(cell)
        return EMPTY_STRING if cell.nil?

        # Combine prefix (if any) + piece identifier + suffix (if any)
        [
          cell[:prefix],
          cell[:id],
          cell[:suffix]
        ].compact.join(EMPTY_STRING)
      end

      def self.dump_dimension_group(group)
        max_depth = calculate_depth(group)
        dump_recursive(group, max_depth)
      end
    end
  end
end
