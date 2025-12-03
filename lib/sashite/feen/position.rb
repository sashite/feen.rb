# frozen_string_literal: true

module Sashite
  module Feen
    # Immutable representation of a complete board game position.
    #
    # Combines piece placement, pieces in hand, and style-turn information
    # into a single unified position object. This represents a complete
    # snapshot of the game state at a given moment.
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    class Position
      # @return [Placement] Board piece placement configuration
      attr_reader :placement

      # @return [Hands] Pieces held in hand by each player
      attr_reader :hands

      # @return [Styles] Game styles and active player indicator
      attr_reader :styles

      # Create a new immutable Position object.
      #
      # @param placement [Placement] Board configuration
      # @param hands [Hands] Captured pieces in hand
      # @param styles [Styles] Style-turn information
      #
      # @example Create a chess starting position
      #   position = Position.new(placement, hands, styles)
      #
      # @example Parse from FEEN string
      #   position = Sashite::Feen.parse("+rnbq+k^bn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+K^BN+R / C/c")
      def initialize(placement, hands, styles)
        @placement = placement
        @hands = hands
        @styles = styles

        freeze
      end

      # Convert position to its canonical FEEN string representation.
      #
      # Generates a deterministic FEEN string. The same position will
      # always produce the same canonical string, enabling position
      # equality via string comparison.
      #
      # @return [String] Canonical FEEN notation string
      #
      # @example
      #   position.to_s
      #   # => "+rnbq+k^bn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+K^BN+R / C/c"
      def to_s
        Dumper.dump(self)
      end

      # Compare two positions for equality.
      #
      # @param other [Position] Another position object
      # @return [Boolean] True if all components are equal
      def ==(other)
        other.is_a?(Position) &&
          placement == other.placement &&
          hands == other.hands &&
          styles == other.styles
      end

      alias eql? ==

      # Generate hash code for position.
      #
      # @return [Integer] Hash code based on all components
      def hash
        [placement, hands, styles].hash
      end
    end
  end
end
