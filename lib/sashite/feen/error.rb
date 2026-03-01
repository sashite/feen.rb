# frozen_string_literal: true

module Sashite
  module Feen
    # Base error class for all FEEN-related errors.
    #
    # Inherits from ArgumentError for compatibility with standard Ruby
    # error handling patterns.
    #
    # @api public
    class Error < ::ArgumentError
      freeze
    end
  end
end
