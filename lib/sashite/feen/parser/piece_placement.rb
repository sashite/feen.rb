# frozen_string_literal: true

require "sashite/epin"

require_relative "../constants"
require_relative "../errors"

module Sashite
  module Feen
    module Parser
      # Parser for FEEN Piece Placement field (Field 1).
      #
      # The Piece Placement field encodes board occupancy as a stream of tokens
      # organized into segments separated by one or more slash characters.
      #
      # Segment separators indicate dimensional boundaries:
      # - "/" separates ranks (1D boundary)
      # - "//" separates layers (2D boundary)
      # - "///" separates higher dimensions (3D boundary)
      #
      # Within each segment, content is a concatenation of placement tokens:
      # - Empty-count token: a base-10 integer (≥ 1, no leading zeros)
      # - Piece token: a valid EPIN identifier
      #
      # Canonical form requirements:
      # - No empty segments
      # - No consecutive empty-count tokens (must be merged)
      # - Dimensional coherence (separator depth matches structure)
      #
      # @api private
      #
      # @example Parsing a simple 1D board
      #   PiecePlacement.parse("K2Q")
      #   # => { segments: [[<K>, 2, <Q>]], separators: [] }
      #
      # @example Parsing a 2D board (Chess-like)
      #   PiecePlacement.parse("8/8/8/8/8/8/8/8")
      #   # => { segments: [[8], [8], ...], separators: ["/", "/", ...] }
      #
      # @example Parsing a 3D board
      #   PiecePlacement.parse("4/4//4/4")
      #   # => { segments: [[4], [4], [4], [4]], separators: ["/", "//", "/"] }
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      module PiecePlacement
        # Parses a FEEN Piece Placement field string.
        #
        # @param input [String] The Piece Placement field string
        # @return [Hash] A hash with :segments and :separators keys
        # @raise [Errors::Argument] If the input is not valid
        def self.parse(input)
          validate_not_empty!(input)
          validate_boundaries!(input)

          segments, separators = extract_segments_and_separators(input)

          validate_segments!(segments)
          validate_dimensional_coherence!(separators)
          validate_dimension_sizes!(segments)

          { segments:, separators: }
        end

        class << self
          private

          # ASCII byte constants for efficient parsing.
          SLASH = 0x2F       # '/'
          ZERO = 0x30        # '0'
          NINE = 0x39        # '9'
          UPPER_A = 0x41     # 'A'
          UPPER_Z = 0x5A     # 'Z'
          LOWER_A = 0x61     # 'a'
          LOWER_Z = 0x7A     # 'z'
          PLUS = 0x2B        # '+'
          MINUS = 0x2D       # '-'
          CARET = 0x5E       # '^'
          APOSTROPHE = 0x27  # "'"

          # Validates that input is not empty.
          #
          # @param input [String] The input to validate
          # @raise [Errors::Argument] If input is empty
          def validate_not_empty!(input)
            return unless input.empty?

            raise Errors::Argument, Errors::Argument::Messages::PIECE_PLACEMENT_EMPTY
          end

          # Validates that input doesn't start or end with separator.
          #
          # @param input [String] The input to validate
          # @raise [Errors::Argument] If boundaries are invalid
          def validate_boundaries!(input)
            if input.getbyte(0) == SLASH
              raise Errors::Argument, Errors::Argument::Messages::PIECE_PLACEMENT_STARTS_WITH_SEPARATOR
            end

            if input.getbyte(input.bytesize - 1) == SLASH
              raise Errors::Argument, Errors::Argument::Messages::PIECE_PLACEMENT_ENDS_WITH_SEPARATOR
            end
          end

          # Extracts segments and separators from the input string.
          #
          # @param input [String] The input to parse
          # @return [Array(Array<Array>, Array<String>)] Segments and separators
          def extract_segments_and_separators(input)
            segments = []
            separators = []
            pos = 0

            while pos < input.bytesize
              segment, pos = parse_segment(input, pos)
              segments << segment

              if pos < input.bytesize
                separator, pos = parse_separator(input, pos)
                separators << separator
              end
            end

            [segments, separators]
          end

          # Parses a segment (sequence of placement tokens until separator or end).
          #
          # @param str [String] The string to parse
          # @param pos [Integer] Starting position
          # @return [Array(Array, Integer)] The segment tokens and new position
          def parse_segment(str, pos)
            tokens = []
            previous_was_empty_count = false

            while pos < str.bytesize
              byte = str.getbyte(pos)

              break if byte == SLASH

              if digit?(byte)
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
          # @param previous_was_empty_count [Boolean] Whether previous token was an empty count
          # @raise [Errors::Argument] If consecutive empty counts detected
          def validate_no_consecutive_empty_counts!(previous_was_empty_count)
            return unless previous_was_empty_count

            raise Errors::Argument, Errors::Argument::Messages::CONSECUTIVE_EMPTY_COUNTS
          end

          # Parses an empty-count token.
          #
          # @param str [String] The string to parse
          # @param pos [Integer] Starting position
          # @return [Array(Integer, Integer)] The count and new position
          # @raise [Errors::Argument] If count is invalid
          def parse_empty_count(str, pos)
            start_pos = pos
            pos += 1 while pos < str.bytesize && digit?(str.getbyte(pos))

            count_str = str.byteslice(start_pos, pos - start_pos)
            validate_empty_count!(count_str)

            [count_str.to_i, pos]
          end

          # Validates an empty-count string.
          #
          # @param count_str [String] The count string to validate
          # @raise [Errors::Argument] If count has leading zeros or is zero
          def validate_empty_count!(count_str)
            # Leading zeros are forbidden (includes "0" itself since count must be ≥ 1)
            return unless count_str.getbyte(0) == ZERO

            raise Errors::Argument, Errors::Argument::Messages::INVALID_EMPTY_COUNT
          end

          # Parses an EPIN piece token.
          #
          # EPIN structure: [+-]?[A-Za-z]\^?'?
          #
          # @param str [String] The string to parse
          # @param pos [Integer] Starting position
          # @return [Array(Sashite::Epin::Identifier, Integer)] The parsed EPIN and new position
          # @raise [Errors::Argument] If EPIN parsing fails
          def parse_piece(str, pos)
            start_pos = pos
            byte = str.getbyte(pos)

            # Optional state modifier: + or -
            if byte == PLUS || byte == MINUS
              pos += 1
              byte = str.getbyte(pos)
            end

            # Required letter: A-Z or a-z
            if letter?(byte)
              pos += 1
              byte = str.getbyte(pos)
            end

            # Optional terminal marker: ^
            if byte == CARET
              pos += 1
              byte = str.getbyte(pos)
            end

            # Optional derivation marker: '
            pos += 1 if byte == APOSTROPHE

            epin_str = str.byteslice(start_pos, pos - start_pos)

            begin
              piece = ::Sashite::Epin.parse(epin_str)
            rescue ::ArgumentError
              raise Errors::Argument, Errors::Argument::Messages::INVALID_PIECE_TOKEN
            end

            [piece, pos]
          end

          # Parses a separator group (one or more slashes).
          #
          # @param str [String] The string to parse
          # @param pos [Integer] Starting position
          # @return [Array(String, Integer)] The separator string and new position
          def parse_separator(str, pos)
            start_pos = pos
            pos += 1 while pos < str.bytesize && str.getbyte(pos) == SLASH

            separator = str.byteslice(start_pos, pos - start_pos)

            [separator, pos]
          end

          # Validates that all segments are non-empty.
          #
          # @param segments [Array<Array>] The segments to validate
          # @raise [Errors::Argument] If any segment is empty
          def validate_segments!(segments)
            segments.each do |segment|
              if segment.empty?
                raise Errors::Argument, Errors::Argument::Messages::EMPTY_SEGMENT
              end
            end
          end

          # Validates dimensional coherence of separators.
          #
          # A separator of length N indicates a boundary at dimension N.
          # This requires that all segments between such separators contain
          # separators of length N-1, ensuring proper dimensional hierarchy.
          #
          # @param separators [Array<String>] The separators to validate
          # @raise [Errors::Argument] If dimensional coherence is violated
          def validate_dimensional_coherence!(separators)
            return if separators.empty?

            max_depth = separators.map(&:length).max

            if max_depth > Constants::MAX_DIMENSIONS
              raise Errors::Argument, Errors::Argument::Messages::EXCEEDS_MAX_DIMENSIONS
            end

            validate_separator_hierarchy!(separators, max_depth)
          end

          # Validates that separator hierarchy is properly structured.
          #
          # For a valid N-dimensional board:
          # - Between "//" separators, there must be "/" separators
          # - Between "///" separators, there must be "//" separators
          #
          # @param separators [Array<String>] The separators to validate
          # @param max_depth [Integer] Maximum separator depth
          # @raise [Errors::Argument] If hierarchy is invalid
          def validate_separator_hierarchy!(separators, max_depth)
            return if max_depth <= 1

            # For each dimension level from max down to 2,
            # verify proper structure exists at the level below
            (2..max_depth).each do |depth|
              current_sep = "/" * depth
              lower_sep = "/" * (depth - 1)

              # Find positions of current depth separators
              indices = separators.each_index.select { |i| separators[i].length >= depth }

              next if indices.empty?

              # Check that between each pair of depth-N separators (or boundaries),
              # there exists at least one depth-(N-1) separator
              check_points = [-1] + indices + [separators.length]

              check_points.each_cons(2) do |start_idx, end_idx|
                range_start = start_idx + 1
                range_end = end_idx - 1

                next if range_start > range_end

                has_lower = (range_start..range_end).any? do |i|
                  separators[i] == lower_sep
                end

                unless has_lower
                  raise Errors::Argument, Errors::Argument::Messages::DIMENSIONAL_COHERENCE_VIOLATION
                end
              end
            end
          end

          # Validates that no dimension exceeds the maximum size.
          #
          # @param segments [Array<Array>] The segments to validate
          # @raise [Errors::Argument] If any dimension is too large
          def validate_dimension_sizes!(segments)
            segments.each do |segment|
              size = segment_size(segment)

              if size > Constants::MAX_DIMENSION_SIZE
                raise Errors::Argument, Errors::Argument::Messages::DIMENSION_SIZE_EXCEEDED
              end
            end
          end

          # Calculates the size (number of squares) of a segment.
          #
          # @param segment [Array] The segment tokens
          # @return [Integer] The number of squares
          def segment_size(segment)
            segment.sum do |token|
              case token
              when ::Integer then token
              else 1
              end
            end
          end

          # Checks if byte is an ASCII digit (0-9).
          #
          # @param byte [Integer, nil] The byte to check
          # @return [Boolean]
          def digit?(byte)
            byte && byte >= ZERO && byte <= NINE
          end

          # Checks if byte is an ASCII letter (A-Z or a-z).
          #
          # @param byte [Integer, nil] The byte to check
          # @return [Boolean]
          def letter?(byte)
            byte && ((byte >= UPPER_A && byte <= UPPER_Z) || (byte >= LOWER_A && byte <= LOWER_Z))
          end
        end
      end
    end
  end
end
