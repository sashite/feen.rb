# frozen_string_literal: true

module Sashite
  module Feen
    # Immutable representation of game styles and active player.
    #
    # Stores the style identifiers (SIN) for both players, with the active
    # player's style indicating whose turn it is to move. The case of each
    # style identifier indicates which player uses it (uppercase = first player,
    # lowercase = second player).
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    # @see https://sashite.dev/specs/sin/1.0.0/
    class Styles
      # @return [Object] Style identifier of the active player (to move)
      attr_reader :active

      # @return [Object] Style identifier of the inactive player (waiting)
      attr_reader :inactive

      # Create a new immutable Styles object.
      #
      # @param active [Object] SIN identifier for active player's style
      # @param inactive [Object] SIN identifier for inactive player's style
      #
      # @example Chess game, white to move
      #   styles = Styles.new(sin_C, sin_c)
      #
      # @example Chess game, black to move
      #   styles = Styles.new(sin_c, sin_C)
      #
      # @example Cross-style game, first player to move
      #   styles = Styles.new(sin_C, sin_m)
      def initialize(active, inactive)
        @active = active
        @inactive = inactive

        freeze
      end

      # Convert styles to their FEEN string representation.
      #
      # @return [String] FEEN style-turn field
      #
      # @example
      #   styles.to_s
      #   # => "C/c"
      def to_s
        Dumper::StyleTurn.dump(self)
      end

      # Compare two styles for equality.
      #
      # @param other [Styles] Another styles object
      # @return [Boolean] True if active and inactive styles are equal
      def ==(other)
        other.is_a?(Styles) &&
          active == other.active &&
          inactive == other.inactive
      end

      alias eql? ==

      # Generate hash code for styles.
      #
      # @return [Integer] Hash code based on active and inactive styles
      def hash
        [active, inactive].hash
      end
    end
  end
end
