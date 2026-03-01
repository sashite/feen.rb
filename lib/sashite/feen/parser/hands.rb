# frozen_string_literal: true

require_relative "../shared/ascii"
require_relative "../errors/hands_error"
require_relative "hand"

module Sashite
  module Feen
    module Parser
      # Parser for the FEEN Hands field (Field 2).
      #
      # Format: <FIRST-HAND>/<SECOND-HAND>
      # Exactly one "/" delimiter must be present.
      #
      # Provides a dual-path API:
      # - {.safe_parse} returns nil on invalid input (no exceptions)
      # - {.parse} raises {HandsError} on invalid input
      #
      # @api private
      module Hands
        # Parses the Hands field, returning nil on failure.
        #
        # @param input [String] The hands field string
        # @return [Hash{Symbol => Array<String>}, nil] Parsed hands or nil
        def self.safe_parse(input)
          # Find the single "/" delimiter by scanning bytes
          slash_pos = nil
          i = 0
          len = input.bytesize

          while i < len
            if input.getbyte(i) == Ascii::SLASH
              return nil if slash_pos # second slash => invalid

              slash_pos = i
            end
            i += 1
          end

          return nil unless slash_pos # no slash => invalid

          first_str = slash_pos == 0 ? "" : input.byteslice(0, slash_pos)
          second_str = slash_pos == len - 1 ? "" : input.byteslice(slash_pos + 1, len - slash_pos - 1)

          first = Hand.safe_parse(first_str)
          return nil if first.nil?

          second = Hand.safe_parse(second_str)
          return nil if second.nil?

          { first: first, second: second }
        end

        # Parses the Hands field, raising on failure.
        #
        # @param input [String] The hands field string
        # @return [Hash{Symbol => Array<String>}] Parsed hands
        # @raise [HandsError] If the input is not valid
        def self.parse(input)
          result = safe_parse(input)
          return result unless result.nil?

          raise_specific_error!(input)
        end

        class << self
          private

          # Re-validates to produce the specific error message.
          def raise_specific_error!(input)
            # Validate delimiter
            slash_pos = nil
            i = 0
            len = input.bytesize

            while i < len
              if input.getbyte(i) == Ascii::SLASH
                raise HandsError, HandsError::INVALID_DELIMITER if slash_pos

                slash_pos = i
              end
              i += 1
            end

            raise HandsError, HandsError::INVALID_DELIMITER unless slash_pos

            first_str = slash_pos == 0 ? "" : input.byteslice(0, slash_pos)
            second_str = slash_pos == len - 1 ? "" : input.byteslice(slash_pos + 1, len - slash_pos - 1)

            # Delegate to Hand.parse for specific error
            Hand.parse(first_str)
            Hand.parse(second_str)
          end
        end

        private_class_method :raise_specific_error!

        freeze
      end
    end
  end
end
