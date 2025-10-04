# frozen_string_literal: true

require_relative "../error"
require_relative "../styles"

require "sashite/sin"

module Sashite
  module Feen
    module Parser
      # Parser for the style-turn field (third field of FEEN).
      #
      # Converts a FEEN style-turn string into a Styles object,
      # decoding game style identifiers and the active player indicator.
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @see https://sashite.dev/specs/sin/1.0.0/
      module StyleTurn
        # Style separator in style-turn field.
        STYLE_SEPARATOR = "/"

        # Parse a FEEN style-turn string into a Styles object.
        #
        # @param string [String] FEEN style-turn field string
        # @return [Styles] Parsed styles object
        # @raise [Error::Syntax] If style-turn format is invalid
        # @raise [Error::Style] If SIN notation is invalid
        #
        # @example Chess game, white to move
        #   parse("C/c")  # => Styles.new(sin_C, sin_c)
        #
        # @example Chess game, black to move
        #   parse("c/C")  # => Styles.new(sin_c, sin_C)
        #
        # @example Cross-style game, first player to move
        #   parse("C/m")  # => Styles.new(sin_C, sin_m)
        def self.parse(string)
          active_str, inactive_str = split_styles(string)

          active = parse_style(active_str)
          inactive = parse_style(inactive_str)

          Styles.new(active, inactive)
        end

        # Split style-turn string into active and inactive parts.
        #
        # @param string [String] Style-turn field string
        # @return [Array(String, String)] Active and inactive style strings
        # @raise [Error::Syntax] If separator is missing or format is invalid
        #
        # @example
        #   split_styles("C/c")  # => ["C", "c"]
        #   split_styles("S/m")  # => ["S", "m"]
        private_class_method def self.split_styles(string)
          parts = string.split(STYLE_SEPARATOR, 2)

          raise Error::Syntax, "style-turn must contain '#{STYLE_SEPARATOR}' separator" unless parts.size == 2

          raise Error::Syntax, "active style cannot be empty" if parts[0].empty?
          raise Error::Syntax, "inactive style cannot be empty" if parts[1].empty?

          parts
        end

        # Parse a SIN string into a style identifier object.
        #
        # @param sin_str [String] SIN notation string (single letter)
        # @return [Object] Style identifier object
        # @raise [Error::Style] If SIN is invalid
        #
        # @example
        #   parse_style("C")  # => Sin::Identifier (Chess, first player)
        #   parse_style("c")  # => Sin::Identifier (Chess, second player)
        #   parse_style("S")  # => Sin::Identifier (Shogi, first player)
        private_class_method def self.parse_style(sin_str)
          unless valid_sin_format?(sin_str)
            raise Error::Style, "invalid SIN notation: '#{sin_str}' (must be a single letter A-Z or a-z)"
          end

          Sashite::Sin.parse(sin_str)
        rescue ::StandardError => e
          raise Error::Style, "failed to parse SIN '#{sin_str}': #{e.message}"
        end

        # Check if string is a valid SIN format.
        #
        # @param string [String] String to validate
        # @return [Boolean] True if string is a single ASCII letter
        private_class_method def self.valid_sin_format?(string)
          string.length == 1 && letter?(string[0])
        end

        # Check if character is a letter.
        #
        # @param char [String] Single character
        # @return [Boolean] True if character is A-Z or a-z
        private_class_method def self.letter?(char)
          (char >= "A" && char <= "Z") || (char >= "a" && char <= "z")
        end
      end
    end
  end
end
