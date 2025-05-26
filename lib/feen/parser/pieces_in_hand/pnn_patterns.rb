# frozen_string_literal: true

module Feen
  module Parser
    module PiecesInHand
      # Patterns for PNN (Piece Name Notation) validation and parsing
      module PnnPatterns
        # Basic PNN piece pattern following the specification:
        # <piece> ::= <letter> | <prefix> <letter> | <letter> <suffix> | <prefix> <letter> <suffix>
        # <prefix> ::= "+" | "-"
        # <suffix> ::= "'"
        # <letter> ::= [a-zA-Z]
        PNN_PIECE_PATTERN = /\A[-+]?[a-zA-Z]'?\z/

        # Pattern for valid count prefixes according to FEEN specification:
        # - Cannot be "0" or "1" (use piece without prefix instead)
        # - Can be 2-9 or any number with 2+ digits
        VALID_COUNT_PATTERN = /\A(?:[2-9]|\d{2,})\z/

        # Pattern to extract piece with optional count from pieces in hand string
        # Matches: optional count followed by complete PNN piece
        # Groups: (count_str, piece_str)
        # Note: We need to handle the full PNN piece including modifiers
        PIECE_WITH_COUNT_PATTERN = /(?:([2-9]|\d{2,}))?([-+]?[a-zA-Z]'?)/

        # Complete validation pattern for pieces in hand string
        # Based on the FEEN BNF specification with PNN support
        # This pattern allows any sequence of pieces (uppercase/lowercase mixed) in canonical order
        # It should reject invalid formats like "++P"
        VALID_FORMAT_PATTERN = /\A
          (?:
            -|                                                    # No pieces in hand
            (?:
              (?:[2-9]|\d{2,})?                                   # Optional count (2-9 or 10+)
              [-+]?                                               # Optional single prefix (+ or -)
              [a-zA-Z]                                            # Required letter
              '?                                                  # Optional single suffix (')
            )+                                                    # One or more pieces
          )
        \z/x

        # Pattern for extracting all pieces globally (used for comprehensive validation)
        GLOBAL_PIECE_EXTRACTION_PATTERN = /(?:([2-9]|\d{2,}))?([-+]?[a-zA-Z]'?)/
      end
    end
  end
end
