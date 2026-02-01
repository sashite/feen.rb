# frozen_string_literal: true

module Sashite
  module Feen
    class Position
      # Represents player styles and the active player.
      #
      # StyleTurn encapsulates parsed data from FEEN Field 3,
      # providing access to each player's style and turn information.
      #
      # The active player is the one whose turn it is to move.
      # Player sides are determined by case:
      # - Uppercase (A-Z): first player
      # - Lowercase (a-z): second player
      #
      # Instances are immutable (frozen after creation) and thread-safe.
      #
      # This class is an implementation detail of {Position} and should not
      # be instantiated directly by external code.
      #
      # @api private
      class StyleTurn
        # Separator between active and inactive styles in FEEN notation.
        SEPARATOR = "/"

        # @return [Object] Active player's style identifier
        attr_reader :active_style

        # @return [Object] Inactive player's style identifier
        attr_reader :inactive_style

        # Creates a new StyleTurn instance.
        #
        # @param active [Object] Active player's style (must respond to :side)
        # @param inactive [Object] Inactive player's style (must respond to :side)
        # @return [StyleTurn] A new frozen instance
        # @raise [ArgumentError] If active does not respond to :side
        # @raise [ArgumentError] If inactive does not respond to :side
        def initialize(active:, inactive:)
          validate_style!(active, "active")
          validate_style!(inactive, "inactive")

          @active_style = active
          @inactive_style = inactive

          freeze
        end

        # Returns true if the first player is to move.
        #
        # The first player is identified by an uppercase style token (side = :first).
        #
        # @return [Boolean] true if first player's turn
        #
        # @example
        #   style_turn.first_to_move?  # => true (for "C/c")
        def first_to_move?
          active_style.side == :first
        end

        # Returns true if the second player is to move.
        #
        # The second player is identified by a lowercase style token (side = :second).
        #
        # @return [Boolean] true if second player's turn
        #
        # @example
        #   style_turn.second_to_move?  # => true (for "c/C")
        def second_to_move?
          active_style.side == :second
        end

        # Returns the canonical FEEN string representation.
        #
        # @return [String] Canonical style-turn string (e.g., "C/c")
        #
        # @example
        #   style_turn.to_s  # => "C/c"
        def to_s
          "#{active_style}#{SEPARATOR}#{inactive_style}"
        end

        # Checks equality with another StyleTurn.
        #
        # @param other [Object] The object to compare
        # @return [Boolean] true if equal
        def ==(other)
          return false unless self.class === other
          return false unless active_style == other.active_style

          inactive_style == other.inactive_style
        end

        alias eql? ==

        # Returns a hash code for the StyleTurn.
        #
        # @return [Integer] Hash code
        def hash
          [self.class, active_style, inactive_style].hash
        end

        # Returns an inspect string for the StyleTurn.
        #
        # @return [String] Inspect representation
        def inspect
          "#<#{self.class} #{self}>"
        end

        private

        # Validates that a style responds to :side.
        #
        # @param style [Object] The style to validate
        # @param name [String] Parameter name for error message
        # @raise [ArgumentError] If style does not respond to :side
        def validate_style!(style, name)
          return if style.respond_to?(:side)

          raise ::ArgumentError, "#{name} must respond to :side"
        end

        private_class_method :new

        freeze
      end
    end
  end
end
