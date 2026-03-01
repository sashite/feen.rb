# frozen_string_literal: true

require_relative "feen/parser"
require_relative "feen/dumper"

module Sashite
  # FEEN (Field Expression Encoding Notation) implementation for Ruby.
  #
  # Provides serialization and deserialization of board game positions
  # between FEEN strings and Qi objects.
  #
  # @see https://sashite.dev/specs/feen/1.0.0/
  # @api public
  module Feen
    # Parses a FEEN string into a Qi position.
    #
    # @param feen_string [String] The FEEN string to parse
    # @return [Qi] An immutable position object
    # @raise [ParseError] If the string is not a valid FEEN
    def self.parse(feen_string)
      Parser.parse(feen_string)
    end

    # Reports whether a string is a valid FEEN position.
    #
    # @param feen_string [String] The string to validate
    # @return [Boolean] true if valid, false otherwise
    def self.valid?(feen_string)
      Parser.valid?(feen_string)
    end

    # Serializes a Qi position to a canonical FEEN string.
    #
    # @param position [Qi] The position to serialize
    # @return [String] Canonical FEEN string
    def self.dump(position)
      Dumper.dump(position)
    end
  end
end
