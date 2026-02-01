# frozen_string_literal: true

module Sashite
  module Feen
    # Implementation limits for bounded parsing.
    #
    # These constraints enable safe parsing with predictable memory usage
    # while remaining sufficient for all realistic board game positions.
    #
    # @example Validating input length
    #   if input.bytesize > Limits::MAX_STRING_LENGTH
    #     raise "input too long"
    #   end
    #
    # @example Validating board dimensions
    #   if dimensions > Limits::MAX_DIMENSIONS
    #     raise "too many dimensions"
    #   end
    #
    # @see https://sashite.dev/specs/feen/1.0.0/
    # @api private
    module Limits
      # Maximum allowed length for a FEEN string in bytes.
      #
      # This limit is sufficient for any realistic board position,
      # including large boards like 19×19 Go with complex piece states.
      #
      # @return [Integer] 4096
      MAX_STRING_LENGTH = 4_096

      # Maximum number of board dimensions supported.
      #
      # Covers 1D (linear), 2D (standard boards), and 3D (cubic) boards.
      # Higher dimensions are theoretically possible but not practically used.
      #
      # @return [Integer] 3
      MAX_DIMENSIONS = 3

      # Maximum size of any single dimension.
      #
      # Fits in an 8-bit unsigned integer, allowing boards up to
      # 255×255×255 squares. This exceeds any known board game.
      #
      # @return [Integer] 255
      MAX_DIMENSION_SIZE = 255

      freeze
    end
  end
end
