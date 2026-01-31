# frozen_string_literal: true

require_relative "argument/messages"

module Sashite
  module Feen
    module Errors
      # Error raised when FEEN parsing or validation fails.
      #
      # This error is a subclass of ArgumentError, allowing callers to catch
      # either the specific error or the standard Ruby error type.
      #
      # @example Catching the specific error
      #   begin
      #     Sashite::Feen.parse("invalid")
      #   rescue Sashite::Feen::Errors::Argument => e
      #     puts "FEEN error: #{e.message}"
      #   end
      #
      # @example Catching as ArgumentError
      #   begin
      #     Sashite::Feen.parse("invalid")
      #   rescue ArgumentError => e
      #     puts "Invalid argument: #{e.message}"
      #   end
      #
      # @see Messages
      # @api private
      class Argument < ::ArgumentError
      end
    end
  end
end
