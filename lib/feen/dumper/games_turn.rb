# frozen_string_literal: true

module Feen
  module Dumper
    # Handles conversion of games turn data structure to FEEN notation string
    module GamesTurn
      ERRORS = {
        missing_key:        "Missing required key in games_turn: %s",
        invalid_type:       "Invalid type for games_turn[%s]: expected String, got %s",
        empty_string:       "Empty string for games_turn[%s]",
        casing_requirement: "One game must be uppercase and the other lowercase",
        invalid_chars:      "Game identifiers must contain only alphabetic characters (a-z, A-Z)"
      }.freeze

      REQUIRED_KEYS = %i[active_player inactive_player].freeze

      # Converts the internal games turn representation to a FEEN string
      #
      # @param games_turn [Hash] Hash containing game turn information
      # @return [String] FEEN-formatted games turn string
      def self.dump(games_turn)
        validate_games_turn(games_turn)

        # Format is <active_player>/<inactive_player>
        "#{games_turn[:active_player]}/#{games_turn[:inactive_player]}"
      end

      # Validates the games turn data structure
      #
      # @param games_turn [Hash] The games turn data to validate
      # @raise [ArgumentError] If the games turn data is invalid
      # @return [Boolean] true if the validation passes
      def self.validate_games_turn(games_turn)
        validate_structure(games_turn)
        validate_casing(games_turn)
        validate_character_set(games_turn)

        true
      end

      # Validates the basic structure of games_turn
      #
      # @param games_turn [Hash] The games turn data to validate
      # @raise [ArgumentError] If the structure is invalid
      # @return [void]
      private_class_method def self.validate_structure(games_turn)
        REQUIRED_KEYS.each do |key|
          raise ArgumentError, format(ERRORS[:missing_key], key) unless games_turn.key?(key)

          unless games_turn[key].is_a?(String)
            raise ArgumentError, format(ERRORS[:invalid_type], key, games_turn[key].class)
          end

          raise ArgumentError, format(ERRORS[:empty_string], key) if games_turn[key].empty?
        end
      end

      # Validates the casing requirement (one uppercase, one lowercase)
      #
      # @param games_turn [Hash] The games turn data to validate
      # @raise [ArgumentError] If the casing requirement is not met
      # @return [void]
      private_class_method def self.validate_casing(games_turn)
        active_has_uppercase = games_turn[:active_player].match?(/[A-Z]/)
        inactive_has_uppercase = games_turn[:inactive_player].match?(/[A-Z]/)

        # Ensure exactly one has uppercase
        raise ArgumentError, ERRORS[:casing_requirement] if active_has_uppercase == inactive_has_uppercase

        # Check that uppercase game is all caps and lowercase game has no caps
        if active_has_uppercase && games_turn[:active_player].match?(/[a-z]/)
          raise ArgumentError, "Active game has mixed case: #{games_turn[:active_player]}"
        end

        return unless inactive_has_uppercase && games_turn[:inactive_player].match?(/[a-z]/)

        raise ArgumentError, "Inactive game has mixed case: #{games_turn[:inactive_player]}"
      end

      # Validates that identifiers only contain allowed characters
      #
      # @param games_turn [Hash] The games turn data to validate
      # @raise [ArgumentError] If invalid characters are present
      # @return [void]
      private_class_method def self.validate_character_set(games_turn)
        REQUIRED_KEYS.each do |key|
          raise ArgumentError, ERRORS[:invalid_chars] unless games_turn[key].match?(/\A[a-zA-Z]+\z/)
        end
      end
    end
  end
end
