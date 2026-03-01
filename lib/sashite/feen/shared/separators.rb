# frozen_string_literal: true

module Sashite
  module Feen
    # Field and segment separator constants for FEEN parsing and dumping.
    #
    # @api private
    module Separators
      # Separates the three FEEN fields (ASCII space).
      FIELD = " "

      # Separates segments within fields (ASCII forward slash).
      SEGMENT = "/"

      freeze
    end
  end
end
