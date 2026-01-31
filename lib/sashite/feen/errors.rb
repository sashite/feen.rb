# frozen_string_literal: true

require_relative "errors/argument"

module Sashite
  module Feen
    # Error classes for FEEN parsing and validation.
    #
    # All errors raised by the FEEN library are subclasses of standard
    # Ruby error types, allowing flexible error handling.
    #
    # @example
    #   begin
    #     Sashite::Feen.parse("invalid")
    #   rescue Sashite::Feen::Errors::Argument => e
    #     puts e.message
    #   end
    #
    # @api private
    module Errors
    end
  end
end
