# frozen_string_literal: true

module Sashite
  module Feen
    class Position
      # Represents board structure and piece occupancy.
      #
      # PiecePlacement encapsulates the parsed data from FEEN Field 1,
      # providing methods to query board metrics and iterate over squares.
      #
      # The board is represented as a sequence of segments, where each segment
      # contains placement tokens (pieces or empty counts). Segments are
      # separated by dimensional boundaries encoded in the separators array.
      #
      # Instances are immutable (frozen after creation) and thread-safe.
      #
      # @api public
      #
      # @example Accessing board metrics
      #   placement = position.piece_placement
      #   placement.squares_count  # => 64
      #   placement.pieces_count   # => 32
      #   placement.dimensions     # => 2
      #
      # @example Iterating over squares
      #   placement.each do |square|
      #     case square
      #     when Integer then puts "#{square} empty squares"
      #     when Sashite::Epin::Identifier then puts "Piece: #{square}"
      #     end
      #   end
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      class PiecePlacement
        include ::Enumerable

        # @return [Array<Array>] Board segments, each containing placement tokens
        attr_reader :segments

        # @return [Array<String>] Separators between segments (e.g., "/", "//")
        attr_reader :separators

        # Creates a new PiecePlacement instance.
        #
        # @param segments [Array<Array>] Parsed segments from PiecePlacement parser
        # @param separators [Array<String>] Separators between segments
        # @return [PiecePlacement] A new frozen instance
        def initialize(segments:, separators:)
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
            segment.sum { |token| token.is_a?(::Integer) ? token : 1 }
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
            segment.count { |token| !token.is_a?(::Integer) }
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

        # Iterates over each square on the board.
        #
        # Yields placement tokens in order: either Integer (empty count)
        # or Sashite::Epin::Identifier (piece). Separators are not yielded.
        #
        # @yieldparam square [Integer, Sashite::Epin::Identifier] A placement token
        # @return [Enumerator] If no block given
        #
        # @example
        #   placement.each { |sq| puts sq }
        #
        # @example Getting an enumerator
        #   placement.each.to_a
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
            separator = separators[index] || ""
            "#{segment_str}#{separator}"
          end.join
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

        # Returns a hash code for the PiecePlacement.
        #
        # @return [Integer] Hash code
        def hash
          [segments, separators].hash
        end

        # Returns an inspect string for the PiecePlacement.
        #
        # @return [String] Inspect representation
        def inspect
          "#<#{self.class} #{self}>"
        end
      end
    end
  end
end
