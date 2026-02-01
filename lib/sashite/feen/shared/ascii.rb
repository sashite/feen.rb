# frozen_string_literal: true

module Sashite
  module Feen
    # ASCII byte constants and predicates for efficient parsing.
    #
    # This module centralizes all byte-level operations to avoid
    # duplication across parsers. All methods operate on raw byte
    # values (Integer) for maximum performance.
    #
    # @example Checking character types
    #   Ascii.digit?(0x35)     # => true  (byte for '5')
    #   Ascii.letter?(0x4B)    # => true  (byte for 'K')
    #   Ascii.uppercase?(0x4B) # => true  (byte for 'K')
    #   Ascii.lowercase?(0x6B) # => true  (byte for 'k')
    #
    # @example Usage in parsing
    #   byte = string.getbyte(position)
    #   if Ascii.digit?(byte)
    #     # parse number
    #   elsif Ascii.letter?(byte)
    #     # parse piece token
    #   end
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    # @api private
    module Ascii
      # @!group Digit Constants

      # ASCII byte value for '0'.
      ZERO = 0x30

      # ASCII byte value for '9'.
      NINE = 0x39

      # @!group Uppercase Letter Constants

      # ASCII byte value for 'A'.
      UPPER_A = 0x41

      # ASCII byte value for 'Z'.
      UPPER_Z = 0x5A

      # @!group Lowercase Letter Constants

      # ASCII byte value for 'a'.
      LOWER_A = 0x61

      # ASCII byte value for 'z'.
      LOWER_Z = 0x7A

      # @!group Special Character Constants

      # ASCII byte value for '+'.
      PLUS = 0x2B

      # ASCII byte value for '-'.
      MINUS = 0x2D

      # ASCII byte value for '/'.
      SLASH = 0x2F

      # ASCII byte value for '^'.
      CARET = 0x5E

      # ASCII byte value for "'".
      APOSTROPHE = 0x27

      # @!group Predicates

      # Tests whether a byte represents an ASCII digit (0-9).
      #
      # @param byte [Integer, nil] the byte value to test
      # @return [Boolean] true if byte is in range 0x30-0x39
      #
      # @example
      #   Ascii.digit?(0x30) # => true  ('0')
      #   Ascii.digit?(0x39) # => true  ('9')
      #   Ascii.digit?(0x41) # => false ('A')
      #   Ascii.digit?(nil)  # => false
      def self.digit?(byte)
        (::Integer === byte) && byte >= ZERO && byte <= NINE
      end

      # Tests whether a byte represents an ASCII letter (A-Z or a-z).
      #
      # @param byte [Integer, nil] the byte value to test
      # @return [Boolean] true if byte is a letter
      #
      # @example
      #   Ascii.letter?(0x41) # => true  ('A')
      #   Ascii.letter?(0x7A) # => true  ('z')
      #   Ascii.letter?(0x30) # => false ('0')
      #   Ascii.letter?(nil)  # => false
      def self.letter?(byte)
        (::Integer === byte) && (uppercase_range?(byte) || lowercase_range?(byte))
      end

      # Tests whether a byte represents an uppercase ASCII letter (A-Z).
      #
      # @param byte [Integer, nil] the byte value to test
      # @return [Boolean] true if byte is in range 0x41-0x5A
      #
      # @example
      #   Ascii.uppercase?(0x41) # => true  ('A')
      #   Ascii.uppercase?(0x5A) # => true  ('Z')
      #   Ascii.uppercase?(0x61) # => false ('a')
      #   Ascii.uppercase?(nil)  # => false
      def self.uppercase?(byte)
        (::Integer === byte) && uppercase_range?(byte)
      end

      # Tests whether a byte represents a lowercase ASCII letter (a-z).
      #
      # @param byte [Integer, nil] the byte value to test
      # @return [Boolean] true if byte is in range 0x61-0x7A
      #
      # @example
      #   Ascii.lowercase?(0x61) # => true  ('a')
      #   Ascii.lowercase?(0x7A) # => true  ('z')
      #   Ascii.lowercase?(0x41) # => false ('A')
      #   Ascii.lowercase?(nil)  # => false
      def self.lowercase?(byte)
        (::Integer === byte) && lowercase_range?(byte)
      end

      # @!group Private Range Checks

      # Checks if byte is in uppercase range (assumes byte is Integer).
      #
      # @param byte [Integer] the byte value to test
      # @return [Boolean]
      # @api private
      def self.uppercase_range?(byte)
        byte >= UPPER_A && byte <= UPPER_Z
      end

      # Checks if byte is in lowercase range (assumes byte is Integer).
      #
      # @param byte [Integer] the byte value to test
      # @return [Boolean]
      # @api private
      def self.lowercase_range?(byte)
        byte >= LOWER_A && byte <= LOWER_Z
      end

      private_class_method :uppercase_range?, :lowercase_range?

      freeze
    end
  end
end
