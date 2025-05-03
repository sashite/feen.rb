# frozen_string_literal: true

module Feen
  module Parser
    module GamesTurn
      # Complete pattern matching the BNF specification with named groups
      # <games-turn> ::= <game-id-uppercase> "/" <game-id-lowercase>
      #                | <game-id-lowercase> "/" <game-id-uppercase>
      ValidGamesTurnPattern = %r{
        \A                    # Start of string
        (?:                   # Non-capturing group for alternatives
          (?<uppercase_first>[A-Z]+)  # Named group: uppercase identifier first
          /                           # Separator
          (?<lowercase_second>[a-z]+) # Named group: lowercase identifier second
          |                           # OR
          (?<lowercase_first>[a-z]+)  # Named group: lowercase identifier first
          /                           # Separator
          (?<uppercase_second>[A-Z]+) # Named group: uppercase identifier second
        )
        \z                    # End of string
      }x
    end
  end
end
