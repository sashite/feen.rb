# frozen_string_literal: true

module Sashite
  module Feen
    class Position
      # Represents the Piece Placement field (Field 1).
      #
      # Encapsulates board occupancy as segments of placement tokens
      # with preserved separator groups for multi-dimensional boards.
      #
      # @example
      #   pp = PiecePlacement.new(
      #     segments: [[<Epin r>, 2, <Epin k>], [8]],
      #     separators: ["/"]
      #   )
      #   pp.to_s  # => "r2k/8"
      class PiecePlacement
        # @return [Array<Array>] Segments containing Integer (empty count) or Epin::Identifier
        attr_reader :segments

        # @return [Array<String>] Separator strings between segments
        attr_reader :separators

        # Creates a new PiecePlacement instance.
        #
        # @param segments [Array<Array>] Segments of placement tokens
        # @param separators [Array<String>] Separators between segments
        def initialize(segments:, separators:)
          @segments = segments
          @separators = separators

          freeze
        end

        # Iterates over each segment.
        #
        # @yieldparam segment [Array] A segment of placement tokens
        # @return [Enumerator, self]
        def each_segment(&block)
          return segments.each unless block

          segments.each(&block)
          self
        end

        # Returns all tokens as a flat array.
        #
        # @return [Array] All placement tokens
        def to_a
          segments.flatten
        end

        # Returns the canonical string representation.
        #
        # @return [String] The piece placement string
        def to_s
          segments.map { |segment| segment_to_s(segment) }
                  .zip(separators)
                  .flatten
                  .compact
                  .join
        end

        # Checks equality with another PiecePlacement.
        #
        # @param other [Object] The object to compare
        # @return [Boolean] true if equal
        def ==(other)
          return false unless self.class === other

          segments == other.segments && separators == other.separators
        end

        alias eql? ==

        # Returns a hash code.
        #
        # @return [Integer] Hash code
        def hash
          [segments, separators].hash
        end

        private

        # Converts a segment to its string representation.
        #
        # @param segment [Array] A segment of placement tokens
        # @return [String] The segment string
        def segment_to_s(segment)
          segment.map { |token| token.to_s }.join
        end
      end
    end
  end
end
