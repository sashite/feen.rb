# frozen_string_literal: true

module Feen
  module Parser
    # Handles parsing of the games turn section of a FEEN string
    module GamesTurn
      # Complete pattern matching the BNF specification with named groups
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

      # Error messages
      ERRORS = {
        invalid_type:   "Games turn must be a string, got %s",
        empty_string:   "Games turn string cannot be empty",
        invalid_format: "Invalid games turn format. Expected format: UPPERCASE/lowercase or lowercase/UPPERCASE"
      }.freeze

      # Parses the games turn section of a FEEN string
      #
      # @param games_turn_str [String] FEEN games turn string
      # @return [Hash] Hash containing game turn information with keys:
      #   - :active_player [String] The player to move
      #   - :inactive_player [String] The opponent
      #   - :active_player_uppercase? [Boolean] Whether active player uses uppercase pieces
      # @raise [ArgumentError] If the input string is invalid
      #
      # @example Valid games turn string with uppercase first
      #   GamesTurn.parse("CHESS/shogi")
      #   # => {
      #   #      active_player: "CHESS",
      #   #      inactive_player: "shogi",
      #   #      active_player_uppercase?: true
      #   #    }
      #
      # @example Valid games turn string with lowercase first
      #   GamesTurn.parse("chess/SHOGI")
      #   # => {
      #   #      active_player: "chess",
      #   #      inactive_player: "SHOGI",
      #   #      active_player_uppercase?: false
      #   #    }
      def self.parse(games_turn_str)
        validate_input_type(games_turn_str)

        match = VALID_GAMES_TURN_PATTERN.match(games_turn_str)
        raise ::ArgumentError, ERRORS[:invalid_format] unless match

        extract_game_identifiers(**match.named_captures.transform_keys(&:to_sym))
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
      # @param uppercase_first [String, nil] Uppercase identifier if it comes first
      # @param lowercase_second [String, nil] Lowercase identifier if it comes second
      # @param lowercase_first [String, nil] Lowercase identifier if it comes first
      # @param uppercase_second [String, nil] Uppercase identifier if it comes second
      # @return [Hash] Parsed game turn information
      private_class_method def self.extract_game_identifiers(uppercase_first: nil, lowercase_second: nil, lowercase_first: nil, uppercase_second: nil)
        if uppercase_first
          {
            active_player:            uppercase_first,
            inactive_player:          lowercase_second,
            active_player_uppercase?: true
          }
        else
          {
            active_player:            lowercase_first,
            inactive_player:          uppercase_second,
            active_player_uppercase?: false
          }
        end
      end
    end
  end
end
