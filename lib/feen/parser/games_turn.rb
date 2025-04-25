# frozen_string_literal: true

module Feen
  module Parser
    # Handles parsing of the games turn section of a FEEN string
    module GamesTurn
      ERRORS = {
        invalid_type:       "Games turn must be a string, got %s",
        empty_string:       "Games turn string cannot be empty",
        separator:          "Games turn must contain exactly one '/' separator",
        mixed_casing:       "%s game has mixed case: %s",
        casing_requirement: "One game must use uppercase letters and the other lowercase letters",
        invalid_chars:      "Invalid characters in %s game identifier: %s",
        empty_identifier:   "%s game identifier cannot be empty"
      }.freeze

      # Parses the games turn section of a FEEN string
      #
      # @param games_turn_str [String] FEEN games turn string
      # @return [Hash] Hash containing game turn information
      # @raise [ArgumentError] If the input string is invalid
      def self.parse(games_turn_str)
        validate_games_turn_string(games_turn_str)

        # Split by the forward slash
        parts = games_turn_str.split("/")
        active_player = parts[0]
        inactive_player = parts[1]

        # Determine casing
        active_uppercase = contains_uppercase?(active_player)

        # Build result hash
        {
          active_player:        active_player,
          inactive_player:      inactive_player,
          uppercase_game:       active_uppercase ? active_player : inactive_player,
          lowercase_game:       active_uppercase ? inactive_player : active_player,
          active_player_casing: active_uppercase ? :uppercase : :lowercase
        }
      end

      # Validates the games turn string for syntax and semantics
      #
      # @param str [String] FEEN games turn string
      # @raise [ArgumentError] If the string is invalid
      # @return [void]
      def self.validate_games_turn_string(str)
        validate_basic_structure(str)

        parts = str.split("/")
        validate_game_identifiers(parts)
        validate_casing_requirements(parts)
      end

      # Validates the basic structure of the games turn string
      #
      # @param str [String] FEEN games turn string
      # @raise [ArgumentError] If the structure is invalid
      # @return [void]
      private_class_method def self.validate_basic_structure(str)
        raise ArgumentError, format(ERRORS[:invalid_type], str.class) unless str.is_a?(String)

        raise ArgumentError, ERRORS[:empty_string] if str.empty?

        # Check for exactly one separator '/'
        return if str.count("/") == 1

        raise ArgumentError, ERRORS[:separator]
      end

      # Validates the individual game identifiers
      #
      # @param parts [Array<String>] Split game identifiers
      # @raise [ArgumentError] If any identifier is invalid
      # @return [void]
      private_class_method def self.validate_game_identifiers(parts)
        parts.each_with_index do |game_id, idx|
          position = idx == 0 ? "active" : "inactive"

          raise ArgumentError, format(ERRORS[:empty_identifier], position.capitalize) if game_id.nil? || game_id.empty?

          unless game_id.match?(/\A[a-zA-Z]+\z/)
            invalid_chars = game_id.scan(/[^a-zA-Z]/).uniq.join(", ")
            raise ArgumentError, format(ERRORS[:invalid_chars], position, invalid_chars)
          end
        end
      end

      # Validates the casing requirements (one uppercase, one lowercase)
      #
      # @param parts [Array<String>] Split game identifiers
      # @raise [ArgumentError] If casing requirements aren't met
      # @return [void]
      private_class_method def self.validate_casing_requirements(parts)
        active_uppercase = contains_uppercase?(parts[0])
        inactive_uppercase = contains_uppercase?(parts[1])

        raise ArgumentError, ERRORS[:casing_requirement] if active_uppercase == inactive_uppercase

        # Verify consistent casing in each identifier
        if active_uppercase && contains_lowercase?(parts[0])
          raise ArgumentError, format(ERRORS[:mixed_casing], "Active", parts[0])
        end

        if inactive_uppercase && contains_lowercase?(parts[1])
          raise ArgumentError, format(ERRORS[:mixed_casing], "Inactive", parts[1])
        end

        if !active_uppercase && contains_uppercase?(parts[0])
          raise ArgumentError, format(ERRORS[:mixed_casing], "Active", parts[0])
        end

        return unless !inactive_uppercase && contains_uppercase?(parts[1])

        raise ArgumentError, format(ERRORS[:mixed_casing], "Inactive", parts[1])
      end

      # Checks if a string contains any uppercase letters
      #
      # @param str [String] String to check
      # @return [Boolean] True if the string contains uppercase letters
      def self.contains_uppercase?(str)
        str.match?(/[A-Z]/)
      end

      # Checks if a string contains any lowercase letters
      #
      # @param str [String] String to check
      # @return [Boolean] True if the string contains lowercase letters
      def self.contains_lowercase?(str)
        str.match?(/[a-z]/)
      end
    end
  end
end
