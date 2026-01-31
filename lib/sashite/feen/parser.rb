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
    # parsing to specialized sub-parsers:
    # - {Parser::PiecePlacement} for Field 1
    # - {Parser::Hands} for Field 2
    # - {Parser::StyleTurn} for Field 3
    #
    # @api private
    #
    # @example Parsing a valid FEEN string
    #   Parser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
    #   # => { piece_placement: {...}, hands: {...}, style_turn: {...} }
    #
    # @example Validation without exception
    #   Parser.valid?("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c")
    #   # => true
    #
    #   Parser.valid?("invalid")
    #   # => false
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    module Parser
      # Number of fields in a valid FEEN string.
      FIELD_COUNT = 3

      # Parses a FEEN string into its components.
      #
      # @param input [String] The FEEN string to parse
      # @return [Hash] A hash with :piece_placement, :hands, and :style_turn keys
      # @raise [Errors::Argument] If the input is not a valid FEEN string
      def self.parse(input)
        validate_length!(input)

        fields = input.split(Constants::FIELD_SEPARATOR, -1)
        validate_field_count!(fields)

        piece_placement_str, hands_str, style_turn_str = fields

        piece_placement = PiecePlacement.parse(piece_placement_str)
        hands = Hands.parse(hands_str)
        style_turn = StyleTurn.parse(style_turn_str)

        validate_piece_count!(piece_placement, hands)

        { piece_placement:, hands:, style_turn: }
      end

      # Validates a FEEN string without raising an exception.
      #
      # @param input [String] The FEEN string to validate
      # @return [Boolean] true if valid, false otherwise
      def self.valid?(input)
        return false unless input.is_a?(::String)

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
        # @raise [Errors::Argument] If input exceeds maximum length
        def validate_length!(input)
          return if input.bytesize <= Constants::MAX_STRING_LENGTH

          raise Errors::Argument, Errors::Argument::Messages::INPUT_TOO_LONG
        end

        # Validates that there are exactly 3 fields.
        #
        # @param fields [Array<String>] The split fields
        # @raise [Errors::Argument] If field count is not 3
        def validate_field_count!(fields)
          return if fields.size == FIELD_COUNT

          raise Errors::Argument, Errors::Argument::Messages::INVALID_FIELD_COUNT
        end

        # Validates that total pieces don't exceed board capacity.
        #
        # @param piece_placement [Hash] Parsed piece placement
        # @param hands [Hash] Parsed hands
        # @raise [Errors::Argument] If too many pieces for board size
        def validate_piece_count!(piece_placement, hands)
          board_pieces = count_board_pieces(piece_placement[:segments])
          hand_pieces = count_hand_pieces(hands)
          total_pieces = board_pieces + hand_pieces

          total_squares = count_total_squares(piece_placement[:segments])

          return if total_pieces <= total_squares

          raise Errors::Argument, Errors::Argument::Messages::TOO_MANY_PIECES
        end

        # Counts pieces on the board.
        #
        # @param segments [Array<Array>] The board segments
        # @return [Integer] Number of pieces
        def count_board_pieces(segments)
          segments.sum do |segment|
            segment.count { |token| !token.is_a?(::Integer) }
          end
        end

        # Counts pieces in hands.
        #
        # @param hands [Hash] The hands data
        # @return [Integer] Total pieces in both hands
        def count_hand_pieces(hands)
          first_count = hands[:first].sum { |item| item[:count] }
          second_count = hands[:second].sum { |item| item[:count] }
          first_count + second_count
        end

        # Counts total squares on the board.
        #
        # @param segments [Array<Array>] The board segments
        # @return [Integer] Total number of squares
        def count_total_squares(segments)
          segments.sum do |segment|
            segment.sum do |token|
              token.is_a?(::Integer) ? token : 1
            end
          end
        end
      end
    end
  end
end
