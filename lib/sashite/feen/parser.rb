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
    # - {Parser::PiecePlacement} for Field 1 → flat board + shape
    # - {Parser::Hands} for Field 2 → two piece count maps
    # - {Parser::StyleTurn} for Field 3 → styles + turn
    #
    # After parsing all fields, it validates cross-field constraints
    # (cardinality: total pieces <= total squares) and assembles a Qi position.
    #
    # Uses a dual-path architecture:
    # - {.valid?} uses exception-free sub-parsers, never constructs a Qi
    # - {.parse} uses the same validation path, raises once at the boundary
    #
    # @example Parsing a valid FEEN string
    #   Parser.parse("rnbqk^bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK^BNR / C/c")
    #   # => #<Qi ...>
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

      # Parses a FEEN string into a Qi position.
      #
      # @param input [String] The FEEN string to parse
      # @return [Qi] An immutable position object
      # @raise [ParseError] If the input is not a valid FEEN string
      def self.parse(input)
        validate_length!(input)

        fields = input.split(Separators::FIELD, -1)
        validate_field_count!(fields)

        piece_placement_str, hands_str, style_turn_str = fields

        # Use safe_parse for all sub-parsers first
        pp_result = PiecePlacement.safe_parse(piece_placement_str)
        hands_result = Hands.safe_parse(hands_str)
        st_result = StyleTurn.safe_parse(style_turn_str)

        # If any sub-parser failed, delegate to the raising path
        # for the first failing one (preserving field order)
        if pp_result.nil?
          PiecePlacement.parse(piece_placement_str)
        end

        if hands_result.nil?
          Hands.parse(hands_str)
        end

        if st_result.nil?
          StyleTurn.parse(style_turn_str)
        end

        flat_board, shape = flatten_with_shape(pp_result)
        first_hand_array = hands_result[:first]
        second_hand_array = hands_result[:second]
        first_player_style = st_result[:styles][:first]
        second_player_style = st_result[:styles][:second]
        turn = st_result[:turn]

        first_player_hand = to_count_map(first_hand_array)
        second_player_hand = to_count_map(second_hand_array)

        validate_cardinality!(flat_board, first_player_hand, second_player_hand)

        build_position(flat_board, shape, first_player_hand, second_player_hand,
                       first_player_style, second_player_style, turn)
      end

      # Validates a FEEN string without raising an exception.
      #
      # Uses the exception-free code path throughout. Never constructs
      # a Qi object — only validates structural and semantic constraints.
      #
      # @param input [String] The FEEN string to validate
      # @return [Boolean] true if valid, false otherwise
      def self.valid?(input)
        return false unless ::String === input
        return false if input.bytesize > Limits::MAX_STRING_LENGTH

        fields = input.split(Separators::FIELD, -1)
        return false unless fields.size == FIELD_COUNT

        piece_placement_str, hands_str, style_turn_str = fields

        pp_result = PiecePlacement.safe_parse(piece_placement_str)
        return false if pp_result.nil?

        hands_result = Hands.safe_parse(hands_str)
        return false if hands_result.nil?

        st_result = StyleTurn.safe_parse(style_turn_str)
        return false if st_result.nil?

        flat_board, _shape = flatten_with_shape(pp_result)
        first_player_hand = to_count_map(hands_result[:first])
        second_player_hand = to_count_map(hands_result[:second])

        cardinality_valid?(flat_board, first_player_hand, second_player_hand)
      end

      class << self
        private

        # Extracts flat board and shape from a dimensioned board structure.
        #
        # @param board [Array] Nested board (1D flat, 2D ranks, 3D layers)
        # @return [Array(Array, Array<Integer>)] [flat_board, shape]
        def flatten_with_shape(board)
          return [board, [board.size]] unless board[0].is_a?(::Array)

          unless board[0][0].is_a?(::Array)
            # 2D: array of rank arrays
            ranks = board.size
            files = board[0].size
            return [board.flatten, [ranks, files]]
          end

          # 3D: array of layer arrays of rank arrays
          layers = board.size
          ranks = board[0].size
          files = board[0][0].size
          [board.flatten, [layers, ranks, files]]
        end

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
        # @param flat_board [Array] Flat board array
        # @param first_player_hand [Hash{String => Integer}] First hand
        # @param second_player_hand [Hash{String => Integer}] Second hand
        # @raise [CardinalityError] If too many pieces for board size
        def validate_cardinality!(flat_board, first_player_hand, second_player_hand)
          return if cardinality_valid?(flat_board, first_player_hand, second_player_hand)

          raise CardinalityError, CardinalityError::TOO_MANY_PIECES
        end

        # Checks cardinality without raising.
        #
        # @param flat_board [Array] Flat board array
        # @param first_player_hand [Hash{String => Integer}] First hand
        # @param second_player_hand [Hash{String => Integer}] Second hand
        # @return [Boolean]
        def cardinality_valid?(flat_board, first_player_hand, second_player_hand)
          total_squares = flat_board.size

          board_pieces = 0
          flat_board.each { |sq| board_pieces += 1 unless sq.nil? }

          hand_pieces = sum_hand(first_player_hand) + sum_hand(second_player_hand)

          (board_pieces + hand_pieces) <= total_squares
        end

        # Sums the total piece count in a hand.
        #
        # @param hand [Hash{String => Integer}] Piece → count map
        # @return [Integer] Total piece count
        def sum_hand(hand)
          total = 0
          hand.each_value { |count| total += count }
          total
        end

        # Converts an expanded array of pieces into a count map.
        #
        # @param expanded_hand [Array<String>] Expanded piece strings
        # @return [Hash{String => Integer}] Piece → count map
        def to_count_map(expanded_hand)
          map = {}

          expanded_hand.each do |piece|
            map[piece] = (map[piece] || 0) + 1
          end

          map
        end

        # Constructs a Qi position from parsed components.
        #
        # @param flat_board [Array<String, nil>] Flat board array
        # @param shape [Array<Integer>] Board dimensions
        # @param first_player_hand [Hash{String => Integer}] First hand
        # @param second_player_hand [Hash{String => Integer}] Second hand
        # @param first_player_style [String] First player SIN token
        # @param second_player_style [String] Second player SIN token
        # @param turn [Symbol] :first or :second
        # @return [Qi] Immutable position
        def build_position(flat_board, shape, first_player_hand, second_player_hand,
                           first_player_style, second_player_style, turn)
          position = ::Qi.new(shape,
                              first_player_style: first_player_style,
                              second_player_style: second_player_style)

          # Place pieces on the board
          board_diffs = {}
          flat_board.each_with_index do |sq, i|
            board_diffs[i] = sq unless sq.nil?
          end

          position = position.board_diff(**board_diffs) unless board_diffs.empty?

          # Add hand pieces
          unless first_player_hand.empty?
            position = position.first_player_hand_diff(**first_player_hand.transform_keys(&:to_sym))
          end

          unless second_player_hand.empty?
            position = position.second_player_hand_diff(**second_player_hand.transform_keys(&:to_sym))
          end

          # Set turn
          position = position.toggle if turn == :second

          position
        end
      end

      private_class_method :validate_length!,
                           :validate_field_count!,
                           :validate_cardinality!,
                           :cardinality_valid?,
                           :sum_hand,
                           :to_count_map,
                           :flatten_with_shape,
                           :build_position

      freeze
    end
  end
end
