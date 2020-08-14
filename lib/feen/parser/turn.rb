# frozen_string_literal: true

require_relative 'invalid_turn_char_error'

module FEEN
  module Parser
    # The turn class.
    class Turn
      TOPSIDE = {
        'B' => false,
        't' => true
      }.freeze

      # @param char [String] The identifier of bottom-side and top-side.
      def initialize(char)
        raise InvalidTurnCharError unless TOPSIDE.key?(char)

        @char = char
      end

      # @return [Boolean] Returns true if topside have to play, false otherwise.
      def topside?
        TOPSIDE.fetch(@char)
      end
    end
  end
end
