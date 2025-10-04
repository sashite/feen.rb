# frozen_string_literal: true

module Sashite
  module Feen
    # Immutable representation of pieces held in hand by each player.
    #
    # Stores captured pieces that players hold in reserve, available for
    # placement back onto the board in games that support drop mechanics
    # (such as shogi, crazyhouse, etc.).
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    class Hands
      # @return [Array] Array of pieces held by first player
      attr_reader :first_player

      # @return [Array] Array of pieces held by second player
      attr_reader :second_player

      # Create a new immutable Hands object.
      #
      # @param first_player [Array] Pieces in first player's hand
      # @param second_player [Array] Pieces in second player's hand
      #
      # @example Empty hands
      #   hands = Hands.new([], [])
      #
      # @example First player has captured pieces
      #   hands = Hands.new([pawn1, pawn2], [])
      #
      # @example Both players have captured pieces
      #   hands = Hands.new([rook, bishop], [pawn1, pawn2, knight])
      def initialize(first_player, second_player)
        @first_player = first_player.freeze
        @second_player = second_player.freeze

        freeze
      end

      # Check if both hands are empty.
      #
      # @return [Boolean] True if neither player has pieces in hand
      #
      # @example
      #   hands.empty?  # => true
      def empty?
        first_player.empty? && second_player.empty?
      end

      # Convert hands to their FEEN string representation.
      #
      # @return [String] FEEN pieces-in-hand field
      #
      # @example
      #   hands.to_s
      #   # => "2P/p"
      def to_s
        Dumper::PiecesInHand.dump(self)
      end

      # Compare two hands for equality.
      #
      # @param other [Hands] Another hands object
      # @return [Boolean] True if both players' pieces are equal
      def ==(other)
        other.is_a?(Hands) &&
          first_player == other.first_player &&
          second_player == other.second_player
      end

      alias eql? ==

      # Generate hash code for hands.
      #
      # @return [Integer] Hash code based on both players' pieces
      def hash
        [first_player, second_player].hash
      end
    end
  end
end
