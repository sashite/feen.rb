# frozen_string_literal: true

require_relative "constants"
require_relative "errors"
require_relative "position/hands"
require_relative "position/piece_placement"
require_relative "position/style_turn"

module Sashite
  module Feen
    # Represents a parsed FEEN (Field Expression Encoding Notation) position.
    #
    # A Position encapsulates the three FEEN fields:
    # - Piece Placement: Board occupancy
    # - Hands: Off-board pieces held by each player
    # - Style-Turn: Player styles and active player
    #
    # Instances are immutable (frozen after creation).
    #
    # @example Creating a position
    #   position = Sashite::Feen.parse("lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s")
    #   position.to_s  # => "lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s"
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    class Position
      # @return [PiecePlacement] Board occupancy
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
      # @return [Position] A new frozen Position instance
      def initialize(piece_placement:, hands:, style_turn:)
        @piece_placement = PiecePlacement.new(**piece_placement)
        @hands = Hands.new(**hands)
        @style_turn = StyleTurn.new(**style_turn)

        freeze
      end

      # Returns the canonical FEEN string representation.
      #
      # @return [String] The FEEN string
      def to_s
        [
          piece_placement.to_s,
          hands.to_s,
          style_turn.to_s
        ].join(Constants::FIELD_SEPARATOR)
      end

      # Checks equality with another Position.
      #
      # @param other [Object] The object to compare
      # @return [Boolean] true if equal
      def ==(other)
        return false unless self.class === other

        piece_placement == other.piece_placement &&
          hands == other.hands &&
          style_turn == other.style_turn
      end

      alias eql? ==

      # Returns a hash code for the Position.
      #
      # @return [Integer] Hash code
      def hash
        [piece_placement, hands, style_turn].hash
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
