# frozen_string_literal: true

module Sashite
  module Feen
    # Base error class for all FEEN-related errors.
    #
    # Inherits from ArgumentError for compatibility with standard Ruby
    # error handling patterns. All FEEN parsing and validation errors
    # are subclasses of this class.
    #
    # @example Catching all FEEN errors
    #   begin
    #     Sashite::Feen.parse(input)
    #   rescue Sashite::Feen::Error => e
    #     puts "FEEN error: #{e.message}"
    #   end
    #
    # @example Catching as standard ArgumentError
    #   begin
    #     Sashite::Feen.parse(input)
    #   rescue ArgumentError => e
    #     puts "Invalid argument: #{e.message}"
    #   end
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    # @api public
    class Error < ::ArgumentError
      freeze
    end
  end
end
