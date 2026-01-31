# frozen_string_literal: true

module Sashite
  module Feen
    class Position
      class Hands
        # Represents a single player's off-board pieces.
        #
        # A Hand contains zero or more items, each being a piece type
        # with an associated count. Items are stored in canonical order.
        #
        # Instances are immutable (frozen after creation) and thread-safe.
        #
        # @api public
        #
        # @example Querying a hand
        #   hand.empty?        # => false
        #   hand.size          # => 3
        #   hand.pieces_count  # => 7
        #
        # @example Iterating over items
        #   hand.each do |piece, count|
        #     puts "#{count}x #{piece}"
        #   end
        #
        # @see https://sashite.dev/specs/feen/1.0.0/
        class Hand
          include ::Enumerable

          # @return [Array<Hash>] Hand items with :piece and :count keys
          attr_reader :items

          # Creates a new Hand instance.
          #
          # @param items [Array<Hash>] Hand items from parser
          # @return [Hand] A new frozen instance
          def initialize(items)
            @items = items

            freeze
          end

          # Returns true if the hand contains no pieces.
          #
          # @return [Boolean] true if empty
          #
          # @example
          #   hand.empty?  # => true
          def empty?
            items.empty?
          end

          # Returns the number of distinct piece types.
          #
          # @return [Integer] Number of distinct piece types
          #
          # @example
          #   hand.size  # => 3 (e.g., for "2PNR")
          def size
            items.size
          end

          # Returns the total number of pieces.
          #
          # @return [Integer] Total piece count
          #
          # @example
          #   hand.pieces_count  # => 4 (e.g., for "2PNR" = 2+1+1)
          def pieces_count
            items.sum { |item| item[:count] }
          end

          # Iterates over each piece type and its count.
          #
          # @yieldparam piece [Sashite::Epin::Identifier] The piece
          # @yieldparam count [Integer] Number of that piece
          # @return [Enumerator] If no block given
          #
          # @example
          #   hand.each { |piece, count| puts "#{count}x #{piece}" }
          def each(&block)
            return enum_for(:each) unless block

            items.each do |item|
              block.call(item[:piece], item[:count])
            end
          end

          # Returns the canonical FEEN string representation.
          #
          # @return [String] Canonical hand string (e.g., "2PN")
          #
          # @example
          #   hand.to_s  # => "2PN"
          def to_s
            items.map do |item|
              count_str = item[:count] > 1 ? item[:count].to_s : ""
              "#{count_str}#{item[:piece]}"
            end.join
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

          # Returns a hash code for the Hand.
          #
          # @return [Integer] Hash code
          def hash
            items.hash
          end

          # Returns an inspect string for the Hand.
          #
          # @return [String] Inspect representation
          def inspect
            "#<#{self.class} #{self}>"
          end
        end
      end
    end
  end
end
