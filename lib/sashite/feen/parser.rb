# frozen_string_literal: true

require "qi"

require_relative "shared/limits"
require_relative "errors/parse_error"
require_relative "errors/cardinality_error"
require_relative "parser/piece_placement"
require_relative "parser/hands"
require_relative "parser/style_turn"

module Sashite
  module Feen
    # Parser for FEEN strings into Qi positions.
    #
    # Uses a dual-path architecture:
    # - {.valid?} uses exception-free sub-parsers, never constructs a Qi
    # - {.parse} uses the same path, raises once at the boundary
    #
    # @api private
    module Parser
      FIELD_COUNT = 3

      # Parses a FEEN string into a Qi position.
      #
      # @param input [String] The FEEN string to parse
      # @return [Qi] An immutable position object
      # @raise [ParseError] If the input is not a valid FEEN string
      def self.parse(input)
        raise ParseError, ParseError::INPUT_TOO_LONG if input.bytesize > Limits::MAX_STRING_LENGTH

        fields = input.split(" ", -1)
        raise ParseError, ParseError::INVALID_FIELD_COUNT unless fields.size == FIELD_COUNT

        f1, f2, f3 = fields

        # Try safe_parse first, delegate to raising path on failure
        pp_result = PiecePlacement.safe_parse(f1)
        hands_result = Hands.safe_parse(f2)
        st_result = StyleTurn.safe_parse(f3)

        PiecePlacement.parse(f1) if pp_result.nil?
        Hands.parse(f2) if hands_result.nil?
        StyleTurn.parse(f3) if st_result.nil?

        flat_board, shape = flatten_with_shape(pp_result)

        first_player_hand = to_count_map(hands_result[:first])
        second_player_hand = to_count_map(hands_result[:second])

        validate_cardinality!(flat_board, first_player_hand, second_player_hand)

        build_position(flat_board, shape, first_player_hand, second_player_hand,
                       st_result[:styles][:first], st_result[:styles][:second],
                       st_result[:turn])
      end

      # Validates a FEEN string without raising.
      #
      # @param input [String] The FEEN string to validate
      # @return [Boolean]
      def self.valid?(input)
        return false unless ::String === input
        return false if input.bytesize > Limits::MAX_STRING_LENGTH

        fields = input.split(" ", -1)
        return false unless fields.size == FIELD_COUNT

        f1, f2, f3 = fields

        pp_result = PiecePlacement.safe_parse(f1)
        return false if pp_result.nil?

        hands_result = Hands.safe_parse(f2)
        return false if hands_result.nil?

        st_result = StyleTurn.safe_parse(f3)
        return false if st_result.nil?

        total_squares, board_pieces = count_squares_and_pieces(pp_result)
        hand_pieces = count_hand(hands_result[:first]) + count_hand(hands_result[:second])

        (board_pieces + hand_pieces) <= total_squares
      end

      class << self
        private

        # Extracts flat board and shape from a dimensioned board structure.
        def flatten_with_shape(board)
          first = board[0]
          unless first.is_a?(::Array)
            return [board, [board.size]]
          end

          first_inner = first[0]
          unless first_inner.is_a?(::Array)
            # 2D
            return [board.flatten, [board.size, first.size]]
          end

          # 3D
          [board.flatten, [board.size, first.size, first_inner.size]]
        end

        # Counts total squares and occupied squares without flattening.
        # Used by valid? to avoid allocating a flat array.
        def count_squares_and_pieces(board)
          first = board[0]
          unless first.is_a?(::Array)
            pieces = 0
            board.each { |sq| pieces += 1 if sq }
            return [board.size, pieces]
          end

          total = 0
          pieces = 0

          first_inner = first[0]
          if first_inner.is_a?(::Array)
            # 3D
            board.each do |layer|
              layer.each do |rank|
                rank.each { |sq| pieces += 1 if sq }
                total += rank.size
              end
            end
          else
            # 2D
            board.each do |rank|
              rank.each { |sq| pieces += 1 if sq }
              total += rank.size
            end
          end

          [total, pieces]
        end

        # Counts pieces in an expanded hand array.
        def count_hand(expanded)
          expanded.size
        end

        # Validates cardinality, raising on failure.
        def validate_cardinality!(flat_board, first_hand, second_hand)
          total_squares = flat_board.size
          board_pieces = 0
          flat_board.each { |sq| board_pieces += 1 if sq }

          hand_pieces = sum_hand(first_hand) + sum_hand(second_hand)

          return if (board_pieces + hand_pieces) <= total_squares

          raise CardinalityError, CardinalityError::TOO_MANY_PIECES
        end

        # Sums piece count in a hand map.
        def sum_hand(hand)
          total = 0
          hand.each_value { |c| total += c }
          total
        end

        # Converts expanded piece array into count map.
        def to_count_map(expanded)
          map = {}
          expanded.each do |piece|
            map[piece] = (map[piece] || 0) + 1
          end
          map
        end

        # Constructs a Qi position from parsed components.
        def build_position(flat_board, shape, first_player_hand, second_player_hand,
                           first_player_style, second_player_style, turn)
          position = ::Qi.new(shape,
                              first_player_style: first_player_style,
                              second_player_style: second_player_style)

          board_diffs = {}
          flat_board.each_with_index do |sq, i|
            board_diffs[i] = sq if sq
          end

          position = position.board_diff(**board_diffs) unless board_diffs.empty?

          unless first_player_hand.empty?
            position = position.first_player_hand_diff(**first_player_hand.transform_keys(&:to_sym))
          end

          unless second_player_hand.empty?
            position = position.second_player_hand_diff(**second_player_hand.transform_keys(&:to_sym))
          end

          position = position.toggle if turn == :second
          position
        end
      end

      private_class_method :flatten_with_shape,
                           :count_squares_and_pieces,
                           :count_hand,
                           :validate_cardinality!,
                           :sum_hand,
                           :to_count_map,
                           :build_position

      freeze
    end
  end
end
