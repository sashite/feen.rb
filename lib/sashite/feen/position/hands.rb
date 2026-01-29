# frozen_string_literal: true

require_relative "../constants"

module Sashite
  module Feen
    class Position
      # Represents the Hands field (Field 2).
      #
      # Encapsulates off-board pieces held by each player.
      #
      # @api public
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
      # @api public
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
        # Items are sorted according to canonical ordering:
        # 1. By multiplicity — descending (larger counts first)
        # 2. By base letter — case-insensitive alphabetical order
        # 3. By letter case — uppercase before lowercase
        # 4. By state modifier — `-` before `+` before none
        # 5. By terminal marker — absent before present
        # 6. By derivation marker — absent before present
        #
        # @return [String] The hand string in canonical order
        def to_s
          canonical_items.map { |item| hand_item_to_s(item) }.join
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

        # Returns items sorted in canonical order.
        #
        # @return [Array<Hash>] Items in canonical order
        def canonical_items
          items.sort { |a, b| compare_hand_items(a, b) }
        end

        # Compares two hand items according to canonical ordering rules.
        #
        # @param item_a [Hash] First hand item
        # @param item_b [Hash] Second hand item
        # @return [Integer] Comparison result (-1, 0, or 1)
        def compare_hand_items(item_a, item_b)
          # 1. By multiplicity — descending
          cmp = item_b[:count] <=> item_a[:count]
          return cmp unless cmp == 0

          piece_a = item_a[:piece]
          piece_b = item_b[:piece]
          pin_a = piece_a.pin
          pin_b = piece_b.pin

          # 2. By base letter — case-insensitive alphabetical
          cmp = pin_a.abbr.to_s <=> pin_b.abbr.to_s
          return cmp unless cmp == 0

          # 3. By letter case — uppercase before lowercase (first before second)
          cmp = side_order(pin_a.side) <=> side_order(pin_b.side)
          return cmp unless cmp == 0

          # 4. By state modifier — `-` before `+` before none
          cmp = state_order(pin_a.state) <=> state_order(pin_b.state)
          return cmp unless cmp == 0

          # 5. By terminal marker — absent before present
          cmp = terminal_order(pin_a.terminal?) <=> terminal_order(pin_b.terminal?)
          return cmp unless cmp == 0

          # 6. By derivation marker — absent before present
          derived_order(piece_a.derived?) <=> derived_order(piece_b.derived?)
        end

        # Returns sort order for side.
        #
        # @param side [Symbol] :first or :second
        # @return [Integer] 0 for first (uppercase), 1 for second (lowercase)
        def side_order(side)
          side == :first ? 0 : 1
        end

        # Returns sort order for state modifier.
        #
        # @param state [Symbol] :diminished, :enhanced, or :normal
        # @return [Integer] 0 for diminished, 1 for enhanced, 2 for normal
        def state_order(state)
          case state
          when :diminished then 0
          when :enhanced then 1
          else 2
          end
        end

        # Returns sort order for terminal marker.
        #
        # @param terminal [Boolean] Terminal status
        # @return [Integer] 0 for absent, 1 for present
        def terminal_order(terminal)
          terminal ? 1 : 0
        end

        # Returns sort order for derivation marker.
        #
        # @param derived [Boolean] Derived status
        # @return [Integer] 0 for absent, 1 for present
        def derived_order(derived)
          derived ? 1 : 0
        end

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
