# frozen_string_literal: true

require "sashite/epin"

require_relative "../shared/ascii"
require_relative "../shared/limits"
require_relative "../shared/separators"
require_relative "../errors/piece_placement_error"

module Sashite
  module Feen
    module Parser
      # Parser for FEEN Piece Placement field (Field 1).
      #
      # The Piece Placement field encodes board occupancy as a stream of tokens
      # organized into segments separated by one or more slash characters.
      #
      # == Dimensional Structure
      #
      # Segment separators indicate dimensional boundaries:
      # - "/" separates ranks (1D boundary)
      # - "//" separates layers (2D boundary)
      # - "///" separates higher dimensions (3D boundary)
      #
      # == Token Types
      #
      # Within each segment, content is a concatenation of placement tokens:
      # - Empty-count token: a base-10 integer (>= 1, no leading zeros)
      # - Piece token: a valid EPIN identifier
      #
      # == Return Value
      #
      # Returns a nested Array representing the board, ready for Qi::Position:
      # - 1D: flat Array of String/nil (e.g. ["K^", nil, nil, "k^"])
      # - 2D: Array of rank Arrays (e.g. [[nil, nil], ["K^", nil]])
      # - 3D: Array of layer Arrays of rank Arrays
      #
      # Pieces are EPIN token strings, empty squares are nil.
      #
      # @example Parsing a 1D board
      #   PiecePlacement.parse("K2Q")
      #   # => ["K", nil, nil, "Q"]
      #
      # @example Parsing a 2D board (Chess-like)
      #   PiecePlacement.parse("8/8/8/8/8/8/8/8")
      #   # => [[nil]*8, [nil]*8, ..., [nil]*8]
      #
      # @example Parsing a 3D board
      #   PiecePlacement.parse("ab/cd//AB/CD")
      #   # => [[["a","b"],["c","d"]],[["A","B"],["C","D"]]]
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module PiecePlacement
        # Parses a FEEN Piece Placement field string.
        #
        # @param input [String] The Piece Placement field string
        # @return [Array] A nested board array of EPIN strings and nil
        # @raise [PiecePlacementError] If the input is not valid
        def self.parse(input)
          validate_not_empty!(input)
          validate_boundaries!(input)

          segments, separators = extract_segments_and_separators(input)

          validate_segments!(segments)
          validate_dimensional_coherence!(separators)
          validate_dimension_sizes!(segments)

          build_board(segments, separators)
        end

        class << self
          private

          # ------------------------------------------------------------------
          # Input Validation
          # ------------------------------------------------------------------

          # Validates that input is not empty.
          #
          # @param input [String] The input to validate
          # @raise [PiecePlacementError] If input is empty
          def validate_not_empty!(input)
            return unless input.empty?

            raise PiecePlacementError, PiecePlacementError::EMPTY
          end

          # Validates that input doesn't start or end with separator.
          #
          # This validation, combined with parse_separator consuming all
          # consecutive slashes, guarantees that empty segments cannot occur.
          #
          # @param input [String] The input to validate
          # @raise [PiecePlacementError] If boundaries are invalid
          def validate_boundaries!(input)
            if input.getbyte(0) == Ascii::SLASH
              raise PiecePlacementError, PiecePlacementError::STARTS_WITH_SEPARATOR
            end

            if input.getbyte(input.bytesize - 1) == Ascii::SLASH
              raise PiecePlacementError, PiecePlacementError::ENDS_WITH_SEPARATOR
            end
          end

          # ------------------------------------------------------------------
          # Segment Extraction
          # ------------------------------------------------------------------

          # Extracts segments and separators from the input string.
          #
          # The algorithm alternates between parsing segments (content) and
          # separators (slashes). Since boundaries are validated beforehand,
          # we always start and end with a segment.
          #
          # @param input [String] The input to parse
          # @return [Array(Array<Array>, Array<Integer>)] Segments and separator depths
          def extract_segments_and_separators(input)
            segments = []
            separators = []
            pos = 0

            while pos < input.bytesize
              segment, pos = parse_segment(input, pos)
              segments << segment

              if pos < input.bytesize
                depth, pos = parse_separator(input, pos)
                separators << depth
              end
            end

            [segments, separators]
          end

          # Parses a segment (sequence of placement tokens until separator or end).
          #
          # Tokens are either:
          # - Empty counts: sequences of digits parsed as a single integer
          # - Pieces: EPIN tokens parsed via the sashite-epin library
          #
          # @param str [String] The string to parse
          # @param pos [Integer] Starting position
          # @return [Array(Array, Integer)] The segment tokens and new position
          def parse_segment(str, pos)
            tokens = []
            previous_was_empty_count = false

            while pos < str.bytesize
              byte = str.getbyte(pos)

              break if byte == Ascii::SLASH

              if Ascii.digit?(byte)
                validate_no_consecutive_empty_counts!(previous_was_empty_count)
                count, pos = parse_empty_count(str, pos)
                tokens << count
                previous_was_empty_count = true
              else
                piece, pos = parse_piece(str, pos)
                tokens << piece
                previous_was_empty_count = false
              end
            end

            [tokens, pos]
          end

          # Validates that we don't have consecutive empty counts.
          #
          # This is defensive code: with the current implementation, consecutive
          # empty counts cannot occur because parse_empty_count consumes all
          # consecutive digits as a single number (e.g., "34" becomes 34, not
          # two separate tokens "3" and "4").
          #
          # Kept as a safeguard in case the parsing logic is modified.
          #
          # @param previous_was_empty_count [Boolean] Whether previous token was an empty count
          # @raise [PiecePlacementError] If consecutive empty counts detected
          def validate_no_consecutive_empty_counts!(previous_was_empty_count)
            # :nocov:
            return unless previous_was_empty_count

            raise PiecePlacementError, PiecePlacementError::CONSECUTIVE_EMPTY_COUNTS
            # :nocov:
          end

          # ------------------------------------------------------------------
          # Token Parsing
          # ------------------------------------------------------------------

          # Parses an empty-count token (sequence of digits).
          #
          # Consumes all consecutive digits starting at pos and converts
          # them to an integer. This greedy consumption is why consecutive
          # empty counts cannot occur in practice.
          #
          # @param str [String] The string to parse
          # @param pos [Integer] Starting position
          # @return [Array(Integer, Integer)] The count and new position
          # @raise [PiecePlacementError] If count is invalid (zero or leading zeros)
          def parse_empty_count(str, pos)
            start_pos = pos
            pos += 1 while pos < str.bytesize && Ascii.digit?(str.getbyte(pos))

            count_str = str.byteslice(start_pos, pos - start_pos)
            validate_empty_count!(count_str)

            [count_str.to_i, pos]
          end

          # Validates an empty-count string.
          #
          # Rejects:
          # - "0" (count must be >= 1)
          # - "00", "01", "007", etc. (leading zeros forbidden)
          #
          # @param count_str [String] The count string to validate
          # @raise [PiecePlacementError] If count has leading zeros or is zero
          def validate_empty_count!(count_str)
            return unless count_str.getbyte(0) == Ascii::ZERO

            raise PiecePlacementError, PiecePlacementError::INVALID_EMPTY_COUNT
          end

          # Parses an EPIN piece token.
          #
          # EPIN structure: [+-]?[A-Za-z]\^?'?
          #
          # The parser manually extracts the maximal EPIN-like substring,
          # then delegates validation to the sashite-epin library.
          # Returns the raw EPIN string for performance.
          #
          # @param str [String] The string to parse
          # @param pos [Integer] Starting position
          # @return [Array(String, Integer)] The EPIN token string and new position
          # @raise [PiecePlacementError] If EPIN parsing fails
          def parse_piece(str, pos)
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

            begin
              ::Sashite::Epin.parse(epin_str)
            rescue ::ArgumentError
              raise PiecePlacementError, PiecePlacementError::INVALID_PIECE_TOKEN
            end

            [epin_str, pos]
          end

          # Parses a separator group (one or more slashes).
          #
          # Consumes all consecutive slashes as a single separator.
          # Returns the depth (number of slashes) which indicates the
          # dimensional boundary:
          # - 1 = rank boundary (1D)
          # - 2 = layer boundary (2D)
          # - 3 = cube boundary (3D)
          #
          # @param str [String] The string to parse
          # @param pos [Integer] Starting position
          # @return [Array(Integer, Integer)] The separator depth and new position
          def parse_separator(str, pos)
            start_pos = pos
            pos += 1 while pos < str.bytesize && str.getbyte(pos) == Ascii::SLASH

            [pos - start_pos, pos]
          end

          # ------------------------------------------------------------------
          # Post-Parsing Validation
          # ------------------------------------------------------------------

          # Validates that all segments are non-empty.
          #
          # This is defensive code: with the current implementation, empty
          # segments cannot occur because:
          # 1. validate_boundaries! rejects strings starting/ending with "/"
          # 2. parse_separator consumes ALL consecutive slashes as one separator
          #
          # Therefore "//" is parsed as a single separator of depth 2, not
          # as two separators with an empty segment between them.
          #
          # Kept as a safeguard in case the parsing logic is modified.
          #
          # @param segments [Array<Array>] The segments to validate
          # @raise [PiecePlacementError] If any segment is empty
          def validate_segments!(segments)
            segments.each do |segment|
              # :nocov:
              raise PiecePlacementError, PiecePlacementError::EMPTY_SEGMENT if segment.empty?
              # :nocov:
            end
          end

          # Validates dimensional coherence of separators.
          #
          # A separator of depth N indicates a boundary at dimension N.
          # This requires that structures separated by depth-N separators
          # contain separators of depth N-1, ensuring proper dimensional hierarchy.
          #
          # Example: "a/b//c/d" is valid (3D with proper 2D structure)
          # Example: "a//b" is invalid (3D without 2D structure between)
          #
          # @param separators [Array<Integer>] The separator depths to validate
          # @raise [PiecePlacementError] If dimensional coherence is violated
          def validate_dimensional_coherence!(separators)
            return if separators.empty?

            max_depth = separators.max

            if max_depth > Limits::MAX_DIMENSIONS
              raise PiecePlacementError, PiecePlacementError::EXCEEDS_MAX_DIMENSIONS
            end

            return if max_depth <= 1

            validate_separator_hierarchy!(separators, max_depth)
          end

          # Validates that separator hierarchy is properly structured.
          #
          # For a valid N-dimensional board:
          # - Between depth-2 separators, there must be depth-1 separators
          # - Between depth-3 separators, there must be depth-2 separators
          #
          # @param separators [Array<Integer>] The separator depths to validate
          # @param max_depth [Integer] Maximum separator depth
          # @raise [PiecePlacementError] If hierarchy is invalid
          def validate_separator_hierarchy!(separators, max_depth)
            (2..max_depth).each do |depth|
              # Find indices where separators have depth >= current level
              boundary_indices = [-1] +
                separators.each_index.select { |i| separators[i] >= depth } +
                [separators.length]

              boundary_indices.each_cons(2) do |left, right|
                range_start = left + 1
                range_end = right - 1

                has_lower = (range_start..range_end).any? do |i|
                  separators[i] == depth - 1
                end

                unless has_lower
                  raise PiecePlacementError, PiecePlacementError::DIMENSIONAL_COHERENCE
                end
              end
            end
          end

          # Validates that no dimension exceeds the maximum size.
          #
          # Each segment represents a rank (row) of squares. The total
          # number of squares in a segment must not exceed MAX_DIMENSION_SIZE.
          #
          # @param segments [Array<Array>] The segments to validate
          # @raise [PiecePlacementError] If any dimension is too large
          def validate_dimension_sizes!(segments)
            segments.each do |segment|
              size = segment_size(segment)

              if size > Limits::MAX_DIMENSION_SIZE
                raise PiecePlacementError, PiecePlacementError::DIMENSION_SIZE_EXCEEDED
              end
            end
          end

          # Calculates the size (number of squares) of a segment.
          #
          # Empty counts contribute their value; pieces contribute 1 each.
          #
          # @param segment [Array] The segment tokens
          # @return [Integer] The number of squares
          def segment_size(segment)
            segment.sum do |token|
              ::Integer === token ? token : 1
            end
          end

          # ------------------------------------------------------------------
          # Board Construction
          # ------------------------------------------------------------------

          # Builds a nested board array from parsed segments and separators.
          #
          # Expands each segment into a flat rank array (pieces as EPIN
          # strings, empty squares as nil), then nests ranks into layers
          # and higher dimensions based on separator depths.
          #
          # @param segments [Array<Array>] Parsed segments (Integer/String tokens)
          # @param separators [Array<Integer>] Separator depths
          # @return [Array] Nested board array
          def build_board(segments, separators)
            ranks = segments.map { |seg| expand_segment(seg) }

            # 1D: single segment, no separators
            return ranks[0] if separators.empty?

            max_depth = separators.max

            # 2D: all separators are depth-1
            return ranks if max_depth == 1

            # 3D+: recursively nest by separator depth
            nest(ranks, separators, max_depth)
          end

          # Expands a segment of tokens into a flat rank array.
          #
          # Integer tokens become runs of nil (empty squares).
          # String tokens remain as EPIN piece identifiers.
          #
          # @param segment [Array<Integer, String>] Segment tokens
          # @return [Array<String, nil>] Flat rank array
          def expand_segment(segment)
            result = []

            segment.each do |token|
              if ::Integer === token
                token.times { result << nil }
              else
                result << token
              end
            end

            result
          end

          # Recursively nests rank arrays into higher-dimensional structures.
          #
          # Splits ranks at separators of the given depth, then recursively
          # processes each group at the next lower depth.
          #
          # @param ranks [Array<Array>] Flat list of expanded rank arrays
          # @param separators [Array<Integer>] Separator depths between ranks
          # @param depth [Integer] Current grouping depth
          # @return [Array] Nested array structure
          def nest(ranks, separators, depth)
            return ranks if depth <= 1

            groups = []
            group_ranks = [ranks[0]]
            group_seps = []

            separators.each_with_index do |sep_depth, i|
              if sep_depth >= depth
                groups << nest(group_ranks, group_seps, depth - 1)
                group_ranks = [ranks[i + 1]]
                group_seps = []
              else
                group_seps << sep_depth
                group_ranks << ranks[i + 1]
              end
            end

            groups << nest(group_ranks, group_seps, depth - 1)
            groups
          end
        end

        private_class_method :validate_not_empty!,
                             :validate_boundaries!,
                             :extract_segments_and_separators,
                             :parse_segment,
                             :validate_no_consecutive_empty_counts!,
                             :parse_empty_count,
                             :validate_empty_count!,
                             :parse_piece,
                             :parse_separator,
                             :validate_segments!,
                             :validate_dimensional_coherence!,
                             :validate_separator_hierarchy!,
                             :validate_dimension_sizes!,
                             :segment_size,
                             :build_board,
                             :expand_segment,
                             :nest

        freeze
      end
    end
  end
end
