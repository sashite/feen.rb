# frozen_string_literal: true

require "sashite/epin"

require_relative "../constants"
require_relative "../errors"

module Sashite
  module Feen
    module Parser
      # Parser for FEEN Piece Placement field (Field 1).
      #
      # The Piece Placement field encodes Board occupancy as a stream of tokens
      # organized into segments separated by one or more slash characters.
      #
      # Within each segment, the content is a concatenation of placement tokens:
      # - Empty-count token: a base-10 integer (≥ 1, no leading zeros)
      # - Piece token: a valid EPIN token
      #
      # @example
      #   PiecePlacement.parse("8")
      #   # => { segments: [[8]], separators: [] }
      #
      #   PiecePlacement.parse("r2k/8")
      #   # => { segments: [[<r>, 2, <k>], [8]], separators: ["/"] }
      #
      #   PiecePlacement.parse("8/8//8")
      #   # => { segments: [[8], [8], [8]], separators: ["/", "//"] }
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      module PiecePlacement
        # Parses a FEEN Piece Placement field string.
        #
        # @param input [String] The Piece Placement field string
        # @return [Hash] A hash with :segments and :separators keys
        # @raise [Errors::Argument] If the input is not valid
        def self.parse(input)
          validate_boundaries!(input)

          segments = []
          separators = []
          pos = 0

          while pos < input.bytesize
            # Parse a segment
            segment, pos = parse_segment(input, pos)
            segments << segment

            # Parse separator group if present
            if pos < input.bytesize
              separator, pos = parse_separator(input, pos)
              separators << separator
            end
          end

          { segments: segments, separators: separators }
        end

        class << self
          private

          # Validates that input doesn't start or end with separator.
          #
          # @param input [String] The input to validate
          # @raise [Errors::Argument] If boundaries are invalid
          def validate_boundaries!(input)
            if input.empty?
              raise Errors::Argument, Errors::Argument::Messages::EMPTY_INPUT
            end

            if input.getbyte(0) == 0x2F
              raise Errors::Argument, Errors::Argument::Messages::PIECE_PLACEMENT_STARTS_WITH_SEPARATOR
            end

            if input.getbyte(input.bytesize - 1) == 0x2F
              raise Errors::Argument, Errors::Argument::Messages::PIECE_PLACEMENT_ENDS_WITH_SEPARATOR
            end
          end

          # Parses a segment (sequence of placement tokens until separator or end).
          #
          # @param str [String] The string to parse
          # @param pos [Integer] Starting position
          # @return [Array(Array, Integer)] The segment tokens and new position
          def parse_segment(str, pos)
            tokens = []

            while pos < str.bytesize
              byte = str.getbyte(pos)

              # Stop at separator
              break if byte == 0x2F

              if digit?(byte)
                # Empty-count token
                count, pos = parse_empty_count(str, pos)
                tokens << count
              else
                # Piece token (EPIN)
                piece, pos = parse_piece(str, pos)
                tokens << piece
              end
            end

            [tokens, pos]
          end

          # Parses an empty-count token.
          #
          # @param str [String] The string to parse
          # @param pos [Integer] Starting position
          # @return [Array(Integer, Integer)] The count and new position
          # @raise [Errors::Argument] If count is invalid
          def parse_empty_count(str, pos)
            start_pos = pos
            pos += 1

            # Consume remaining digits
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
            if count_str.getbyte(0) == 0x30
              raise Errors::Argument, Errors::Argument::Messages::INVALID_EMPTY_COUNT
            end
          end

          # Parses an EPIN piece token.
          #
          # EPIN structure: [+-]?[A-Za-z]\^?'?
          #
          # @param str [String] The string to parse
          # @param pos [Integer] Starting position
          # @return [Array(Sashite::Epin::Identifier, Integer)] The parsed EPIN and new position
          # @raise [Sashite::Epin::Errors::Argument] If EPIN parsing fails
          def parse_piece(str, pos)
            start_pos = pos
            byte = str.getbyte(pos)

            # Optional state modifier: + or -
            if byte == 0x2B || byte == 0x2D
              pos += 1
              byte = str.getbyte(pos)
            end

            # Required letter: A-Z or a-z
            if letter?(byte)
              pos += 1
              byte = str.getbyte(pos)
            end

            # Optional terminal marker: ^
            if byte == 0x5E
              pos += 1
              byte = str.getbyte(pos)
            end

            # Optional derivation marker: '
            pos += 1 if byte == 0x27

            epin_str = str.byteslice(start_pos, pos - start_pos)
            piece = ::Sashite::Epin.parse(epin_str)

            [piece, pos]
          end

          # Parses a separator group (one or more slashes).
          #
          # @param str [String] The string to parse
          # @param pos [Integer] Starting position
          # @return [Array(String, Integer)] The separator string and new position
          def parse_separator(str, pos)
            start_pos = pos

            # Consume all consecutive slashes
            pos += 1 while pos < str.bytesize && str.getbyte(pos) == 0x2F

            separator = str.byteslice(start_pos, pos - start_pos)

            [separator, pos]
          end

          # Checks if byte is an ASCII digit (0-9).
          #
          # @param byte [Integer, nil] The byte to check
          # @return [Boolean]
          def digit?(byte)
            byte && byte >= 0x30 && byte <= 0x39
          end

          # Checks if byte is an ASCII letter (A-Z or a-z).
          #
          # @param byte [Integer, nil] The byte to check
          # @return [Boolean]
          def letter?(byte)
            byte && ((byte >= 0x41 && byte <= 0x5A) || (byte >= 0x61 && byte <= 0x7A))
          end
        end
      end
    end
  end
end
