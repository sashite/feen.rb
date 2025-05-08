# frozen_string_literal: true

require_relative File.join("piece_placement", "board")

module Feen
  module Dumper
    module PiecePlacement
      # Converts a piece placement structure to a FEEN-compliant string
      #
      # @param piece_placement [Array] Hierarchical array representing the board where:
      #   - Empty squares are represented by empty strings or nil
      #   - Pieces are represented by strings (e.g., "r", "K=", "+P")
      #   - Dimensions are represented by nested arrays
      # @return [String] FEEN piece placement string
      # @raise [ArgumentError] If the piece placement structure is invalid
      # @example
      #   # 2D chess board
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
      def self.dump(piece_placement)
        # Detect the shape of the board from the piece placement
        shape = detect_shape(piece_placement)

        # Flatten the board into a 1D array
        contents = flatten_board(piece_placement)

        # Create and use the Board class
        board = Board.new(shape)
        board.flatten_squares(*contents)
      end

      private

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

          # Check if we've reached the leaf level (array of strings)
          break if current.first.is_a?(String) || current.first.nil? || current.first.empty?

          current = current.first
        end

        dimensions
      end

      # Flattens the hierarchical board structure into a 1D array
      #
      # @param board [Array] Hierarchical array structure representing the board
      # @return [Array<String>] Flattened array of piece strings where empty cells are represented by empty strings
      def self.flatten_board(board)
        return [] if board.empty?

        # If we're already at the leaf level (1D array of strings)
        return board if board.first.is_a?(String) || board.first.nil? || board.first.empty?

        # Recursively flatten the structure without side effects
        flatten_board_recursive(board)
      end

      # Recursively flattens the board structure without side effects
      #
      # @param structure [Array] Current structure level
      # @return [Array<String>] Flattened array
      def self.flatten_board_recursive(structure)
        # Base case: we've reached a leaf (string or nil)
        if structure.is_a?(String) || structure.nil?
          # Normalize nil to empty string
          return structure.nil? ? "" : structure
        end

        # If it's an array, process each element
        if structure.is_a?(Array)
          # If it contains strings or nil (leaf level), return a normalized array
          if structure.all? { |item| item.is_a?(String) || item.nil? }
            return structure.map { |item| item.nil? ? "" : item }
          end

          # Otherwise, recursively flatten each sub-element and combine
          return structure.flat_map { |item| flatten_board_recursive(item) }
        end

        # Default case (shouldn't happen with valid input)
        ""
      end
    end
  end
end
