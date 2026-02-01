# frozen_string_literal: true

module Sashite
  module Feen
    class Position
      # Represents board structure and piece occupancy.
      #
      # PiecePlacement encapsulates parsed data from FEEN Field 1,
      # providing methods to query board metrics and iterate over squares.
      #
      # The board is represented as a sequence of segments, where each segment
      # contains placement tokens (pieces or empty counts). Segments are
      # separated by dimensional boundaries encoded in the separators array.
      #
      # Instances are immutable (frozen after creation) and thread-safe.
      #
      # This class is an implementation detail of {Position} and should not
      # be instantiated directly by external code.
      #
      # @api private
      class PiecePlacement
        include ::Enumerable

        # Empty string used when no separator follows a segment.
        EMPTY_STRING = ""

        # @return [Array<Array>] Board segments, each containing placement tokens
        attr_reader :segments

        # @return [Array<String>] Separators between segments (e.g., "/", "//")
        attr_reader :separators

        # Creates a new PiecePlacement instance.
        #
        # @param segments [Array<Array>] Parsed segments containing tokens
        # @param separators [Array<String>] Separators between segments
        # @return [PiecePlacement] A new frozen instance
        # @raise [ArgumentError] If segments is not an Array
        # @raise [ArgumentError] If separators is not an Array
        # @raise [ArgumentError] If any segment is not an Array
        # @raise [ArgumentError] If any separator is not a String
        def initialize(segments:, separators:)
          raise ::ArgumentError, "segments must be an Array, got #{segments.class}" unless ::Array === segments
          raise ::ArgumentError, "separators must be an Array, got #{separators.class}" unless ::Array === separators

          validate_segments!(segments)
          validate_separators!(separators)

          @segments = segments
          @separators = separators

          freeze
        end

        # Returns the total number of squares on the board.
        #
        # @return [Integer] Total square count
        #
        # @example
        #   placement.squares_count  # => 64 (for 8x8 board)
        def squares_count
          segments.sum do |segment|
            segment.sum { |token| ::Integer === token ? token : 1 }
          end
        end

        # Returns the number of pieces on the board.
        #
        # @return [Integer] Piece count (excludes empty squares)
        #
        # @example
        #   placement.pieces_count  # => 32 (for Chess initial position)
        def pieces_count
          segments.sum do |segment|
            segment.count { |token| !(::Integer === token) }
          end
        end

        # Returns the board dimensionality.
        #
        # Dimensionality is determined by the maximum separator length:
        # - No separators: 1D
        # - "/" only: 2D
        # - "//" present: 3D
        #
        # @return [Integer] 1 for 1D, 2 for 2D, 3 for 3D
        #
        # @example
        #   placement.dimensions  # => 2 (for standard chess board)
        def dimensions
          return 1 if separators.empty?

          separators.map(&:length).max + 1
        end

        # Iterates over each placement token on the board.
        #
        # Yields tokens in order: either Integer (empty count)
        # or piece identifier. Separators are not yielded.
        #
        # @yieldparam token [Integer, Object] A placement token
        # @return [Enumerator] If no block given
        #
        # @example
        #   placement.each { |token| puts token }
        def each(&block)
          return enum_for(:each) unless block

          segments.each do |segment|
            segment.each(&block)
          end
        end

        # Returns the canonical FEEN string representation.
        #
        # @return [String] Canonical piece placement string
        #
        # @example
        #   placement.to_s  # => "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
        def to_s
          segments.map.with_index do |segment, index|
            segment_str = segment.map(&:to_s).join
            separator = separators[index] || EMPTY_STRING
            "#{segment_str}#{separator}"
          end.join
        end

        # Checks equality with another PiecePlacement.
        #
        # @param other [Object] The object to compare
        # @return [Boolean] true if equal
        def ==(other)
          return false unless self.class === other
          return false unless segments == other.segments

          separators == other.separators
        end

        alias eql? ==

        # Returns a hash code for the PiecePlacement.
        #
        # @return [Integer] Hash code
        def hash
          [self.class, segments, separators].hash
        end

        # Returns an inspect string for the PiecePlacement.
        #
        # @return [String] Inspect representation
        def inspect
          "#<#{self.class} #{self}>"
        end

        private

        # Validates that all segments are Arrays.
        #
        # @param segments [Array] The segments to validate
        # @raise [ArgumentError] If any segment is not an Array
        def validate_segments!(segments)
          segments.each_with_index do |segment, index|
            unless ::Array === segment
              raise ::ArgumentError, "segment at index #{index} must be an Array, got #{segment.class}"
            end
          end
        end

        # Validates that all separators are Strings.
        #
        # @param separators [Array] The separators to validate
        # @raise [ArgumentError] If any separator is not a String
        def validate_separators!(separators)
          separators.each_with_index do |separator, index|
            unless ::String === separator
              raise ::ArgumentError, "separator at index #{index} must be a String, got #{separator.class}"
            end
          end
        end

        private_class_method :new

        freeze
      end
    end
  end
end
