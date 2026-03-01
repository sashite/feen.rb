# frozen_string_literal: true

module Sashite
  module Feen
    # ASCII byte constants and predicates for efficient parsing.
    #
    # All predicates accept the return value of String#getbyte (Integer or nil)
    # and return a truthy/falsey value. They are nil-safe via short-circuit
    # evaluation: +byte && ...+ returns nil (falsey) when byte is nil.
    #
    # @api private
    module Ascii
      ZERO       = 0x30
      NINE       = 0x39
      UPPER_A    = 0x41
      UPPER_Z    = 0x5A
      LOWER_A    = 0x61
      LOWER_Z    = 0x7A
      PLUS       = 0x2B
      MINUS      = 0x2D
      SLASH      = 0x2F
      CARET      = 0x5E
      APOSTROPHE = 0x27

      # Tests whether a byte is an ASCII digit (0-9).
      def self.digit?(byte)
        byte && byte >= ZERO && byte <= NINE
      end

      # Tests whether a byte is an ASCII letter (A-Z or a-z).
      #
      # Uses a bit trick: OR with 0x20 maps A-Z to a-z while leaving a-z
      # unchanged. Characters between Z (0x5A) and a (0x61) map to 0x7B+,
      # which falls outside the a-z range, so no false positives occur.
      def self.letter?(byte)
        byte && (byte | 0x20) >= LOWER_A && (byte | 0x20) <= LOWER_Z
      end

      # Tests whether a byte is an uppercase ASCII letter (A-Z).
      def self.uppercase?(byte)
        byte && byte >= UPPER_A && byte <= UPPER_Z
      end

      # Tests whether a byte is a lowercase ASCII letter (a-z).
      def self.lowercase?(byte)
        byte && byte >= LOWER_A && byte <= LOWER_Z
      end

      freeze
    end
  end
end
