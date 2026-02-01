# frozen_string_literal: true

require_relative "../shared/separators"
require_relative "../errors/hands_error"
require_relative "hand"

module Sashite
  module Feen
    module Parser
      # Parser for FEEN Hands field (Field 2).
      #
      # The Hands field encodes off-board pieces held by each player:
      #
      #   <FIRST-HAND>/<SECOND-HAND>
      #
      # The "/" delimiter is always present. Either hand may be empty.
      #
      # Hand attribution:
      # - Left of "/" → First Player Hand
      # - Right of "/" → Second Player Hand
      #
      # The Piece Side encoded inside EPIN tokens is independent of the
      # Hand's associated Side. A piece with Piece Side `first` may be
      # located in the Second Player Hand, and vice versa.
      #
      # @example Parsing empty hands
      #   Hands.parse("/")
      #   # => { first: [], second: [] }
      #
      # @example Parsing hands with pieces
      #   Hands.parse("2PN/p")
      #   # => { first: [...], second: [...] }
      #
      # @see https://sashite.dev/specs/feen/1.0.0/
      # @api private
      module Hands
        # Parses a FEEN Hands field string.
        #
        # @param input [String] The Hands field string
        # @return [Hash] A hash with :first and :second keys
        # @raise [HandsError] If the input is not valid
        def self.parse(input)
          validate_delimiter!(input)

          first_str, second_str = input.split(Separators::SEGMENT, -1)

          first = Hand.parse(first_str)
          second = Hand.parse(second_str)

          { first:, second: }
        end

        class << self
          private

          # Validates that the input contains exactly one delimiter.
          #
          # @param input [String] The input to validate
          # @raise [HandsError] If delimiter is missing or duplicated
          def validate_delimiter!(input)
            count = input.count(Separators::SEGMENT)

            raise HandsError, HandsError::INVALID_DELIMITER unless count == 1
          end
        end

        private_class_method :validate_delimiter!

        freeze
      end
    end
  end
end
