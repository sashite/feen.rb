# Feen.rb

[![Version](https://img.shields.io/github/v/tag/sashite/feen.rb?label=Version&logo=github)](https://github.com/sashite/feen.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/feen.rb/main)
![Ruby](https://github.com/sashite/feen.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/feen.rb?label=License&logo=github)](https://github.com/sashite/feen.rb/raw/main/LICENSE.md)

> **FEEN** (Forsyth–Edwards Enhanced Notation) support for the Ruby language.

## What is FEEN?

FEEN (Forsyth–Edwards Enhanced Notation) is a compact, canonical, and rule-agnostic textual format for representing static board positions in two-player piece-placement games.

This gem implements the [FEEN Specification v1.0.0](https://sashite.dev/documents/feen/1.0.0/), providing a Ruby interface for:

- Representing positions from various games without knowledge of specific rules
- Supporting boards of arbitrary dimensions
- Encoding pieces in hand (as used in Shogi)
- Facilitating serialization and deserialization of positions
- Ensuring canonical representation for consistent data handling

## Installation

```ruby
# In your Gemfile
gem "feen", ">= 5.0.0.beta5"
```

Or install manually:

```sh
gem install feen --pre
```

## FEEN Format

A FEEN record consists of three space-separated fields:

```
<PIECE-PLACEMENT> <PIECES-IN-HAND> <GAMES-TURN>
```

## Basic Usage

### Parsing FEEN Strings

Convert a FEEN string into a structured Ruby object:

```ruby
require "feen"

feen_string = "r'nbqkbnr'/pppppppp/8/8/8/8/PPPPPPPP/R'NBQKBNR' - CHESS/chess"
position = Feen.parse(feen_string)

# Result is a hash:
# {
#   piece_placement: [
#     ["r'", "n", "b", "q", "k", "b", "n", "r'"],
#     ["p", "p", "p", "p", "p", "p", "p", "p"],
#     ["", "", "", "", "", "", "", ""],
#     ["", "", "", "", "", "", "", ""],
#     ["", "", "", "", "", "", "", ""],
#     ["", "", "", "", "", "", "", ""],
#     ["P", "P", "P", "P", "P", "P", "P", "P"],
#     ["R'", "N", "B", "Q", "K", "B", "N", "R'"]
#   ],
#   pieces_in_hand: [],
#   games_turn: ["CHESS", "chess"]
# }
```

### Safe Parsing

Parse a FEEN string without raising exceptions:

```ruby
require "feen"

# Valid FEEN string
result = Feen.safe_parse("r'nbqkbnr'/pppppppp/8/8/8/8/PPPPPPPP/R'NBQKBNR' - CHESS/chess")
# => {piece_placement: [...], pieces_in_hand: [...], games_turn: [...]}

# Invalid FEEN string
result = Feen.safe_parse("invalid feen string")
# => nil
```

### Creating FEEN Strings

Convert position components to a FEEN string using named arguments:

```ruby
require "feen"

# Representation of a chess board in initial position
piece_placement = [
  ["r'", "n", "b", "q", "k", "b", "n", "r'"],
  ["p", "p", "p", "p", "p", "p", "p", "p"],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["P", "P", "P", "P", "P", "P", "P", "P"],
  ["R'", "N", "B", "Q", "K", "B", "N", "R'"]
]

result = Feen.dump(
  piece_placement: piece_placement,
  games_turn:      %w[CHESS chess],
  pieces_in_hand:  []
)
# => "r'nbqkbnr'/pppppppp/8/8/8/8/PPPPPPPP/R'NBQKBNR' - CHESS/chess"
```

### Validation

Check if a string is valid FEEN notation and in canonical form:

```ruby
require "feen"

# Canonical form
Feen.valid?("lnsgk3l/5g3/p1ppB2pp/9/8B/2P6/P2PPPPPP/3K3R1/5rSNL N5P2gln2s SHOGI/shogi")
# => true

# Invalid syntax
Feen.valid?("invalid feen string")
# => false

# Valid syntax but non-canonical form (pieces in hand not in lexicographic order)
Feen.valid?("lnsgk3l/5g3/p1ppB2pp/9/8B/2P6/P2PPPPPP/3K3R1/5rSNL N5P2gn2sl SHOGI/shogi")
# => false
```

The `valid?` method performs two levels of validation:

1. **Syntax check**: Verifies the string can be parsed as FEEN
2. **Canonicity check**: Ensures the string is in its canonical form through round-trip conversion

## Game Examples

As FEEN is rule-agnostic, it can represent positions from various board games. Here are some examples:

### International Chess

```ruby
feen_string = "r'nbqkbnr'/pppppppp/8/8/8/8/PPPPPPPP/R'NBQKBNR' - CHESS/chess"
```

In this initial chess position:

- The `'` suffixes on rooks indicate an intermediate state (which might represent castling rights in chess, though FEEN doesn't define this semantics)
- The third field `CHESS/chess` indicates it's the player with uppercase pieces' turn to move

### Shogi (Japanese Chess)

```ruby
feen_string = "lnsgk3l/5g3/p1ppB2pp/9/8B/2P6/P2PPPPPP/3K3R1/5rSNL N5P2gln2s SHOGI/shogi"
```

In this shogi position:

- The format supports promotions with the `+` prefix (e.g., `+P` for a promoted pawn)
- The notation allows for pieces in hand, indicated in the second field
- `SHOGI/shogi` indicates it's Sente's (Black's, uppercase) turn to move
- `N5P2gln2s` shows the pieces in hand: Sente has a Knight (N) and 5 Pawns (5P), while Gote has 2 Golds (2g), a Lance (l), a Knight (n), and 2 Silvers (2s), all properly sorted in ASCII lexicographic order

### Makruk (Thai Chess)

```ruby
feen_string = "rnbqkbnr/8/pppppppp/8/8/PPPPPPPP/8/RNBQKBNR - MAKRUK/makruk"
```

This initial Makruk position is easily represented in FEEN without needing to know the specific rules of the game.

### Xiangqi (Chinese Chess)

```ruby
feen_string = "rheagaehr/9/1c5c1/s1s1s1s1s/9/9/S1S1S1S1S/1C5C1/9/RHEAGAEHR - XIANGQI/xiangqi"
```

In this Xiangqi position:

- The representation uses single letters for the different pieces
- The format naturally adapts to the presence of a "river" (empty space in the middle)

## Advanced Features

### Multi-dimensional Boards

FEEN supports arbitrary-dimensional board configurations:

```ruby
require "feen"

# 3D board
piece_placement = [
  [
    %w[r n b],
    %w[q k p]
  ],
  [
    ["P", "R", ""],
    ["", "K", "Q"]
  ]
]

result = Feen.dump(
  piece_placement: piece_placement,
  games_turn:      %w[FOO bar],
  pieces_in_hand:  []
)
# => "rnb/qkp//PR1/1KQ - FOO/bar"
```

### Piece Modifiers

FEEN supports prefixes and suffixes for pieces to denote various states or capabilities:

- **Prefix `+`**: Enhanced state
  - Example in shogi: `+P` may represent a promoted pawn

- **Prefix `-`**: Diminished state
  - Could represent a piece with limited movement or other restrictions

- **Suffix `'`**: Intermediate state
  - Example in chess: `R'` may represent a rook that has intermediate status (such as castling eligibility)
  - Example in chess: `P'` may represent a pawn that may be captured _en passant_

These modifiers have no defined semantics in the FEEN specification itself but provide a flexible framework for representing piece-specific conditions while maintaining FEEN's rule-agnostic nature.

## Documentation

- [Official FEEN Specification](https://sashite.dev/documents/feen/1.0.0/)
- [API Documentation](https://rubydoc.info/github/sashite/feen.rb/main)

## License

The [gem](https://rubygems.org/gems/feen) is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This project is maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of Chinese, Japanese, and Western chess cultures.
