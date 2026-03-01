# frozen_string_literal: true

require_relative "../shared/ascii"
require_relative "../errors/style_turn_error"

module Sashite
  module Feen
    module Parser
      # Parser for the FEEN Style-Turn field (Field 3).
      #
      # Format: <ACTIVE-STYLE>/<INACTIVE-STYLE>
      # Each style is a valid SIN token (exactly one ASCII letter).
      # The two tokens must be of opposite case.
      #
      # @api private
      module StyleTurn
        # Parses a Style-Turn field, returning nil on failure.
        #
        # @param input [String] The Style-Turn field string
        # @return [Hash, nil]
        def self.safe_parse(input)
          # Exactly 3 bytes: letter "/" letter
          return nil unless input.bytesize == 3

          return nil unless input.getbyte(1) == Ascii::SLASH

          active_byte = input.getbyte(0)
          inactive_byte = input.getbyte(2)

          # Both must be ASCII letters (inline SIN validation)
          active_lowered = active_byte | 0x20
          return nil if active_lowered < Ascii::LOWER_A || active_lowered > Ascii::LOWER_Z

          inactive_lowered = inactive_byte | 0x20
          return nil if inactive_lowered < Ascii::LOWER_A || inactive_lowered > Ascii::LOWER_Z

          # Must be opposite case
          active_upper = active_byte < Ascii::LOWER_A
          inactive_upper = inactive_byte < Ascii::LOWER_A
          return nil if active_upper == inactive_upper

          active_str = input.byteslice(0, 1)
          inactive_str = input.byteslice(2, 1)

          if active_upper
            { styles: { first: active_str, second: inactive_str }, turn: :first }
          else
            { styles: { first: inactive_str, second: active_str }, turn: :second }
          end
        end

        # Parses a Style-Turn field, raising on failure.
        #
        # @param input [String] The Style-Turn field string
        # @return [Hash]
        # @raise [StyleTurnError] If the input is not valid
        def self.parse(input)
          result = safe_parse(input)
          return result unless result.nil?

          raise_specific_error!(input)
        end

        class << self
          private

          def raise_specific_error!(input)
            # Find single slash delimiter
            slash_pos = nil
            i = 0
            len = input.bytesize

            while i < len
              if input.getbyte(i) == Ascii::SLASH
                raise StyleTurnError, StyleTurnError::INVALID_DELIMITER if slash_pos

                slash_pos = i
              end
              i += 1
            end

            raise StyleTurnError, StyleTurnError::INVALID_DELIMITER unless slash_pos

            # Validate each SIN token (single ASCII letter)
            unless slash_pos == 1 && valid_sin_byte?(input.getbyte(0))
              raise StyleTurnError, StyleTurnError::INVALID_STYLE_TOKEN
            end

            unless (len - slash_pos - 1) == 1 && valid_sin_byte?(input.getbyte(slash_pos + 1))
              raise StyleTurnError, StyleTurnError::INVALID_STYLE_TOKEN
            end

            raise StyleTurnError, StyleTurnError::SAME_CASE
          end

          def valid_sin_byte?(byte)
            byte && (byte | 0x20) >= Ascii::LOWER_A && (byte | 0x20) <= Ascii::LOWER_Z
          end
        end

        private_class_method :raise_specific_error!,
                             :valid_sin_byte?

        freeze
      end
    end
  end
end
