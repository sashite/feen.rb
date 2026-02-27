# frozen_string_literal: true

require "qi"

require_relative "shared/limits"
require_relative "shared/separators"
require_relative "errors/parse_error"
require_relative "errors/cardinality_error"
require_relative "parser/piece_placement"
require_relative "parser/hands"
require_relative "parser/style_turn"

module Sashite
  module Feen
    # Parser for FEEN (Field Expression Encoding Notation) strings.
    #
    # A FEEN string consists of three fields separated by single ASCII spaces:
    #
    #   <PIECE-PLACEMENT> <HANDS> <STYLE-TURN>
    #
    # This parser validates the overall structure and delegates field-specific
    # parsing to specialized sub-parsers:
    # - {Parser::PiecePlacement} for Field 1 → board array
    # - {Parser::Hands} for Field 2 → hands hash
    # - {Parser::StyleTurn} for Field 3 → styles hash + turn
    #
    # After parsing all fields, it validates cross-field constraints
    # (cardinality: total pieces <= total squares) and assembles a Qi::Position.
    #
    # @example Parsing a valid FEEN string
    #   Parser.parse("rnbqk^bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK^BNR / C/c")
    #   # => #<Qi::Position ...>
    #
    # @example Validation without exception
    #   Parser.valid?("rnbqk^bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK^BNR / C/c")
    #   # => true
    #
    #   Parser.valid?("invalid")
    #   # => false
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    # @api private
    module Parser
      # Number of fields in a valid FEEN string.
      FIELD_COUNT = 3

      # Parses a FEEN string into a Qi::Position.
      #
      # @param input [String] The FEEN string to parse
      # @return [Qi::Position] An immutable position object
      # @raise [ParseError] If the input is not a valid FEEN string
      def self.parse(input)
        validate_length!(input)

        fields = input.split(Separators::FIELD, -1)
        validate_field_count!(fields)

        piece_placement_str, hands_str, style_turn_str = fields

        board = PiecePlacement.parse(piece_placement_str)
        hands = Hands.parse(hands_str)
        style_turn = StyleTurn.parse(style_turn_str)

        validate_cardinality!(board, hands)

        ::Qi.new(board, hands, style_turn[:styles], style_turn[:turn])
      end

      # Validates a FEEN string without raising an exception.
      #
      # @param input [String] The FEEN string to validate
      # @return [Boolean] true if valid, false otherwise
      def self.valid?(input)
        return false unless ::String === input

        parse(input)
        true
      rescue ::ArgumentError
        false
      end

      class << self
        private

        # Validates the input string length.
        #
        # @param input [String] The input to validate
        # @raise [ParseError] If input exceeds maximum length
        def validate_length!(input)
          return if input.bytesize <= Limits::MAX_STRING_LENGTH

          raise ParseError, ParseError::INPUT_TOO_LONG
        end

        # Validates that there are exactly 3 fields.
        #
        # @param fields [Array<String>] The split fields
        # @raise [ParseError] If field count is not 3
        def validate_field_count!(fields)
          return if fields.size == FIELD_COUNT

          raise ParseError, ParseError::INVALID_FIELD_COUNT
        end

        # Validates that total pieces don't exceed board capacity.
        #
        # Operates on the board array (nested 1D-3D with String/nil)
        # and the hands hash (flat arrays of EPIN strings).
        #
        # @param board [Array] Nested board array
        # @param hands [Hash] Hands with :first and :second arrays
        # @raise [CardinalityError] If too many pieces for board size
        def validate_cardinality!(board, hands)
          flat = board.flatten

          total_squares = flat.size
          total_pieces = flat.count { |sq| !sq.nil? } +
                         hands[:first].size +
                         hands[:second].size

          return if total_pieces <= total_squares

          raise CardinalityError, CardinalityError::TOO_MANY_PIECES
        end
      end

      private_class_method :validate_length!,
                           :validate_field_count!,
                           :validate_cardinality!

      freeze
    end
  end
end
