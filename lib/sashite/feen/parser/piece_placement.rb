# frozen_string_literal: true

require_relative "../shared/ascii"
require_relative "../shared/limits"
require_relative "../errors/piece_placement_error"

module Sashite
  module Feen
    module Parser
      # Parser for the FEEN Piece Placement field (Field 1).
      #
      # Parses into a dimensioned board structure:
      # - 1D: flat Array of squares
      # - 2D: Array of rank Arrays
      # - 3D: Array of layer Arrays of rank Arrays
      #
      # @api private
      module PiecePlacement
        # Parses a Piece Placement field, returning nil on failure.
        #
        # @param input [String] The Piece Placement field string
        # @return [Array, nil] Dimensioned board structure or nil
        def self.safe_parse(input)
          return nil if input.empty?

          len = input.bytesize
          return nil if input.getbyte(0) == Ascii::SLASH
          return nil if input.getbyte(len - 1) == Ascii::SLASH

          max_sep = scan_max_separator(input, len)
          dims = max_sep + 1
          return nil if dims > Limits::MAX_DIMENSIONS

          case dims
          when 1 then parse_1d(input, len)
          when 2 then parse_2d(input, len)
          when 3 then parse_3d(input, len)
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
          def scan_max_separator(input, len)
            max = 0
            cur = 0
            i = 0

            while i < len
              if input.getbyte(i) == Ascii::SLASH
                cur += 1
              else
                max = cur if cur > max
                cur = 0
              end
              i += 1
            end

            max = cur if cur > max
            max
          end

          # Parses a 1D board (no separators).
          def parse_1d(input, len)
            squares = parse_segment(input, 0, len)
            return nil if squares.nil?
            return nil if squares.size > Limits::MAX_DIMENSION_SIZE

            squares
          end

          # Parses a 2D board (ranks separated by "/").
          # Scans for "/" byte positions and parses segments by range.
          def parse_2d(input, len)
            ranks = []
            seg_start = 0
            i = 0

            while i <= len
              if i == len || input.getbyte(i) == Ascii::SLASH
                squares = parse_segment(input, seg_start, i)
                return nil if squares.nil?
                return nil if squares.size > Limits::MAX_DIMENSION_SIZE

                ranks << squares
                seg_start = i + 1
              end
              i += 1
            end

            return nil if ranks.size > Limits::MAX_DIMENSION_SIZE

            ranks
          end

          # Parses a 3D board in a single scan.
          # Detects "//" layer boundaries and "/" rank boundaries.
          def parse_3d(input, len)
            layers = []
            ranks = []
            seg_start = 0
            ranks_per_layer = nil
            i = 0

            while i < len
              if input.getbyte(i) == Ascii::SLASH
                # Parse the pending segment
                squares = parse_segment(input, seg_start, i)
                return nil if squares.nil?
                return nil if squares.size > Limits::MAX_DIMENSION_SIZE

                ranks << squares

                # Check for "//" (layer boundary)
                if (i + 1) < len && input.getbyte(i + 1) == Ascii::SLASH
                  # Dimensional coherence: each layer must have >= 2 ranks
                  return nil if ranks.size < 2

                  if ranks_per_layer.nil?
                    ranks_per_layer = ranks.size
                    return nil if ranks_per_layer > Limits::MAX_DIMENSION_SIZE
                  else
                    return nil unless ranks.size == ranks_per_layer
                  end

                  layers << ranks
                  ranks = []
                  seg_start = i + 2
                  i += 2
                else
                  seg_start = i + 1
                  i += 1
                end
              else
                i += 1
              end
            end

            # Last segment + last layer
            squares = parse_segment(input, seg_start, len)
            return nil if squares.nil?
            return nil if squares.size > Limits::MAX_DIMENSION_SIZE

            ranks << squares

            return nil if ranks.size < 2

            if ranks_per_layer.nil?
              ranks_per_layer = ranks.size
              return nil if ranks_per_layer > Limits::MAX_DIMENSION_SIZE
            else
              return nil unless ranks.size == ranks_per_layer
            end

            layers << ranks
            return nil if layers.size > Limits::MAX_DIMENSION_SIZE

            layers
          end

          # Parses a single segment (rank) by byte range [seg_start, seg_stop).
          # Returns Array of (String | nil) or nil on failure.
          # Inlines EPIN validation and integer conversion.
          def parse_segment(input, seg_start, seg_stop)
            return nil if seg_start >= seg_stop

            squares = []
            pos = seg_start
            last_was_empty = false

            while pos < seg_stop
              byte = input.getbyte(pos)

              if byte >= Ascii::ZERO && byte <= Ascii::NINE
                # Empty count token
                return nil if last_was_empty

                count_start = pos
                pos += 1
                while pos < seg_stop
                  b = input.getbyte(pos)
                  break unless b >= Ascii::ZERO && b <= Ascii::NINE

                  pos += 1
                end

                # Leading zeros forbidden
                return nil if (pos - count_start) > 1 && input.getbyte(count_start) == Ascii::ZERO

                # Inline integer conversion (avoids byteslice + to_i)
                count = 0
                j = count_start
                while j < pos
                  count = count * 10 + (input.getbyte(j) - Ascii::ZERO)
                  j += 1
                end

                return nil if count < 1

                count.times { squares << nil }
                last_was_empty = true
              else
                # EPIN token — inline validation: [+-]?[A-Za-z]^?'?
                piece_start = pos

                # Optional state modifier
                if byte == Ascii::MINUS || byte == Ascii::PLUS
                  pos += 1
                  return nil if pos >= seg_stop

                  byte = input.getbyte(pos)
                end

                # Required letter (bit trick)
                lowered = byte | 0x20
                return nil if lowered < Ascii::LOWER_A || lowered > Ascii::LOWER_Z

                pos += 1

                # Optional terminal ^ then optional derivation '
                if pos < seg_stop
                  byte = input.getbyte(pos)

                  if byte == Ascii::CARET
                    pos += 1

                    if pos < seg_stop && input.getbyte(pos) == Ascii::APOSTROPHE
                      pos += 1
                    end
                  elsif byte == Ascii::APOSTROPHE
                    pos += 1
                  end
                end

                squares << input.byteslice(piece_start, pos - piece_start)
                last_was_empty = false
              end
            end

            squares
          end

          # ----------------------------------------------------------------
          # Error path (cold): re-validates for specific error messages
          # ----------------------------------------------------------------

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

            len = input.bytesize
            max_sep = scan_max_separator(input, len)
            dims = max_sep + 1

            if dims > Limits::MAX_DIMENSIONS
              raise PiecePlacementError, PiecePlacementError::EXCEEDS_MAX_DIMENSIONS
            end

            case dims
            when 1 then raise_1d_errors!(input, len)
            when 2 then raise_2d_errors!(input, len)
            when 3 then raise_3d_errors!(input, len)
            end
          end

          def raise_1d_errors!(input, len)
            squares = raise_parse_segment!(input, 0, len)
            raise_dimension_size!(squares.size)
          end

          def raise_2d_errors!(input, len)
            seg_start = 0
            rank_count = 0
            i = 0

            while i <= len
              if i == len || input.getbyte(i) == Ascii::SLASH
                squares = raise_parse_segment!(input, seg_start, i)
                raise_dimension_size!(squares.size)
                rank_count += 1
                seg_start = i + 1
              end
              i += 1
            end

            raise_dimension_size!(rank_count)
          end

          def raise_3d_errors!(input, len)
            ranks_in_layer = 0
            ranks_per_layer = nil
            layer_count = 0
            seg_start = 0
            i = 0

            while i < len
              if input.getbyte(i) == Ascii::SLASH
                squares = raise_parse_segment!(input, seg_start, i)
                raise_dimension_size!(squares.size)
                ranks_in_layer += 1

                if (i + 1) < len && input.getbyte(i + 1) == Ascii::SLASH
                  if ranks_in_layer < 2
                    raise PiecePlacementError, PiecePlacementError::DIMENSIONAL_COHERENCE
                  end

                  if ranks_per_layer.nil?
                    ranks_per_layer = ranks_in_layer
                    raise_dimension_size!(ranks_per_layer)
                  elsif ranks_in_layer != ranks_per_layer
                    raise PiecePlacementError, PiecePlacementError::DIMENSIONAL_COHERENCE
                  end

                  layer_count += 1
                  ranks_in_layer = 0
                  seg_start = i + 2
                  i += 2
                else
                  seg_start = i + 1
                  i += 1
                end
              else
                i += 1
              end
            end

            # Last segment + last layer
            squares = raise_parse_segment!(input, seg_start, len)
            raise_dimension_size!(squares.size)
            ranks_in_layer += 1

            if ranks_in_layer < 2
              raise PiecePlacementError, PiecePlacementError::DIMENSIONAL_COHERENCE
            end

            if ranks_per_layer && ranks_in_layer != ranks_per_layer
              raise PiecePlacementError, PiecePlacementError::DIMENSIONAL_COHERENCE
            end

            layer_count += 1
            raise_dimension_size!(layer_count)
          end

          # Parses a segment on the error path, raising specific errors.
          def raise_parse_segment!(input, seg_start, seg_stop)
            if seg_start >= seg_stop
              raise PiecePlacementError, PiecePlacementError::EMPTY_SEGMENT
            end

            squares = []
            pos = seg_start
            last_was_empty = false

            while pos < seg_stop
              byte = input.getbyte(pos)

              if byte >= Ascii::ZERO && byte <= Ascii::NINE
                if last_was_empty
                  raise PiecePlacementError, PiecePlacementError::CONSECUTIVE_EMPTY_COUNTS
                end

                count_start = pos
                pos += 1
                while pos < seg_stop
                  b = input.getbyte(pos)
                  break unless b >= Ascii::ZERO && b <= Ascii::NINE

                  pos += 1
                end

                if (pos - count_start) > 1 && input.getbyte(count_start) == Ascii::ZERO
                  raise PiecePlacementError, PiecePlacementError::INVALID_EMPTY_COUNT
                end

                count = 0
                j = count_start
                while j < pos
                  count = count * 10 + (input.getbyte(j) - Ascii::ZERO)
                  j += 1
                end

                if count < 1
                  raise PiecePlacementError, PiecePlacementError::INVALID_EMPTY_COUNT
                end

                count.times { squares << nil }
                last_was_empty = true
              else
                piece_start = pos

                if byte == Ascii::MINUS || byte == Ascii::PLUS
                  pos += 1
                  byte = pos < seg_stop ? input.getbyte(pos) : nil
                end

                valid_letter = byte && (byte | 0x20) >= Ascii::LOWER_A && (byte | 0x20) <= Ascii::LOWER_Z

                if valid_letter
                  pos += 1
                  if pos < seg_stop
                    byte = input.getbyte(pos)
                    if byte == Ascii::CARET
                      pos += 1
                      if pos < seg_stop && input.getbyte(pos) == Ascii::APOSTROPHE
                        pos += 1
                      end
                    elsif byte == Ascii::APOSTROPHE
                      pos += 1
                    end
                  end
                end

                unless valid_letter && (pos - piece_start) >= 1
                  raise PiecePlacementError, PiecePlacementError::INVALID_PIECE_TOKEN
                end

                squares << input.byteslice(piece_start, pos - piece_start)
                last_was_empty = false
              end
            end

            squares
          end

          def raise_dimension_size!(size)
            return if size <= Limits::MAX_DIMENSION_SIZE

            raise PiecePlacementError, PiecePlacementError::DIMENSION_SIZE_EXCEEDED
          end
        end

        private_class_method :scan_max_separator,
                             :parse_1d,
                             :parse_2d,
                             :parse_3d,
                             :parse_segment,
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
