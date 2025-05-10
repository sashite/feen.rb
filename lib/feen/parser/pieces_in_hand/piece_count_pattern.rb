# frozen_string_literal: true

module Feen
  module Parser
    module PiecesInHand
      # Regex to extract piece counts from pieces in hand string
      # Matches either:
      # - A single piece character with no count (e.g., "P")
      # - A count followed by a piece character (e.g., "5P")
      PieceCountPattern = /(?:([2-9]|\d{2,}))?([A-Za-z])/
    end
  end
end
