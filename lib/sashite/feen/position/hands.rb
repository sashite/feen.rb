# frozen_string_literal: true

require_relative "../constants"

module Sashite
  module Feen
    class Position
      # Represents the Hands field (Field 2).
      #
      # Encapsulates off-board pieces held by each player.
      #
      # @example
      #   hands = Hands.new(
      #     first: [{ piece: <Epin P>, count: 2 }],
      #     second: [{ piece: <Epin p>, count: 1 }]
      #   )
      #   hands.to_s  # => "2P/p"
      class Hands
        # @return [Hand] First player's hand
        attr_reader :first

        # @return [Hand] Second player's hand
        attr_reader :second

        # Creates a new Hands instance.
        #
        # @param first [Array<Hash>] First player's hand items
        # @param second [Array<Hash>] Second player's hand items
        def initialize(first:, second:)
          @first = Hand.new(first)
          @second = Hand.new(second)

          freeze
        end

        # Returns the canonical string representation.
        #
        # @return [String] The hands string
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

        # Returns a hash code.
        #
        # @return [Integer] Hash code
        def hash
          [first, second].hash
        end
      end

      # Represents a single player's hand.
      #
      # Contains a collection of hand items (piece + count pairs).
      #
      # @example
      #   hand = Hand.new([{ piece: <Epin P>, count: 2 }, { piece: <Epin N>, count: 1 }])
      #   hand.to_s  # => "2PN"
      class Hand
        # @return [Array<Hash>] Hand items with :piece and :count keys
        attr_reader :items

        # Creates a new Hand instance.
        #
        # @param items [Array<Hash>] Hand items
        def initialize(items)
          @items = items

          freeze
        end

        # Returns true if the hand is empty.
        #
        # @return [Boolean]
        def empty?
          items.empty?
        end

        # Returns the number of distinct piece types.
        #
        # @return [Integer]
        def size
          items.size
        end

        # Iterates over each hand item.
        #
        # @yieldparam item [Hash] A hand item with :piece and :count
        # @return [Enumerator, self]
        def each(&block)
          return items.each unless block

          items.each(&block)
          self
        end

        # Returns the canonical string representation.
        #
        # @return [String] The hand string
        def to_s
          items.map { |item| hand_item_to_s(item) }.join
        end

        # Checks equality with another Hand.
        #
        # @param other [Object] The object to compare
        # @return [Boolean] true if equal
        def ==(other)
          return false unless self.class === other

          items == other.items
        end

        alias eql? ==

        # Returns a hash code.
        #
        # @return [Integer] Hash code
        def hash
          items.hash
        end

        private

        # Converts a hand item to its string representation.
        #
        # @param item [Hash] A hand item with :piece and :count
        # @return [String] The hand item string
        def hand_item_to_s(item)
          count = item[:count]
          piece = item[:piece]

          count == 1 ? piece.to_s : "#{count}#{piece}"
        end
      end
    end
  end
end
