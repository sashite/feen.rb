# frozen_string_literal: true

require "sashite-snn"

module Feen
  module Parser
    # Handles parsing of the style turn section of a FEEN string
    module StyleTurn
      # Error messages for style turn parsing
      ERRORS = {
        invalid_type:   "Style turn must be a string, got %s",
        empty_string:   "Style turn string cannot be empty",
        invalid_format: "Invalid style turn format. Expected format: UPPERCASE/lowercase or lowercase/UPPERCASE",
        invalid_snn:    "Invalid SNN notation in style turn: %s"
      }.freeze

      # Pattern matching the FEEN specification for style turn
      # <style-turn> ::= <style-id-uppercase> "/" <style-id-lowercase>
      #                | <style-id-lowercase> "/" <style-id-uppercase>
      VALID_STYLE_TURN_PATTERN = %r{
        \A                                    # Start of string
        (?:                                   # Non-capturing group for alternatives
          (?<uppercase_first>[A-Z][A-Z0-9]*) # Named group: uppercase style identifier first
          /                                   # Separator
          (?<lowercase_second>[a-z][a-z0-9]*) # Named group: lowercase style identifier second
          |                                   # OR
          (?<lowercase_first>[a-z][a-z0-9]*) # Named group: lowercase style identifier first
          /                                   # Separator
          (?<uppercase_second>[A-Z][A-Z0-9]*) # Named group: uppercase style identifier second
        )
        \z                                    # End of string
      }x

      # Parses the style turn section of a FEEN string
      #
      # @param style_turn_str [String] FEEN style turn string
      # @return [Array<String>] Array containing [active_style, inactive_style]
      # @raise [ArgumentError] If the input string is invalid
      #
      # @example Valid style turn string with uppercase first
      #   StyleTurn.parse("CHESS/shogi")
      #   # => ["CHESS", "shogi"]
      #
      # @example Valid style turn string with lowercase first
      #   StyleTurn.parse("chess/SHOGI")
      #   # => ["chess", "SHOGI"]
      #
      # @example Valid style turn with numeric identifiers
      #   StyleTurn.parse("CHESS960/makruk")
      #   # => ["CHESS960", "makruk"]
      def self.parse(style_turn_str)
        validate_input_type(style_turn_str)

        match = VALID_STYLE_TURN_PATTERN.match(style_turn_str)
        raise ::ArgumentError, ERRORS[:invalid_format] unless match

        style_identifiers = extract_style_identifiers(match)
        validate_snn_compliance(style_identifiers)

        style_identifiers
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

      # Extracts style identifiers from regexp match captures
      #
      # @param match [MatchData] Regexp match data with named captures
      # @return [Array<String>] Array containing [active_style, inactive_style]
      private_class_method def self.extract_style_identifiers(match)
        captures = match.named_captures

        if captures["uppercase_first"]
          [captures["uppercase_first"], captures["lowercase_second"]]
        else
          [captures["lowercase_first"], captures["uppercase_second"]]
        end
      end

      # Validates that both style identifiers comply with SNN specification
      #
      # @param identifiers [Array<String>] Array of style identifiers to validate
      # @raise [ArgumentError] If any identifier is invalid SNN notation
      # @return [void]
      private_class_method def self.validate_snn_compliance(identifiers)
        identifiers.each do |identifier|
          # Validate using the sashite-snn gem
          # @see https://rubygems.org/gems/sashite-snn
          raise ::ArgumentError, format(ERRORS[:invalid_snn], identifier) unless ::Sashite::Snn.valid?(identifier)
        end
      end
    end
  end
end
