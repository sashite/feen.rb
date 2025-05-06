# frozen_string_literal: true

module Feen
  # Represents a piece in the FEEN specification
  class Piece
    # Valid piece identifiers (a-z, A-Z)
    VALID_IDENTIFIERS = ("a".."z").to_a + ("A".."Z").to_a

    # Valid prefixes
    VALID_PREFIXES = ["+", "-", nil].freeze

    # Valid suffixes
    VALID_SUFFIXES = ["=", "<", ">", nil].freeze

    # Regular expression for validating piece strings
    PIECE_REGEX = /\A[+\-]?[a-zA-Z][=<>]?\z/

    # Readonly accessors for piece properties
    attr_reader :identifier, :prefix, :suffix

    # Initialize a new Piece
    #
    # @param identifier [String] The piece identifier (a-z, A-Z)
    # @param prefix [String, nil] Optional prefix (+, -)
    # @param suffix [String, nil] Optional suffix (=, <, >)
    def initialize(identifier, prefix: nil, suffix: nil)
      validate_identifier(identifier)
      validate_prefix(prefix)
      validate_suffix(suffix)

      @identifier = identifier
      @prefix = prefix
      @suffix = suffix

      freeze
    end

    # Parse a FEEN piece string into a Piece instance
    #
    # @param piece_string [String] The FEEN piece string to parse
    # @return [Piece] A new Piece instance
    def self.parse(piece_string)
      validate_piece_string(piece_string)

      properties = extract_piece_components(piece_string)

      new(
        properties[:identifier],
        prefix: properties[:prefix],
        suffix: properties[:suffix]
      )
    end

    # Returns the string representation of the piece according to FEEN
    #
    # @return [String] FEEN representation of the piece
    def to_s
      "#{prefix}#{identifier}#{suffix}"
    end

    # Returns a hash representation of the piece
    #
    # @return [Hash] Hash with :identifier, :prefix, and :suffix keys
    def to_h
      {
        identifier: identifier,
        prefix:     prefix,
        suffix:     suffix
      }
    end

    # Returns true if the piece belongs to the first player
    #
    # @return [Boolean] true if the piece is uppercase
    def first_player?
      identifier == identifier.upcase
    end

    # Returns true if the piece belongs to the second player
    #
    # @return [Boolean] true if the piece is lowercase
    def second_player?
      !first_player?
    end

    # Returns a new piece with the ownership changed (case flipped)
    # but keeping the same modifiers
    #
    # @return [Piece] A new piece with flipped ownership
    def change_ownership
      self.class.new(flip_case(identifier), prefix: prefix, suffix: suffix)
    end

    # Returns a new piece with a modified prefix
    #
    # @param new_prefix [String, nil] The new prefix to set
    # @return [Piece] A new piece with the updated prefix
    def with_prefix(new_prefix)
      self.class.new(identifier, prefix: new_prefix, suffix: suffix)
    end

    # Returns a new piece with a modified suffix
    #
    # @param new_suffix [String, nil] The new suffix to set
    # @return [Piece] A new piece with the updated suffix
    def with_suffix(new_suffix)
      self.class.new(identifier, prefix: prefix, suffix: new_suffix)
    end

    # Returns a new piece without any modifiers
    #
    # @return [Piece] A new piece with no prefix or suffix
    def without_modifiers
      self.class.new(identifier)
    end

    private

    # Extract components from a piece string
    #
    # @param piece_string [String] The piece string to parse
    # @return [Hash] Hash with :prefix, :identifier, and :suffix
    def self.extract_piece_components(piece_string)
      components = {
        prefix:     nil,
        identifier: nil,
        suffix:     nil
      }

      # Check for prefix
      if piece_string.start_with?("+", "-")
        components[:prefix] = piece_string[0]
        remaining = piece_string[1..]
      else
        remaining = piece_string
      end

      # Extract identifier and suffix
      if remaining.length == 1
        components[:identifier] = remaining
      elsif remaining.length == 2
        components[:identifier] = remaining[0]
        components[:suffix] = remaining[1]
      else
        raise ArgumentError, "Invalid piece string format: #{piece_string.inspect}"
      end

      components
    end

    # Validate a piece string
    #
    # @param piece_string [String] The piece string to validate
    # @raise [ArgumentError] If the piece string is invalid
    def self.validate_piece_string(piece_string)
      return if piece_string.is_a?(String) && piece_string.match?(PIECE_REGEX)

      raise ArgumentError, "Invalid piece string format. Must match /[+\\-]?[a-zA-Z][=<>]?/, got: #{piece_string.inspect}"
    end

    # Flips the case of the identifier
    #
    # @param identifier [String] The identifier to flip
    # @return [String] The identifier with flipped case
    def flip_case(identifier)
      first_player? ? identifier.downcase : identifier.upcase
    end

    # Validates that the identifier is a letter from a-z or A-Z
    #
    # @param identifier [String] The identifier to validate
    # @raise [ArgumentError] If the identifier is invalid
    def validate_identifier(identifier)
      return if identifier.is_a?(String) && identifier.length == 1 && VALID_IDENTIFIERS.include?(identifier)

      raise ArgumentError, "Piece identifier must be a single letter (a-z, A-Z), got: #{identifier.inspect}"
    end

    # Validates that the prefix is valid or nil
    #
    # @param prefix [String, nil] The prefix to validate
    # @raise [ArgumentError] If the prefix is invalid
    def validate_prefix(prefix)
      return if VALID_PREFIXES.include?(prefix)

      raise ArgumentError, "Piece prefix must be '+', '-', or nil, got: #{prefix.inspect}"
    end

    # Validates that the suffix is valid or nil
    #
    # @param suffix [String, nil] The suffix to validate
    # @raise [ArgumentError] If the suffix is invalid
    def validate_suffix(suffix)
      return if VALID_SUFFIXES.include?(suffix)

      raise ArgumentError, "Piece suffix must be '=', '<', '>', or nil, got: #{suffix.inspect}"
    end
  end
end
