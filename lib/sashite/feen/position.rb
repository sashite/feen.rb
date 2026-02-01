# frozen_string_literal: true

require_relative "shared/separators"
require_relative "position/hands"
require_relative "position/piece_placement"
require_relative "position/style_turn"

module Sashite
  module Feen
    # Represents a complete FEEN position.
    #
    # A Position encapsulates the three FEEN fields:
    # - Piece Placement: Board structure and occupancy
    # - Hands: Off-board pieces held by each player
    # - Style-Turn: Player styles and active player
    #
    # Instances are immutable (frozen after creation) and thread-safe.
    #
    # @api public
    #
    # @example Accessing components
    #   position.piece_placement  # => PiecePlacement
    #   position.hands            # => Hands
    #   position.style_turn       # => StyleTurn
    #
    # @example Querying metrics
    #   position.squares_count  # => 64
    #   position.pieces_count   # => 32
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    class Position
      # @return [PiecePlacement] Board structure and occupancy
      attr_reader :piece_placement

      # @return [Hands] Off-board pieces
      attr_reader :hands

      # @return [StyleTurn] Player styles and active player
      attr_reader :style_turn

      # Creates a new Position instance from parsed components.
      #
      # @param piece_placement [Hash] Parsed piece placement with :segments and :separators
      # @param hands [Hash] Parsed hands with :first and :second
      # @param style_turn [Hash] Parsed style-turn with :active and :inactive
      # @return [Position] A new frozen instance
      # @raise [ArgumentError] If any component is invalid
      def initialize(piece_placement:, hands:, style_turn:)
        @piece_placement = PiecePlacement.send(:new, **piece_placement)
        @hands = Hands.send(:new, **hands)
        @style_turn = StyleTurn.send(:new, **style_turn)

        freeze
      end

      # Returns the total number of squares on the board.
      #
      # @return [Integer] Total square count
      #
      # @example
      #   position.squares_count  # => 64
      def squares_count
        piece_placement.squares_count
      end

      # Returns the total number of pieces (board + hands).
      #
      # @return [Integer] Total piece count
      #
      # @example
      #   position.pieces_count  # => 32
      def pieces_count
        piece_placement.pieces_count + hands.pieces_count
      end

      # Returns the canonical FEEN string representation.
      #
      # @return [String] The FEEN string
      #
      # @example
      #   position.to_s  # => "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
      def to_s
        [
          piece_placement.to_s,
          hands.to_s,
          style_turn.to_s
        ].join(Separators::FIELD)
      end

      # Checks equality with another Position.
      #
      # @param other [Object] The object to compare
      # @return [Boolean] true if equal
      def ==(other)
        return false unless self.class === other
        return false unless piece_placement == other.piece_placement
        return false unless hands == other.hands

        style_turn == other.style_turn
      end

      alias eql? ==

      # Returns a hash code for the Position.
      #
      # @return [Integer] Hash code
      def hash
        [self.class, piece_placement, hands, style_turn].hash
      end

      # Returns an inspect string for the Position.
      #
      # @return [String] Inspect representation
      def inspect
        "#<#{self.class} #{self}>"
      end
    end
  end
end
