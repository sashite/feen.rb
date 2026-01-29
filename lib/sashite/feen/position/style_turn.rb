# frozen_string_literal: true

require_relative "../constants"

module Sashite
  module Feen
    class Position
      # Represents the Style-Turn field (Field 3).
      #
      # Encapsulates player styles and active player information.
      #
      # @example
      #   st = StyleTurn.new(active: <Sin C>, inactive: <Sin c>)
      #   st.first_to_move?  # => true
      #   st.to_s            # => "C/c"
      class StyleTurn
        # @return [Sashite::Sin::Identifier] Active player's style
        attr_reader :active_style

        # @return [Sashite::Sin::Identifier] Inactive player's style
        attr_reader :inactive_style

        # Creates a new StyleTurn instance.
        #
        # @param active [Sashite::Sin::Identifier] Active player's style
        # @param inactive [Sashite::Sin::Identifier] Inactive player's style
        def initialize(active:, inactive:)
          @active_style = active
          @inactive_style = inactive

          freeze
        end

        # Returns true if first player is to move.
        #
        # @return [Boolean]
        def first_to_move?
          active_style.side == :first
        end

        # Returns true if second player is to move.
        #
        # @return [Boolean]
        def second_to_move?
          active_style.side == :second
        end

        # Returns the canonical string representation.
        #
        # @return [String] The style-turn string
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

        # Returns a hash code.
        #
        # @return [Integer] Hash code
        def hash
          [active_style, inactive_style].hash
        end
      end
    end
  end
end
