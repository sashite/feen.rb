# frozen_string_literal: true

require_relative "parser/piece_placement"
require_relative "parser/pieces_in_hand"
require_relative "parser/style_turn"

require_relative "error"
require_relative "position"

module Sashite
  module Feen
    # Parser for FEEN (Field Expression Encoding Notation) strings.
    #
    # Parses a complete FEEN string by splitting it into three space-separated
    # fields and delegating parsing to specialized parsers for each component.
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    module Parser
      # Field separator in FEEN notation.
      FIELD_SEPARATOR = " "

      # Number of required fields in a valid FEEN string.
      FIELD_COUNT = 3

      # Parse a FEEN string into an immutable Position object.
      #
      # Validates the overall FEEN structure, splits the string into three
      # space-separated fields, and delegates parsing of each field to the
      # appropriate specialized parser.
      #
      # @param string [String] A FEEN notation string
      # @return [Position] Immutable position object
      # @raise [Error::Syntax] If the FEEN structure is malformed
      #
      # @example Parse a complete FEEN string
      #   position = Parser.parse("+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/c")
      def self.parse(string)
        fields = split_fields(string)

        placement = Parser::PiecePlacement.parse(fields[0])
        hands     = Parser::PiecesInHand.parse(fields[1])
        styles    = Parser::StyleTurn.parse(fields[2])

        Position.new(placement, hands, styles)
      end

      # Split a FEEN string into its three constituent fields.
      #
      # Validates that exactly three space-separated fields are present.
      # Supports empty piece placement field (board-less positions).
      #
      # @param string [String] A FEEN notation string
      # @return [Array<String>] Array of three field strings
      # @raise [Error::Syntax] If field count is not exactly 3
      #
      # @example Valid FEEN string
      #   split_fields("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
      #   # => ["rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR", "/", "C/c"]
      #
      # @example Empty piece placement field
      #   split_fields(" / C/c")
      #   # => ["", "/", "C/c"]
      #
      # @example Invalid FEEN string (too few fields)
      #   split_fields("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR /")
      #   # raises Error::Syntax
      private_class_method def self.split_fields(string)
        # Use regex separator to preserve empty leading fields
        # String#split with " " treats leading spaces specially and discards them
        fields = string.split(/ /, FIELD_COUNT)

        unless fields.size == FIELD_COUNT
          raise Error::Syntax, "FEEN must have exactly #{FIELD_COUNT} space-separated fields, got #{fields.size}"
        end

        fields
      end
    end
  end
end
