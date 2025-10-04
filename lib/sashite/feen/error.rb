# frozen_string_literal: true

module Sashite
  module Feen
    # Base error class for all FEEN-related errors.
    #
    # All FEEN parsing and validation errors inherit from this class,
    # allowing callers to rescue all FEEN errors with a single rescue clause.
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    class Error < StandardError
      # Error raised when FEEN structure is malformed.
      #
      # Indicates problems with the overall FEEN format, such as:
      # - Missing or incorrect number of fields
      # - Missing required separators
      # - Empty fields where content is required
      # - Invalid field structure
      #
      # @example Missing field separator
      #   raise Error::Syntax, "FEEN must have exactly 3 space-separated fields"
      #
      # @example Empty required field
      #   raise Error::Syntax, "active style cannot be empty"
      class Syntax < Error; end

      # Error raised when EPIN (Extended Piece Identifier Notation) is invalid.
      #
      # Indicates problems with piece notation, such as:
      # - Invalid EPIN format
      # - Unrecognized piece characters
      # - Malformed state modifiers or derivation suffixes
      # - EPIN parsing failures
      #
      # @example Invalid EPIN format
      #   raise Error::Piece, "invalid EPIN notation: K#"
      #
      # @example Failed EPIN parsing
      #   raise Error::Piece, "failed to parse EPIN 'X': unknown piece type"
      class Piece < Error; end

      # Error raised when SIN (Style Identifier Notation) is invalid.
      #
      # Indicates problems with style notation, such as:
      # - Invalid SIN format
      # - Non-letter characters in style identifier
      # - Multi-character style identifiers
      # - SIN parsing failures
      #
      # @example Invalid SIN format
      #   raise Error::Style, "invalid SIN notation: '1' (must be a single letter)"
      #
      # @example Failed SIN parsing
      #   raise Error::Style, "failed to parse SIN 'XY': too long"
      class Style < Error; end

      # Error raised when piece counts are invalid.
      #
      # Indicates problems with piece quantity specifications, such as:
      # - Count less than 1
      # - Count exceeding reasonable limits
      # - Invalid count format
      #
      # @example Count too small
      #   raise Error::Count, "piece count must be at least 1, got 0"
      #
      # @example Count too large
      #   raise Error::Count, "piece count too large: 9999"
      class Count < Error; end

      # Error raised for other semantic validation failures.
      #
      # Indicates problems that don't fit other error categories, such as:
      # - Inconsistent position state
      # - Rule violations
      # - Other semantic constraints
      #
      # @example Semantic constraint violation
      #   raise Error::Validation, "position violates conservation principle"
      class Validation < Error; end
    end
  end
end
