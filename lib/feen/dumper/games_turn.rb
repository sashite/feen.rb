# frozen_string_literal: true

module Feen
  module Dumper
    # Handles conversion of games turn data to FEEN notation string
    module GamesTurn
      ERRORS = {
        type:   "%s must be a String, got %s",
        empty:  "%s cannot be empty",
        mixed:  "%s has mixed case: %s",
        casing: "One variant must be uppercase and the other lowercase",
        chars:  "Variant identifiers must contain only alphabetic characters (a-z, A-Z)"
      }.freeze

      # Converts the active and inactive variant identifiers to a FEEN-formatted games turn string
      #
      # @param active_variant [String] Identifier for the player to move and their game variant
      # @param inactive_variant [String] Identifier for the opponent and their game variant
      # @return [String] FEEN-formatted games turn string
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
        # Validate basic type and presence
        [["Active variant", active], ["Inactive variant", inactive]].each do |name, variant|
          raise ArgumentError, format(ERRORS[:type], name, variant.class) unless variant.is_a?(String)
          raise ArgumentError, format(ERRORS[:empty], name) if variant.empty?
          raise ArgumentError, ERRORS[:chars] unless variant.match?(/\A[a-zA-Z]+\z/)
        end

        # Validate casing (one must be uppercase, one must be lowercase)
        active_uppercase = active == active.upcase && active != active.downcase
        inactive_uppercase = inactive == inactive.upcase && inactive != inactive.downcase

        # If both have the same casing (both uppercase or both lowercase), raise error
        raise ArgumentError, ERRORS[:casing] if active_uppercase == inactive_uppercase

        # Check for mixed case (must be all uppercase or all lowercase)
        if active_uppercase && active != active.upcase
          raise ArgumentError, format(ERRORS[:mixed], "Active variant", active)
        end

        if inactive_uppercase && inactive != inactive.upcase
          raise ArgumentError, format(ERRORS[:mixed], "Inactive variant", inactive)
        end

        if !active_uppercase && active != active.downcase
          raise ArgumentError, format(ERRORS[:mixed], "Active variant", active)
        end

        if !inactive_uppercase && inactive != inactive.downcase
          raise ArgumentError, format(ERRORS[:mixed], "Inactive variant", inactive)
        end

        true
      end
    end
  end
end
