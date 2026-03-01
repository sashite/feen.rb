# frozen_string_literal: true

module Sashite
  module Feen
    # Implementation limits for bounded parsing.
    #
    # These constraints enable safe parsing with predictable memory usage
    # while remaining sufficient for all realistic board game positions.
    #
    # @api private
    module Limits
      # Maximum allowed length for a FEEN string in bytes.
      MAX_STRING_LENGTH = 4_096

      # Maximum number of board dimensions (1D, 2D, 3D).
      MAX_DIMENSIONS = 3

      # Maximum size of any single dimension (fits in 8-bit unsigned).
      MAX_DIMENSION_SIZE = 255

      freeze
    end
  end
end
