# frozen_string_literal: true

module Sashite
  module Feen
    # Immutable representation of board piece placement.
    #
    # Stores board configuration as a flat array of ranks with explicit
    # separators, allowing representation of any valid FEEN structure
    # including highly irregular multi-dimensional boards.
    #
    # This design supports complete flexibility:
    # - Any number of dimensions (1D to nD)
    # - Irregular board shapes (different rank sizes)
    # - Arbitrary separator patterns (different separator lengths)
    #
    # @example 1D board (no separators)
    #   ranks = [[king, nil, pawn]]
    #   placement = Placement.new(ranks)
    #
    # @example Regular 2D board
    #   ranks = [
    #     [rook, knight, bishop, queen, king, bishop, knight, rook],
    #     [pawn, pawn, pawn, pawn, pawn, pawn, pawn, pawn],
    #     # ... 6 more ranks
    #   ]
    #   separators = ["/", "/", "/", "/", "/", "/", "/"]
    #   placement = Placement.new(ranks, separators)
    #
    # @example Irregular 3D board
    #   ranks = [[r1], [r2], [r3], [r4]]
    #   separators = ["/", "//", "/"]  # Mixed dimension separators
    #   placement = Placement.new(ranks, separators)
    #
    # @example Highly irregular structure
    #   # "99999/3///K/k//r"
    #   ranks = [[nil]*99999, [nil]*3, [king], [king_b], [rook]]
    #   separators = ["/", "///", "/", "//"]
    #   placement = Placement.new(ranks, separators)
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    class Placement
      # @return [Array<Array>] Flat array of all ranks
      #   Each rank is an array containing piece objects and/or nils
      attr_reader :ranks

      # @return [Array<String>] Separators between consecutive ranks
      #   separators[i] is the separator between ranks[i] and ranks[i+1]
      #   Each separator is a string of one or more "/" characters
      #   Always has length = ranks.length - 1 (or empty for single rank)
      attr_reader :separators

      # @return [Integer] Board dimensionality
      #   Calculated as: 1 + (maximum consecutive "/" characters in any separator)
      #   Examples:
      #     - No separators → 1D
      #     - Only "/" → 2D
      #     - At least one "//" → 3D
      #     - At least one "///" → 4D
      attr_reader :dimension

      # Create a new immutable Placement object.
      #
      # @param ranks [Array<Array>] Array of ranks (each rank is array of pieces/nils)
      # @param separators [Array<String>] Separators between ranks (default: [])
      # @param dimension [Integer, nil] Explicit dimension (auto-calculated if nil)
      #
      # @raise [ArgumentError] If separators count doesn't match ranks
      # @raise [ArgumentError] If any separator is invalid
      # @raise [ArgumentError] If dimension is less than 1
      #
      # @example Create 1D placement
      #   Placement.new([[king, nil, pawn]])
      #
      # @example Create 2D placement
      #   Placement.new(
      #     [[rank1_pieces], [rank2_pieces]],
      #     ["/"]
      #   )
      #
      # @example Create 3D placement with explicit dimension
      #   Placement.new(
      #     [[r1], [r2], [r3]],
      #     ["/", "//"],
      #     3
      #   )
      def initialize(ranks, separators = [], dimension = nil)
        @ranks = deep_freeze_ranks(ranks)
        @separators = separators.freeze
        @dimension = dimension || calculate_dimension(separators)

        validate!
        freeze
      end

      # Get total number of ranks across all dimensions.
      #
      # @return [Integer] Total rank count
      #
      # @example
      #   placement.rank_count  # => 8 (for standard chess board)
      def rank_count
        @ranks.size
      end

      # Check if the board is 1-dimensional (single rank, no separators).
      #
      # @return [Boolean] True if dimension is 1
      #
      # @example
      #   placement.one_dimensional?  # => false (for 2D chess board)
      def one_dimensional?
        @dimension == 1
      end

      # Get all pieces from all ranks (flattened).
      #
      # @return [Array] Flat array of all pieces (nils excluded)
      #
      # @example
      #   placement.all_pieces.size  # => 32 (for chess starting position)
      def all_pieces
        @ranks.flatten.compact
      end

      # Get total number of squares across all ranks.
      #
      # @return [Integer] Total square count
      #
      # @example
      #   placement.total_squares  # => 64 (for 8x8 chess board)
      def total_squares
        @ranks.sum(&:size)
      end

      # Convert placement to array representation based on dimensionality.
      #
      # The returned structure depends on board dimension:
      # - 1D boards: Returns single rank array (or empty array if no ranks)
      # - 2D+ boards: Returns array of ranks
      #
      # @return [Array] Array representation of the board
      #
      # @example 1D board (single rank)
      #   placement = Placement.new([[K, nil, P]], [], 1)
      #   placement.to_a  # => [K, nil, P]
      #
      # @example 1D empty board
      #   placement = Placement.new([], [], 1)
      #   placement.to_a  # => []
      #
      # @example 2D board (multiple ranks)
      #   placement = Placement.new([[r, n], [p, p]], ["/"], 2)
      #   placement.to_a  # => [[r, n], [p, p]]
      #
      # @example 3D board (returns flat array of all ranks)
      #   placement = Placement.new([[r], [n], [b]], ["/", "//"], 3)
      #   placement.to_a  # => [[r], [n], [b]]
      def to_a
        return ranks.first || [] if one_dimensional?

        ranks
      end

      # Convert placement to its FEEN string representation.
      #
      # Delegates to Dumper::PiecePlacement for canonical serialization.
      #
      # @return [String] FEEN piece placement field
      #
      # @example
      #   placement.to_s
      #   # => "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R"
      def to_s
        Dumper::PiecePlacement.dump(self)
      end

      # Compare two placements for equality.
      #
      # Two placements are equal if they have the same ranks, separators,
      # and dimension.
      #
      # @param other [Placement] Another placement object
      # @return [Boolean] True if all attributes are equal
      #
      # @example
      #   placement1 == placement2  # => true (if identical)
      def ==(other)
        other.is_a?(Placement) &&
          ranks == other.ranks &&
          separators == other.separators &&
          dimension == other.dimension
      end

      alias eql? ==

      # Generate hash code for placement.
      #
      # Ensures that equal placements have equal hash codes for use
      # in hash-based collections.
      #
      # @return [Integer] Hash code based on ranks, separators, and dimension
      #
      # @example
      #   placement1.hash == placement2.hash  # => true (if equal)
      def hash
        [ranks, separators, dimension].hash
      end

      # Get a human-readable representation of the placement.
      #
      # @return [String] Debug representation
      #
      # @example
      #   placement.inspect
      #   # => "#<Sashite::Feen::Placement dimension=2 ranks=8 separators=7>"
      def inspect
        "#<#{self.class.name} dimension=#{dimension} ranks=#{rank_count} separators=#{separators.size}>"
      end

      private

      # Deep freeze ranks array to ensure immutability.
      #
      # Freezes both the outer array and each individual rank array.
      #
      # @param ranks_array [Array<Array>] Array of ranks
      # @return [Array<Array>] Frozen ranks array
      def deep_freeze_ranks(ranks_array)
        ranks_array.map(&:freeze).freeze
      end

      # Validate placement structure.
      #
      # Checks:
      # 1. Separator count matches rank count (must be ranks.size - 1)
      # 2. All separators are valid (one or more "/" characters)
      # 3. Dimension is at least 1
      #
      # @raise [ArgumentError] If validation fails
      def validate!
        validate_separator_count!
        validate_separators!
        validate_dimension!
      end

      # Validate that separator count matches rank count.
      #
      # For n ranks, there must be exactly n-1 separators.
      # Special case: 0 or 1 rank requires empty separators array.
      #
      # @raise [ArgumentError] If count mismatch
      def validate_separator_count!
        expected_count = [ranks.size - 1, 0].max

        return if separators.size == expected_count

        raise ArgumentError,
              "Expected #{expected_count} separator(s) for #{ranks.size} rank(s), got #{separators.size}"
      end

      # Validate that all separators are valid.
      #
      # Each separator must be a non-empty string containing only "/" characters.
      #
      # @raise [ArgumentError] If any separator is invalid
      def validate_separators!
        separators.each_with_index do |sep, idx|
          unless sep.is_a?(String) && !sep.empty? && sep.match?(%r{\A/+\z})
            raise ArgumentError,
                  "Invalid separator at index #{idx}: #{sep.inspect} (must be one or more '/' characters)"
          end
        end
      end

      # Validate that dimension is valid.
      #
      # Dimension must be at least 1.
      #
      # @raise [ArgumentError] If dimension is invalid
      def validate_dimension!
        return if dimension.is_a?(Integer) && dimension >= 1

        raise ArgumentError,
              "Dimension must be an integer >= 1, got #{dimension.inspect}"
      end

      # Calculate dimension from separators.
      #
      # Dimension is defined as: 1 + (max consecutive "/" in any separator)
      #
      # Examples:
      #   - [] → 1 (no separators = 1D)
      #   - ["/", "/"] → 2 (only single "/" = 2D)
      #   - ["/", "//", "/"] → 3 (max is "//" = 3D)
      #   - ["///"] → 4 (max is "///" = 4D)
      #
      # @param seps [Array<String>] Array of separator strings
      # @return [Integer] Calculated dimension
      def calculate_dimension(seps)
        return 1 if seps.empty?

        max_slashes = seps.map(&:length).max
        max_slashes + 1
      end
    end
  end
end
