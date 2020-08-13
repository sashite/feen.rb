# frozen_string_literal: true

module FEEN
  module Parser
    # The turn class.
    class Turn
      attr_reader :char

      def initialize(char)
        @char = char
      end

      def topside?
        char.eql?('t')
      end
    end
  end
end
