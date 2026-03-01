# frozen_string_literal: true

require "sashite/epin"

require_relative "../shared/ascii"
require_relative "../shared/limits"
require_relative "../shared/separators"
require_relative "../errors/piece_placement_error"

module Sashite
  module Feen
    module Parser
      # Parser for the FEEN Piece Placement field (Field 1).
      #
      # Parses a Piece Placement string into a dimensioned board structure:
      # - 1D: flat Array of squares
      # - 2D: Array of rank Arrays
      # - 3D: Array of layer Arrays of rank Arrays
      #
      # Validates:
      # - Structural constraints (non-empty, no leading/trailing separators)
      # - EPIN token validity for each piece
      # - Empty count canonicality (no leading zeros, no consecutive counts)
      # - Dimensional coherence (separator hierarchy)
      # - Dimension limits (max 3 dimensions, max 255 per dimension)
      # - Shape regularity (all ranks same width within a dimension)
      #
      # Provides a dual-path API:
      # - {.safe_parse} returns nil on invalid input (no exceptions)
      # - {.parse} raises {PiecePlacementError} on invalid input
      #
      # @example 1D board
      #   PiecePlacement.parse("K^2k^")
      #   # => ["K^", nil, nil, "k^"]
      #
      # @example 2D board
      #   PiecePlacement.parse("8/8")
      #   # => [Array.new(8), Array.new(8)]
      #
      # @example 3D board
      #   PiecePlacement.parse("ab/cd//AB/CD")
      #   # => [[["a","b"],["c","d"]], [["A","B"],["C","D"]]]
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module PiecePlacement
        # Parses a Piece Placement field, returning nil on failure.
        #
        # @param input [String] The Piece Placement field string
        # @return [Array, nil] Dimensioned board structure or nil
        def self.safe_parse(input)
          return nil if input.empty?
          return nil if input.getbyte(0) == Ascii::SLASH
          return nil if input.getbyte(input.bytesize - 1) == Ascii::SLASH

          max_sep = max_separator_length(input)
          dims = max_sep + 1

          return nil if dims > Limits::MAX_DIMENSIONS

          case dims
          when 1 then parse_1d(input)
          when 2 then parse_2d(input)
          when 3 then parse_3d(input)
          end
        end

        # Parses a Piece Placement field, raising on failure.
        #
        # @param input [String] The Piece Placement field string
        # @return [Array] Dimensioned board structure
        # @raise [PiecePlacementError] If the input is not valid
        def self.parse(input)
          result = safe_parse(input)
          return result unless result.nil?

          raise_specific_error!(input)
        end

        class << self
          private

          # Finds the maximum separator group length in the input.
          #
          # A separator group is a consecutive run of "/" characters.
          # Returns 0 if no "/" is found (1D board).
          #
          # @param input [String] The input string
          # @return [Integer] Maximum separator group length
          def max_separator_length(input)
            max_sep = 0
            current_sep = 0
            i = 0

            while i < input.bytesize
              if input.getbyte(i) == Ascii::SLASH
                current_sep += 1
              else
                max_sep = current_sep if current_sep > max_sep
                current_sep = 0
              end

              i += 1
            end

            # Check trailing group (won't happen if we reject trailing "/",
            # but kept for safety)
            max_sep = current_sep if current_sep > max_sep

            max_sep
          end

          # Parses a 1D board (no separators).
          #
          # @param input [String] The segment string
          # @return [Array<String, nil>, nil] Flat array of squares or nil
          def parse_1d(input)
            squares = safe_parse_segment(input)
            return nil if squares.nil?
            return nil if squares.empty?
            return nil if squares.size > Limits::MAX_DIMENSION_SIZE

            squares
          end

          # Parses a 2D board (ranks separated by "/").
          #
          # @param input [String] The Piece Placement string
          # @return [Array<Array<String, nil>>, nil] Array of rank arrays or nil
          def parse_2d(input)
            rank_strs = input.split(Separators::SEGMENT, -1)

            ranks = []

            rank_strs.each do |rank_str|
              squares = safe_parse_segment(rank_str)
              return nil if squares.nil?
              return nil if squares.empty?
              return nil if squares.size > Limits::MAX_DIMENSION_SIZE

              ranks << squares
            end

            return nil if rank_strs.size > Limits::MAX_DIMENSION_SIZE

            ranks
          end

          # Parses a 3D board (layers separated by "//", ranks by "/").
          #
          # @param input [String] The Piece Placement string
          # @return [Array<Array<Array<String, nil>>>, nil] Nested layers or nil
          def parse_3d(input)
            layer_sep = Separators::SEGMENT * 2
            layer_strs = input.split(layer_sep, -1)

            layers = []
            ranks_per_layer = nil

            layer_strs.each do |layer_str|
              rank_strs = layer_str.split(Separators::SEGMENT, -1)

              # Dimensional coherence: each layer must have >= 2 ranks
              return nil if rank_strs.size < 2

              if ranks_per_layer.nil?
                ranks_per_layer = rank_strs.size
                return nil if ranks_per_layer > Limits::MAX_DIMENSION_SIZE
              else
                return nil unless rank_strs.size == ranks_per_layer
              end

              layer = []

              rank_strs.each do |rank_str|
                squares = safe_parse_segment(rank_str)
                return nil if squares.nil?
                return nil if squares.empty?
                return nil if squares.size > Limits::MAX_DIMENSION_SIZE

                layer << squares
              end

              layers << layer
            end

            return nil if layer_strs.size > Limits::MAX_DIMENSION_SIZE

            layers
          end

          # Parses a single segment (rank) into an array of squares.
          #
          # Squares are either EPIN token strings (pieces) or nil (empty).
          # Returns nil if parsing fails for any reason.
          #
          # @param str [String] The segment string
          # @return [Array<String, nil>, nil] Parsed squares or nil
          def safe_parse_segment(str)
            return nil if str.empty?

            squares = []
            pos = 0
            last_was_empty = false

            while pos < str.bytesize
              byte = str.getbyte(pos)

              if Ascii.digit?(byte)
                # Consecutive empty counts violate canonicality
                return nil if last_was_empty

                count, pos = safe_parse_empty_count(str, pos)
                return nil if count.nil?

                count.times { squares << nil }
                last_was_empty = true
              else
                piece, pos = safe_parse_piece(str, pos)
                return nil if piece.nil?

                squares << piece
                last_was_empty = false
              end
            end

            squares
          end

          # Parses an empty count token starting at pos, without raising.
          #
          # @param str [String] The string to parse from
          # @param pos [Integer] Starting byte position
          # @return [Array(Integer, Integer), Array(nil, nil)]
          def safe_parse_empty_count(str, pos)
            start_pos = pos
            pos += 1 while pos < str.bytesize && Ascii.digit?(str.getbyte(pos))

            count_str = str.byteslice(start_pos, pos - start_pos)

            # Leading zeros are forbidden
            return [nil, nil] if count_str.bytesize > 1 && count_str.getbyte(0) == Ascii::ZERO

            count = count_str.to_i

            # Empty count must be >= 1
            return [nil, nil] if count < 1

            [count, pos]
          end

          # Parses an EPIN token starting at pos, without raising.
          #
          # Scans the maximal EPIN structure: [+-]?[A-Za-z]^?'?
          # Then validates via Epin.valid?.
          #
          # @param str [String] The string to parse from
          # @param pos [Integer] Starting byte position
          # @return [Array(String, Integer), Array(nil, nil)]
          def safe_parse_piece(str, pos)
            start_pos = pos
            byte = str.getbyte(pos)

            # Optional state modifier: + or -
            if byte == Ascii::PLUS || byte == Ascii::MINUS
              pos += 1
              byte = str.getbyte(pos)
            end

            # Required letter: A-Z or a-z
            if Ascii.letter?(byte)
              pos += 1
              byte = str.getbyte(pos)
            end

            # Optional terminal marker: ^
            if byte == Ascii::CARET
              pos += 1
              byte = str.getbyte(pos)
            end

            # Optional derivation marker: '
            pos += 1 if byte == Ascii::APOSTROPHE

            epin_str = str.byteslice(start_pos, pos - start_pos)

            return [nil, nil] unless ::Sashite::Epin.valid?(epin_str)

            [epin_str, pos]
          end

          # ----------------------------------------------------------------
          # Error path: re-validates to produce specific error messages
          # ----------------------------------------------------------------

          # Re-validates input to determine the specific error to raise.
          #
          # Only called after safe_parse returned nil.
          #
          # @param input [String] The invalid input
          # @raise [PiecePlacementError] Always raises with a specific message
          def raise_specific_error!(input)
            if input.empty?
              raise PiecePlacementError, PiecePlacementError::EMPTY
            end

            if input.getbyte(0) == Ascii::SLASH
              raise PiecePlacementError, PiecePlacementError::STARTS_WITH_SEPARATOR
            end

            if input.getbyte(input.bytesize - 1) == Ascii::SLASH
              raise PiecePlacementError, PiecePlacementError::ENDS_WITH_SEPARATOR
            end

            max_sep = max_separator_length(input)
            dims = max_sep + 1

            if dims > Limits::MAX_DIMENSIONS
              raise PiecePlacementError, PiecePlacementError::EXCEEDS_MAX_DIMENSIONS
            end

            case dims
            when 1 then raise_1d_errors!(input)
            when 2 then raise_2d_errors!(input)
            when 3 then raise_3d_errors!(input)
            end
          end

          # Raises the specific error for a 1D board.
          #
          # @param input [String] The segment string
          # @raise [PiecePlacementError]
          def raise_1d_errors!(input)
            squares = raise_parse_segment!(input)
            raise_dimension_size!(squares.size)
          end

          # Raises the specific error for a 2D board.
          #
          # @param input [String] The Piece Placement string
          # @raise [PiecePlacementError]
          def raise_2d_errors!(input)
            rank_strs = input.split(Separators::SEGMENT, -1)

            rank_strs.each do |rank_str|
              squares = raise_parse_segment!(rank_str)
              raise_dimension_size!(squares.size)
            end

            raise_dimension_size!(rank_strs.size)
          end

          # Raises the specific error for a 3D board.
          #
          # @param input [String] The Piece Placement string
          # @raise [PiecePlacementError]
          def raise_3d_errors!(input)
            layer_sep = Separators::SEGMENT * 2
            layer_strs = input.split(layer_sep, -1)
            ranks_per_layer = nil

            layer_strs.each do |layer_str|
              rank_strs = layer_str.split(Separators::SEGMENT, -1)

              if rank_strs.size < 2
                raise PiecePlacementError, PiecePlacementError::DIMENSIONAL_COHERENCE
              end

              if ranks_per_layer.nil?
                ranks_per_layer = rank_strs.size
                raise_dimension_size!(ranks_per_layer)
              elsif rank_strs.size != ranks_per_layer
                raise PiecePlacementError, PiecePlacementError::DIMENSIONAL_COHERENCE
              end

              rank_strs.each do |rank_str|
                squares = raise_parse_segment!(rank_str)
                raise_dimension_size!(squares.size)
              end
            end

            raise_dimension_size!(layer_strs.size)
          end

          # Parses a segment on the error path, raising specific errors.
          #
          # @param str [String] The segment string
          # @return [Array<String, nil>] Parsed squares
          # @raise [PiecePlacementError]
          def raise_parse_segment!(str)
            if str.empty?
              raise PiecePlacementError, PiecePlacementError::EMPTY_SEGMENT
            end

            squares = []
            pos = 0
            last_was_empty = false

            while pos < str.bytesize
              byte = str.getbyte(pos)

              if Ascii.digit?(byte)
                if last_was_empty
                  raise PiecePlacementError, PiecePlacementError::CONSECUTIVE_EMPTY_COUNTS
                end

                start_pos = pos
                pos += 1 while pos < str.bytesize && Ascii.digit?(str.getbyte(pos))

                count_str = str.byteslice(start_pos, pos - start_pos)

                if count_str.bytesize > 1 && count_str.getbyte(0) == Ascii::ZERO
                  raise PiecePlacementError, PiecePlacementError::INVALID_EMPTY_COUNT
                end

                count = count_str.to_i

                if count < 1
                  raise PiecePlacementError, PiecePlacementError::INVALID_EMPTY_COUNT
                end

                count.times { squares << nil }
                last_was_empty = true
              else
                start_pos = pos
                byte = str.getbyte(pos)

                if byte == Ascii::PLUS || byte == Ascii::MINUS
                  pos += 1
                  byte = str.getbyte(pos)
                end

                if Ascii.letter?(byte)
                  pos += 1
                  byte = str.getbyte(pos)
                end

                if byte == Ascii::CARET
                  pos += 1
                  byte = str.getbyte(pos)
                end

                pos += 1 if byte == Ascii::APOSTROPHE

                epin_str = str.byteslice(start_pos, pos - start_pos)

                unless ::Sashite::Epin.valid?(epin_str)
                  raise PiecePlacementError, PiecePlacementError::INVALID_PIECE_TOKEN
                end

                squares << epin_str
                last_was_empty = false
              end
            end

            squares
          end

          # Raises if a dimension size exceeds the limit.
          #
          # @param size [Integer] The dimension size
          # @raise [PiecePlacementError] If size exceeds 255
          def raise_dimension_size!(size)
            return if size <= Limits::MAX_DIMENSION_SIZE

            raise PiecePlacementError, PiecePlacementError::DIMENSION_SIZE_EXCEEDED
          end
        end

        private_class_method :max_separator_length,
                             :parse_1d,
                             :parse_2d,
                             :parse_3d,
                             :safe_parse_segment,
                             :safe_parse_empty_count,
                             :safe_parse_piece,
                             :raise_specific_error!,
                             :raise_1d_errors!,
                             :raise_2d_errors!,
                             :raise_3d_errors!,
                             :raise_parse_segment!,
                             :raise_dimension_size!

        freeze
      end
    end
  end
end
