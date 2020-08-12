# frozen_string_literal: true

module FEEN
  module Dumper
    # The turn class.
    class Turn
      def initialize(is_topside)
        @is_topside = is_topside
      end

      def call
        topside? ? 't' : 'B'
      end

      private

      def topside?
        @is_topside
      end
    end
  end
end
