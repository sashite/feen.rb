# frozen_string_literal: true

require_relative "constants"
require_relative "errors"
require_relative "parser/hands"
require_relative "parser/piece_placement"
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
    # parsing to specialized sub-parsers.
    #
    # @example
    #   Parser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
    #   # => { piece_placement: {...}, hands: {...}, style_turn: {...} }
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    module Parser
      # Parses a FEEN string into its components.
      #
      # @param input [String] The FEEN string to parse
      # @return [Hash] A hash with :piece_placement, :hands, and :style_turn keys
      # @raise [Errors::Argument] If the input is not a valid FEEN string
      def self.parse(input)
        validate_input!(input)

        fields = input.split(Constants::FIELD_SEPARATOR, -1)
        validate_field_count!(fields)

        piece_placement_str, hands_str, style_turn_str = fields

        {
          piece_placement: PiecePlacement.parse(piece_placement_str),
          hands:           Hands.parse(hands_str),
          style_turn:      StyleTurn.parse(style_turn_str)
        }
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

        # Validates the input string.
        #
        # @param input [Object] The input to validate
        # @raise [Errors::Argument] If input is invalid
        def validate_input!(input)
          raise Errors::Argument, Errors::Argument::Messages::EMPTY_INPUT if input.empty?

          return unless input.bytesize > Constants::MAX_STRING_LENGTH

          raise Errors::Argument, Errors::Argument::Messages::INPUT_TOO_LONG
        end

        # Validates that there are exactly 3 fields.
        #
        # @param fields [Array<String>] The split fields
        # @raise [Errors::Argument] If field count is not 3
        def validate_field_count!(fields)
          return if fields.size == 3

          raise Errors::Argument, Errors::Argument::Messages::INVALID_FIELD_COUNT
        end
      end
    end
  end
end
