# frozen_string_literal: true

require_relative File.join("games_turn", "valid_games_turn_pattern")
require_relative File.join("games_turn", "errors")

module Feen
  module Parser
    # Handles parsing of the games turn section of a FEEN string
    module GamesTurn
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

        match = ValidGamesTurnPattern.match(games_turn_str)
        raise ::ArgumentError, Errors[:invalid_format] unless match

        extract_game_identifiers(**match.named_captures.transform_keys(&:to_sym))
      end

      # Validates that the input is a non-empty string
      #
      # @param str [String] Input string to validate
      # @raise [ArgumentError] If input is not a string or is empty
      # @return [void]
      private_class_method def self.validate_input_type(str)
        raise ::ArgumentError, format(Errors[:invalid_type], str.class) unless str.is_a?(::String)
        raise ::ArgumentError, Errors[:empty_string] if str.empty?
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
