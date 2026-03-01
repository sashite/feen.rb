# frozen_string_literal: true

require_relative "../shared/ascii"
require_relative "../errors/hands_error"

module Sashite
  module Feen
    module Parser
      # Parser for a single hand within the FEEN Hands field.
      #
      # Provides a dual-path API:
      # - {.safe_parse} returns nil on invalid input (no exceptions)
      # - {.parse} raises {HandsError} on invalid input
      #
      # @api private
      module Hand
        # Parses a single hand string, returning nil on failure.
        #
        # @param input [String] The hand string to parse
        # @return [Array<String>, nil] Expanded piece array, or nil if invalid
        def self.safe_parse(input)
          return [] if input.empty?

          items = []
          pos = 0
          len = input.bytesize
          prev_count = 0
          prev_key = 0
          prev_piece = nil

          while pos < len
            # -- Extract optional count --
            byte = input.getbyte(pos)

            if byte >= Ascii::ZERO && byte <= Ascii::NINE
              count_start = pos
              pos += 1
              pos += 1 while pos < len && (b = input.getbyte(pos)) && b >= Ascii::ZERO && b <= Ascii::NINE

              # Leading zeros forbidden
              return nil if (pos - count_start) > 1 && input.getbyte(count_start) == Ascii::ZERO

              count = input.byteslice(count_start, pos - count_start).to_i

              # Explicit count must be >= 2
              return nil if count < 2

              byte = input.getbyte(pos)
            else
              count = 1
            end

            # -- Extract EPIN token + compute sort key inline --
            piece_start = pos

            # Optional state modifier: - (0), + (1), none (2)
            if byte == Ascii::MINUS
              state = 0
              pos += 1
              byte = input.getbyte(pos)
            elsif byte == Ascii::PLUS
              state = 1
              pos += 1
              byte = input.getbyte(pos)
            else
              state = 2
            end

            # Required letter (inline letter? check)
            return nil unless byte

            lowered = byte | 0x20
            return nil if lowered < Ascii::LOWER_A || lowered > Ascii::LOWER_Z

            case_rank = byte < Ascii::LOWER_A ? 0 : 1 # uppercase = 0
            pos += 1
            byte = input.getbyte(pos)

            # Optional terminal marker ^
            if byte == Ascii::CARET
              terminal = 1
              pos += 1
              byte = input.getbyte(pos)
            else
              terminal = 0
            end

            # Optional derivation marker '
            if byte == Ascii::APOSTROPHE
              derived = 1
              pos += 1
            else
              derived = 0
            end

            piece = input.byteslice(piece_start, pos - piece_start)

            # Sort key encodes all 5 ordering criteria into a single integer:
            #   bits 9..5: base letter (a=1..z=26)
            #   bit  4:    case rank (0=upper, 1=lower)
            #   bits 3..2: state (0=diminished, 1=enhanced, 2=normal)
            #   bit  1:    terminal (0=absent, 1=present)
            #   bit  0:    derived (0=absent, 1=present)
            sort_key = ((lowered & 0x1F) << 5) | (case_rank << 4) | (state << 2) | (terminal << 1) | derived

            # -- Inline aggregation + canonical order check --
            if prev_piece
              return nil if piece == prev_piece # not aggregated

              # Canonical order: count descending, then sort_key ascending
              if prev_count == count
                return nil if prev_key >= sort_key
              else
                return nil if prev_count < count
              end
            end

            items << [count, piece]
            prev_count = count
            prev_key = sort_key
            prev_piece = piece
          end

          # Expand into flat array
          result = []
          items.each { |c, p| c.times { result << p } }
          result
        end

        # Parses a single hand string, raising on failure.
        #
        # @param input [String] The hand string to parse
        # @return [Array<String>] Expanded piece array
        # @raise [HandsError] If the input is not valid
        def self.parse(input)
          result = safe_parse(input)
          return result unless result.nil?

          raise_specific_error!(input)
        end

        class << self
          private

          # Re-validates to produce the specific error message.
          # Only called on the error path (cold).
          def raise_specific_error!(input)
            items = []
            pos = 0
            len = input.bytesize

            while pos < len
              byte = input.getbyte(pos)

              # Extract count
              if byte >= Ascii::ZERO && byte <= Ascii::NINE
                count_start = pos
                pos += 1
                pos += 1 while pos < len && (b = input.getbyte(pos)) && b >= Ascii::ZERO && b <= Ascii::NINE

                count_str = input.byteslice(count_start, pos - count_start)
                if count_str.bytesize > 1 && count_str.getbyte(0) == Ascii::ZERO
                  raise HandsError, HandsError::INVALID_COUNT
                end

                count = count_str.to_i
                raise HandsError, HandsError::INVALID_COUNT if count < 2

                byte = input.getbyte(pos)
              else
                count = 1
              end

              # Extract EPIN token
              piece_start = pos

              if byte == Ascii::PLUS || byte == Ascii::MINUS
                pos += 1
                byte = input.getbyte(pos)
              end

              if byte && (byte | 0x20) >= Ascii::LOWER_A && (byte | 0x20) <= Ascii::LOWER_Z
                pos += 1
                byte = input.getbyte(pos)
              end

              byte == Ascii::CARET && (pos += 1) && (byte = input.getbyte(pos))
              byte == Ascii::APOSTROPHE && (pos += 1)

              piece = input.byteslice(piece_start, pos - piece_start)
              raise HandsError, HandsError::INVALID_PIECE_TOKEN if piece.empty? || !valid_epin?(piece)

              items << [count, piece]
            end

            # Check aggregation
            if items.size > 1
              seen = {}
              items.each do |_c, p|
                raise HandsError, HandsError::NOT_AGGREGATED if seen[p]

                seen[p] = true
              end
            end

            # Check canonical order
            raise HandsError, HandsError::NOT_CANONICAL
          end

          # Inline EPIN validation: [-+]?[A-Za-z]^?'?
          def valid_epin?(str)
            pos = 0
            byte = str.getbyte(pos)

            if byte == Ascii::PLUS || byte == Ascii::MINUS
              pos += 1
              byte = str.getbyte(pos)
            end

            return false unless byte && (byte | 0x20) >= Ascii::LOWER_A && (byte | 0x20) <= Ascii::LOWER_Z

            pos += 1
            byte = str.getbyte(pos)

            if byte == Ascii::CARET
              pos += 1
              byte = str.getbyte(pos)
            end

            pos += 1 if byte == Ascii::APOSTROPHE

            pos == str.bytesize
          end
        end

        private_class_method :raise_specific_error!,
                             :valid_epin?

        freeze
      end
    end
  end
end
