# frozen_string_literal: true

require "sashite-snn"

module Feen
  module Dumper
    # Handles conversion of style turn data to FEEN notation string
    module StyleTurn
      # Error messages for validation
      ERRORS = {
        invalid_type: "%s must be a String, got %s",
        empty_string: "%s cannot be empty",
        invalid_snn:  "%s must be valid SNN notation: %s",
        same_casing:  "One style must be uppercase and the other lowercase"
      }.freeze

      # Converts the active and inactive style identifiers to a FEEN-formatted style turn string
      #
      # @param active_style [String] Identifier for the player to move and their style
      # @param inactive_style [String] Identifier for the opponent and their style
      # @return [String] FEEN-formatted style turn string
      # @raise [ArgumentError] If the style identifiers are invalid
      #
      # @example Valid style turn
      #   StyleTurn.dump("CHESS", "chess")
      #   # => "CHESS/chess"
      #
      # @example Valid style turn with variants
      #   StyleTurn.dump("CHESS960", "makruk")
      #   # => "CHESS960/makruk"
      #
      # @example Invalid - same casing
      #   StyleTurn.dump("CHESS", "MAKRUK")
      #   # => ArgumentError: One style must be uppercase and the other lowercase
      def self.dump(active_style, inactive_style)
        validate_styles(active_style, inactive_style)
        "#{active_style}/#{inactive_style}"
      end

      # Validates the style identifiers according to SNN specification
      #
      # @param active [String] The active player's style identifier
      # @param inactive [String] The inactive player's style identifier
      # @raise [ArgumentError] If the style identifiers are invalid
      # @return [void]
      private_class_method def self.validate_styles(active, inactive)
        # Validate basic type and SNN format
        [["Active style", active], ["Inactive style", inactive]].each do |name, style|
          # Type validation
          raise ArgumentError, format(ERRORS[:invalid_type], name, style.class) unless style.is_a?(::String)

          # Empty validation
          raise ArgumentError, format(ERRORS[:empty_string], name) if style.empty?

          # SNN format validation using the sashite-snn gem
          # @see https://rubygems.org/gems/sashite-snn
          raise ArgumentError, format(ERRORS[:invalid_snn], name, style) unless ::Sashite::Snn.valid?(style)
        end

        # Casing difference validation
        active_is_uppercase = active == active.upcase
        inactive_is_uppercase = inactive == inactive.upcase

        # Both styles must have different casing
        return unless active_is_uppercase == inactive_is_uppercase

        raise ArgumentError, ERRORS[:same_casing]
      end
    end
  end
end
