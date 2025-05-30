# frozen_string_literal: true

module Feen
  module Dumper
    # Handles conversion of games turn data to FEEN notation string
    module GamesTurn
      # Error messages for validation
      ERRORS = {
        invalid_type:  "%s must be a String, got %s",
        empty_string:  "%s cannot be empty",
        invalid_chars: "%s must contain only alphabetic characters (a-z, A-Z)",
        mixed_case:    "%s has mixed case: %s",
        same_casing:   "One variant must be uppercase and the other lowercase"
      }.freeze

      # Converts the active and inactive variant identifiers to a FEEN-formatted games turn string
      #
      # @param active_variant [String] Identifier for the player to move and their game variant
      # @param inactive_variant [String] Identifier for the opponent and their game variant
      # @return [String] FEEN-formatted games turn string
      # @raise [ArgumentError] If the variant identifiers are invalid
      #
      # @example Valid games turn
      #   GamesTurn.dump("CHESS", "chess")
      #   # => "CHESS/chess"
      #
      # @example Invalid - same casing
      #   GamesTurn.dump("CHESS", "MAKRUK")
      #   # => ArgumentError: One variant must be uppercase and the other lowercase
      def self.dump(active_variant, inactive_variant)
        validate_variants(active_variant, inactive_variant)
        "#{active_variant}/#{inactive_variant}"
      end

      # Validates the game variant identifiers
      #
      # @param active [String] The active player's variant identifier
      # @param inactive [String] The inactive player's variant identifier
      # @raise [ArgumentError] If the variant identifiers are invalid
      # @return [void]
      private_class_method def self.validate_variants(active, inactive)
        # Validate basic type, presence and format
        [["Active variant", active], ["Inactive variant", inactive]].each do |name, variant|
          # Type validation
          raise ArgumentError, format(ERRORS[:invalid_type], name, variant.class) unless variant.is_a?(String)

          # Empty validation
          raise ArgumentError, format(ERRORS[:empty_string], name) if variant.empty?

          # Character validation
          raise ArgumentError, format(ERRORS[:invalid_chars], name) unless variant.match?(/\A[a-zA-Z]+\z/)

          # Mixed case validation
          unless variant == variant.upcase || variant == variant.downcase
            raise ArgumentError, format(ERRORS[:mixed_case], name, variant)
          end
        end

        # Casing difference validation
        active_is_uppercase = active == active.upcase
        inactive_is_uppercase = inactive == inactive.upcase

        # Both variants must have different casing
        return unless active_is_uppercase == inactive_is_uppercase

        raise ArgumentError, ERRORS[:same_casing]
      end
    end
  end
end
