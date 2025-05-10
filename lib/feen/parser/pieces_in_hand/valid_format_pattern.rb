# frozen_string_literal: true

module Feen
  module Parser
    module PiecesInHand
      # Valid pattern for pieces in hand based on BNF:
      # <pieces-in-hand> ::= "-" | <pieces-sequence>
      #
      # Rules for numeric prefixes:
      # - Cannot start with "0"
      # - Cannot be exactly "1" (use the letter without prefix instead)
      # - Can be 2-9 or any number with 2+ digits (10, 11, etc.)
      #
      # The pattern (?:[2-9]|\d{2,}) matches:
      # - A single digit from 2-9
      # - OR any number with 2 or more digits (10, 11, 27, 103, etc.)
      ValidFormatPattern = /\A
        (?:
          -|                                              # No pieces in hand
          (?:                                             # Or sequence of pieces
            (?:(?:[2-9]|\d{2,})?[A-Z])*                   # Uppercase pieces (optional)
            (?:(?:[2-9]|\d{2,})?[a-z])*                   # Lowercase pieces (optional)
          )
        )
      \z/x
    end
  end
end
