# frozen_string_literal: true

module Sashite
  module Feen
    # Immutable representation of board piece placement.
    #
    # Stores the configuration of pieces on a multi-dimensional board,
    # where each position can contain a piece or be empty (nil).
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    class Placement
      # @return [Array<Array>] Array of ranks, each rank being an array of pieces/nils
      attr_reader :ranks

      # @return [Integer] Board dimensionality (2 for 2D, 3 for 3D, etc.)
      attr_reader :dimension

      # @return [Array<Integer>, nil] Section sizes for multi-dimensional boards (nil for 2D)
      attr_reader :sections

      # Create a new immutable Placement object.
      #
      # @param ranks [Array<Array>] Array of ranks with pieces and nils
      # @param dimension [Integer] Board dimensionality (default: 2)
      # @param sections [Array<Integer>, nil] Sizes of sections for dimension > 2
      #
      # @example Create a 2D placement
      #   ranks = [
      #     [rook, knight, bishop, queen, king, bishop, knight, rook],
      #     [pawn, pawn, pawn, pawn, pawn, pawn, pawn, pawn]
      #   ]
      #   placement = Placement.new(ranks)
      #
      # @example Create a 3D placement
      #   ranks = [...] # 15 ranks total
      #   placement = Placement.new(ranks, 3, [5, 5, 5]) # 3 sections of 5 ranks each
      def initialize(ranks, dimension = 2, sections = nil)
        @ranks = ranks.freeze
        @dimension = dimension
        @sections = sections&.freeze

        freeze
      end

      # Convert placement to its FEEN string representation.
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
      # @param other [Placement] Another placement object
      # @return [Boolean] True if ranks, dimensions, and sections are equal
      def ==(other)
        other.is_a?(Placement) &&
          ranks == other.ranks &&
          dimension == other.dimension &&
          sections == other.sections
      end

      alias eql? ==

      # Generate hash code for placement.
      #
      # @return [Integer] Hash code based on ranks, dimension, and sections
      def hash
        [ranks, dimension, sections].hash
      end
    end
  end
end
