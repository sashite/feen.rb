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

        # Pattern for uppercase pieces only (used for uppercase section validation)
        UPPERCASE_PIECE_PATTERN = /[-+]?[A-Z]'?/

        # Pattern for lowercase pieces only (used for lowercase section validation)
        LOWERCASE_PIECE_PATTERN = /[-+]?[a-z]'?/

        # Pattern for uppercase section: sequence of uppercase pieces with optional counts
        # Format: [count]piece[count]piece... where pieces are uppercase
        UPPERCASE_SECTION_PATTERN = /\A
          (?:
            (?:[2-9]|\d{2,})?                                 # Optional count (2-9 or 10+)
            [-+]?                                             # Optional single prefix (+ or -)
            [A-Z]                                             # Required uppercase letter
            '?                                                # Optional single suffix (')
          )+                                                  # One or more uppercase pieces
        \z/x

        # Pattern for lowercase section: sequence of lowercase pieces with optional counts
        # Format: [count]piece[count]piece... where pieces are lowercase
        LOWERCASE_SECTION_PATTERN = /\A
          (?:
            (?:[2-9]|\d{2,})?                                 # Optional count (2-9 or 10+)
            [-+]?                                             # Optional single prefix (+ or -)
            [a-z]                                             # Required lowercase letter
            '?                                                # Optional single suffix (')
          )+                                                  # One or more lowercase pieces
        \z/x

        # Complete validation pattern for pieces in hand string with case separation
        # Based on the FEEN BNF specification with PNN support
        # Format: "UPPERCASE_PIECES/LOWERCASE_PIECES"
        # Either section can be empty, but the "/" separator is mandatory
        VALID_FORMAT_PATTERN = %r{\A
          (?:
            (?:                                               # Uppercase section (optional)
              (?:[2-9]|\d{2,})?                               # Optional count (2-9 or 10+)
              [-+]?                                           # Optional single prefix (+ or -)
              [A-Z]                                           # Required uppercase letter
              '?                                              # Optional single suffix (')
            )*                                                # Zero or more uppercase pieces
          )
          /                                                  # Mandatory separator
          (?:
            (?:                                               # Lowercase section (optional)
              (?:[2-9]|\d{2,})?                               # Optional count (2-9 or 10+)
              [-+]?                                           # Optional single prefix (+ or -)
              [a-z]                                           # Required lowercase letter
              '?                                              # Optional single suffix (')
            )*                                                # Zero or more lowercase pieces
          )
        \z}x

        # Pattern for extracting all pieces globally (used for comprehensive validation)
        GLOBAL_PIECE_EXTRACTION_PATTERN = /(?:([2-9]|\d{2,}))?([-+]?[a-zA-Z]'?)/

        # Pattern specifically for uppercase pieces with counts (for section parsing)
        UPPERCASE_PIECE_WITH_COUNT_PATTERN = /(?:([2-9]|\d{2,}))?([-+]?[A-Z]'?)/

        # Pattern specifically for lowercase pieces with counts (for section parsing)
        LOWERCASE_PIECE_WITH_COUNT_PATTERN = /(?:([2-9]|\d{2,}))?([-+]?[a-z]'?)/
      end
    end
  end
end
