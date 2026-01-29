# frozen_string_literal: true

require_relative "argument/messages"

module Sashite
  module Feen
    module Errors
      # Error raised when FEEN parsing or validation fails.
      #
      # @example
      #   raise Argument, Argument::Messages::EMPTY_INPUT
      class Argument < ::ArgumentError
      end
    end
  end
end
