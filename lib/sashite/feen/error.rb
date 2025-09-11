# frozen_string_literal: true

module Sashite
  module Feen
    # Namespaced error types for FEEN
    module Error
      # Base FEEN error (immutable, with optional context payload)
      class Base < StandardError
        # @return [Hash, nil] optional contextual information (e.g., { rank: 3, col: 5 })
        attr_reader :context

        # @param message [String, nil]
        # @param context [Hash, nil] optional structured context (will be frozen)
        def initialize(message = nil, context: nil)
          @context = context&.dup&.freeze
          super(message)
          freeze
        end
      end

      # Raised when the FEEN text does not match the required grammar
      class Syntax < Base; end

      # Raised for structural/semantic violations after syntactic parsing
      class Validation < Base; end

      # Raised when an EPIN token/value is invalid in the current context
      class Piece < Base; end

      # Raised when a SIN token/value or the style/turn field is invalid
      class Style < Base; end

      # Raised when a numeric count (e.g., run-length or hand quantity) is invalid
      class Count < Base; end

      # Raised when board/grid dimensions are empty/inconsistent/out of bounds
      class Bounds < Base; end
    end
  end
end
