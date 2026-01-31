# frozen_string_literal: true

require_relative "../constants"

module Sashite
  module Feen
    class Position
      # Represents player styles and the active player.
      #
      # StyleTurn encapsulates the parsed data from FEEN Field 3,
      # providing access to each player's style and turn information.
      #
      # The active player is the one whose turn it is to move.
      # Player sides are determined by case:
      # - Uppercase (A-Z): first player
      # - Lowercase (a-z): second player
      #
      # Instances are immutable (frozen after creation) and thread-safe.
      #
      # @api public
      #
      # @example Querying turn
      #   style_turn = position.style_turn
      #   style_turn.first_to_move?   # => true
      #   style_turn.second_to_move?  # => false
      #
      # @example Accessing styles
      #   style_turn.active_style    # => Sashite::Sin::Identifier (C)
      #   style_turn.inactive_style  # => Sashite::Sin::Identifier (c)
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      class StyleTurn
        # @return [Sashite::Sin::Identifier] Active player's style
        attr_reader :active_style

        # @return [Sashite::Sin::Identifier] Inactive player's style
        attr_reader :inactive_style

        # Creates a new StyleTurn instance.
        #
        # @param active [Sashite::Sin::Identifier] Active player's style
        # @param inactive [Sashite::Sin::Identifier] Inactive player's style
        # @return [StyleTurn] A new frozen instance
        def initialize(active:, inactive:)
          @active_style = active
          @inactive_style = inactive

          freeze
        end

        # Returns true if the first player is to move.
        #
        # The first player is identified by an uppercase style token.
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
        # The second player is identified by a lowercase style token.
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
          "#{active_style}#{Constants::SEGMENT_SEPARATOR}#{inactive_style}"
        end

        # Checks equality with another StyleTurn.
        #
        # @param other [Object] The object to compare
        # @return [Boolean] true if equal
        def ==(other)
          return false unless self.class === other

          active_style == other.active_style && inactive_style == other.inactive_style
        end

        alias eql? ==

        # Returns a hash code for the StyleTurn.
        #
        # @return [Integer] Hash code
        def hash
          [active_style, inactive_style].hash
        end

        # Returns an inspect string for the StyleTurn.
        #
        # @return [String] Inspect representation
        def inspect
          "#<#{self.class} #{self}>"
        end
      end
    end
  end
end
