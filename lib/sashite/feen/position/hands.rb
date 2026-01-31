# frozen_string_literal: true

require_relative "hands/hand"
require_relative "../constants"

module Sashite
  module Feen
    class Position
      # Represents off-board pieces held by both players.
      #
      # Hands encapsulates the parsed data from FEEN Field 2,
      # providing access to each player's hand and aggregate metrics.
      #
      # Instances are immutable (frozen after creation) and thread-safe.
      #
      # @api public
      #
      # @example Accessing hands
      #   hands = position.hands
      #   hands.first.pieces_count   # => 5
      #   hands.second.pieces_count  # => 3
      #   hands.pieces_count         # => 8
      #
      # @example Iterating over a hand
      #   hands.first.each do |piece, count|
      #     puts "#{count}x #{piece}"
      #   end
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      class Hands
        # @return [Hand] First player's hand
        attr_reader :first

        # @return [Hand] Second player's hand
        attr_reader :second

        # Creates a new Hands instance.
        #
        # @param first [Array<Hash>] First player's hand items
        # @param second [Array<Hash>] Second player's hand items
        # @return [Hands] A new frozen instance
        def initialize(first:, second:)
          @first = Hand.new(first)
          @second = Hand.new(second)

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
        # @return [String] Canonical hands string (e.g., "2PN/p")
        #
        # @example
        #   hands.to_s  # => "2PN/p"
        def to_s
          "#{first}#{Constants::SEGMENT_SEPARATOR}#{second}"
        end

        # Checks equality with another Hands.
        #
        # @param other [Object] The object to compare
        # @return [Boolean] true if equal
        def ==(other)
          return false unless self.class === other

          first == other.first && second == other.second
        end

        alias eql? ==

        # Returns a hash code for the Hands.
        #
        # @return [Integer] Hash code
        def hash
          [first, second].hash
        end

        # Returns an inspect string for the Hands.
        #
        # @return [String] Inspect representation
        def inspect
          "#<#{self.class} #{self}>"
        end
      end
    end
  end
end
