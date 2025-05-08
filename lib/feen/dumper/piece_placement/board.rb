# frozen_string_literal: true

module Feen
  module Dumper
    module PiecePlacement
      # Represents a board for FEEN piece placement formatting
      class Board
        # Error messages
        ERRORS = {
          invalid_shape:        "Board shape must be an array of positive integers, got %s",
          invalid_contents:     "Contents size (%d) does not match board size (%d)",
          invalid_content_type: "Content item must be nil or a String instance, got %s"
        }.freeze

        # Readonly accessor for board shape
        attr_reader :shape

        # Initialize a new Board with a specific shape
        #
        # @param shape [Array<Integer>] The dimensions of the board (e.g., [8, 8] for a chess board)
        # @raise [ArgumentError] If shape is invalid
        def initialize(shape)
          validate_shape(shape)
          @shape = shape.dup.freeze
          freeze
        end

        # Convert a flat array of contents to a FEEN piece placement string
        #
        # @param contents [Array<nil, String>] Flattened array of board contents
        # @return [String] FEEN piece placement string
        # @raise [ArgumentError] If contents size doesn't match board size or contains invalid items
        def flatten_squares(*contents)
          # Handle special case of empty shape
          return "" if shape.empty? || shape.all?(&:zero?)

          # Calculate total board size from shape
          board_size = shape.reduce(1, :*)

          # Validate contents
          validate_contents(contents, board_size)

          # Convert to FEEN piece placement format
          format_contents(contents)
        end

        private

        # Validates the board shape
        #
        # @param shape [Array] Board shape to validate
        # @raise [ArgumentError] If shape is invalid
        def validate_shape(shape)
          raise ArgumentError, format(ERRORS[:invalid_shape], shape.inspect) unless shape.is_a?(Array)

          # Allow empty shape or shape with all zeros (returns empty string)
          return if shape.empty? || shape.all?(&:zero?)

          # Otherwise all dimensions must be positive integers
          return if shape.all? { |dim| dim.is_a?(Integer) && dim.positive? }

          raise ArgumentError, format(ERRORS[:invalid_shape], shape.inspect)
        end

        # Validates the board contents
        #
        # @param contents [Array] Contents to validate
        # @param board_size [Integer] Expected size of contents
        # @raise [ArgumentError] If contents are invalid
        def validate_contents(contents, board_size)
          unless contents.size == board_size
            raise ArgumentError, format(ERRORS[:invalid_contents], contents.size, board_size)
          end

          contents.each do |item|
            next if item.nil? || item.is_a?(String)

            raise ArgumentError, format(ERRORS[:invalid_content_type], item.class)
          end
        end

        # Formats the flattened contents into a FEEN piece placement string
        #
        # @param contents [Array] Flattened board contents
        # @return [String] FEEN piece placement string
        def format_contents(contents)
          # Handle special case of 1D array
          return format_rank(contents) if shape.size == 1

          # For multi-dimensional structures, reshape and format
          struct = reshape_contents(contents)
          format_structure(struct)
        end

        # Reshapes flat contents into a multi-dimensional structure
        #
        # @param contents [Array] Flat contents array
        # @return [Array] Multi-dimensional array with correct orientation
        def reshape_contents(contents)
          # Make a copy to avoid modifying the original
          contents_copy = contents.dup

          # Build nested array structure based on shape
          dimensions = shape.dup
          result = build_dimensions(contents_copy, dimensions)

          # For 2D+ boards, reverse the top level to match FEEN orientation
          result = result.reverse if shape.size >= 2

          result
        end

        # Recursively builds a nested array structure according to dimensions
        #
        # @param items [Array] Items to place in the structure
        # @param dims [Array] Current dimensions to build
        # @return [Array] Nested array structure
        def build_dimensions(items, dims)
          return items.shift if dims.empty?

          current_dim = dims[0]
          remaining_dims = dims[1..]

          if remaining_dims.empty?
            # At the bottom level, create a row
            Array.new(current_dim) { items.shift }
          else
            # Create a nested structure
            Array.new(current_dim) do
              build_dimensions(items, remaining_dims)
            end
          end
        end

        # Formats a multi-dimensional structure into FEEN notation
        #
        # @param structure [Array] Multi-dimensional structure to format
        # @return [String] FEEN notation string
        def format_structure(structure)
          if structure.first.is_a?(Array)
            # Process next dimension level
            parts = structure.map { |substructure| format_structure(substructure) }

            # Join with appropriate separator
            depth = calculate_depth(structure) - 1
            separator = "/" * depth

            parts.join(separator)
          else
            # Bottom level - format a rank
            format_rank(structure)
          end
        end

        # Calculate the depth of a nested structure
        #
        # @param structure [Array] Structure to analyze
        # @return [Integer] Depth of the structure
        def calculate_depth(structure)
          return 0 unless structure.is_a?(Array) && !structure.empty?

          if structure.first.is_a?(Array)
            1 + calculate_depth(structure.first)
          else
            1
          end
        end

        # Formats a sequence of cells into FEEN notation
        #
        # @param rank [Array<nil, String>] Sequence of cells
        # @return [String] FEEN rank notation
        def format_rank(rank)
          # Group consecutive empty/non-empty cells
          result = ""
          empty_count = 0

          rank.each do |cell|
            if cell.nil?
              empty_count += 1
            else
              # If we accumulated empty cells, add their count
              if empty_count > 0
                result += empty_count.to_s
                empty_count = 0
              end
              # Add the piece representation
              result += cell.to_s
            end
          end

          # Add any remaining empty cells
          result += empty_count.to_s if empty_count > 0

          result
        end
      end
    end
  end
end
