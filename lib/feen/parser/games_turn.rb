# frozen_string_literal: true

module Feen
  module Parser
    # Handles parsing of the games turn section of a FEEN string
    module GamesTurn
      # Error messages for games turn parsing
      ERRORS = {
        invalid_type:   "Games turn must be a string, got %s",
        empty_string:   "Games turn string cannot be empty",
        invalid_format: "Invalid games turn format. Expected format: UPPERCASE/lowercase or lowercase/UPPERCASE"
      }.freeze

      # Pattern matching the FEEN specification for games turn
      # <games-turn> ::= <game-id-uppercase> "/" <game-id-lowercase>
      #                | <game-id-lowercase> "/" <game-id-uppercase>
      VALID_GAMES_TURN_PATTERN = %r{
        \A                    # Start of string
        (?:                   # Non-capturing group for alternatives
          (?<uppercase_first>[A-Z]+)  # Named group: uppercase identifier first
          /                           # Separator
          (?<lowercase_second>[a-z]+) # Named group: lowercase identifier second
          |                           # OR
          (?<lowercase_first>[a-z]+)  # Named group: lowercase identifier first
          /                           # Separator
          (?<uppercase_second>[A-Z]+) # Named group: uppercase identifier second
        )
        \z                    # End of string
      }x

      # Parses the games turn section of a FEEN string
      #
      # @param games_turn_str [String] FEEN games turn string
      # @return [Array<String>] Array containing [active_player, inactive_player]
      # @raise [ArgumentError] If the input string is invalid
      #
      # @example Valid games turn string with uppercase first
      #   GamesTurn.parse("CHESS/shogi")
      #   # => ["CHESS", "shogi"]
      #
      # @example Valid games turn string with lowercase first
      #   GamesTurn.parse("chess/SHOGI")
      #   # => ["chess", "SHOGI"]
      def self.parse(games_turn_str)
        validate_input_type(games_turn_str)

        match = VALID_GAMES_TURN_PATTERN.match(games_turn_str)
        raise ::ArgumentError, ERRORS[:invalid_format] unless match

        extract_game_identifiers(match)
      end

      # Validates that the input is a non-empty string
      #
      # @param str [String] Input string to validate
      # @raise [ArgumentError] If input is not a string or is empty
      # @return [void]
      private_class_method def self.validate_input_type(str)
        raise ::ArgumentError, format(ERRORS[:invalid_type], str.class) unless str.is_a?(::String)
        raise ::ArgumentError, ERRORS[:empty_string] if str.empty?
      end

      # Extracts game identifiers from regexp match captures
      #
      # @param match [MatchData] Regexp match data with named captures
      # @return [Array<String>] Array containing [active_player, inactive_player]
      private_class_method def self.extract_game_identifiers(match)
        captures = match.named_captures

        if captures["uppercase_first"]
          [captures["uppercase_first"], captures["lowercase_second"]]
        else
          [captures["lowercase_first"], captures["uppercase_second"]]
        end
      end
    end
  end
end
