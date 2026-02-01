# frozen_string_literal: true

require_relative "hand"

module Sashite
  module Feen
    class Position
      # Represents off-board pieces held by both players.
      #
      # Hands aggregates two Hand instances, one for each player,
      # providing access to each player's hand and aggregate metrics.
      #
      # Instances are immutable (frozen after creation) and thread-safe.
      #
      # This class is an implementation detail of {Position} and should not
      # be instantiated directly by external code.
      #
      # @api private
      class Hands
        # Separator between first and second hands in FEEN notation.
        SEPARATOR = "/"

        # @return [Hand] First player's hand
        attr_reader :first

        # @return [Hand] Second player's hand
        attr_reader :second

        # Creates a new Hands instance.
        #
        # @param first [Array<Hash>] First player's hand items (default: empty)
        # @param second [Array<Hash>] Second player's hand items (default: empty)
        # @return [Hands] A new frozen instance
        #
        # @example Empty hands
        #   Hands.new(first: [], second: [])
        #
        # @example With pieces
        #   Hands.new(
        #     first: [{ piece: epin_p, count: 2 }],
        #     second: [{ piece: epin_n, count: 1 }]
        #   )
        def initialize(first: [], second: [])
          @first = Hand.send(:new, first)
          @second = Hand.send(:new, second)

          freeze
        end

        # Returns the total number of pieces in both hands.
        #
        # @return [Integer] Total piece count
        #
        # @example
        #   hands.pieces_count  # => 8
        def pieces_count
          first.pieces_count + second.pieces_count
        end

        # Returns the canonical FEEN string representation.
        #
        # @return [String] Canonical hands string (e.g., "2BNR/p")
        #
        # @example
        #   hands.to_s  # => "2BNR/p"
        def to_s
          "#{first}#{SEPARATOR}#{second}"
        end

        # Checks equality with another Hands.
        #
        # Two Hands are equal if both their first and second hands are equal.
        #
        # @param other [Object] The object to compare
        # @return [Boolean] true if equal
        def ==(other)
          return false unless self.class === other
          return false unless first == other.first

          second == other.second
        end

        alias eql? ==

        # Returns a hash code for the Hands.
        #
        # @return [Integer] Hash code
        def hash
          [self.class, first, second].hash
        end

        # Returns an inspect string for the Hands.
        #
        # @return [String] Inspect representation
        def inspect
          "#<#{self.class} first=#{first.inspect} second=#{second.inspect}>"
        end

        private_class_method :new

        freeze
      end
    end
  end
end
