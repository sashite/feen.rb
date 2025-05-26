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
- Supporting boards of arbitrary dimensions (2D, 3D, and beyond)
- Encoding pieces in hand with full PNN (Piece Name Notation) support
- Facilitating serialization and deserialization of positions
- Ensuring canonical representation for consistent data handling

## FEEN Format

A FEEN record consists of three space-separated fields:

```
<PIECE-PLACEMENT> <PIECES-IN-HAND> <GAMES-TURN>
```

### Field Details

1. **Piece Placement**: Spatial distribution of pieces on the board using [PNN notation](https://sashite.dev/documents/pnn/1.0.0/)
2. **Pieces in Hand**: Off-board pieces available for placement, sorted canonically
3. **Games Turn**: Game identifiers and active player indication

## Installation

```ruby
# In your Gemfile
gem "feen", ">= 5.0.0.beta6"
```

Or install manually:

```sh
gem install feen --pre
```

## Basic Usage

### Parsing FEEN Strings

Convert a FEEN string into a structured Ruby object:

```ruby
require "feen"

feen_string = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess"
position = Feen.parse(feen_string)

# Result is a hash:
# {
#   piece_placement: [
#     ["r", "n", "b", "q", "k", "b", "n", "r"],
#     ["p", "p", "p", "p", "p", "p", "p", "p"],
#     ["", "", "", "", "", "", "", ""],
#     ["", "", "", "", "", "", "", ""],
#     ["", "", "", "", "", "", "", ""],
#     ["", "", "", "", "", "", "", ""],
#     ["P", "P", "P", "P", "P", "P", "P", "P"],
#     ["R", "N", "B", "Q", "K", "B", "N", "R"]
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
result = Feen.safe_parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess")
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
  ["r", "n", "b", "q", "k", "b", "n", "r"],
  ["p", "p", "p", "p", "p", "p", "p", "p"],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["P", "P", "P", "P", "P", "P", "P", "P"],
  ["R", "N", "B", "Q", "K", "B", "N", "R"]
]

result = Feen.dump(
  piece_placement: piece_placement,
  games_turn:      %w[CHESS chess],
  pieces_in_hand:  []
)
# => "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess"
```

### Validation

Check if a string is valid FEEN notation and in canonical form:

```ruby
require "feen"

# Canonical form
Feen.valid?("lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL - SHOGI/shogi")
# => true

# Invalid syntax
Feen.valid?("invalid feen string")
# => false

# Valid syntax but non-canonical form (pieces in hand not in canonical order)
Feen.valid?("8/8/8/8/8/8/8/8 P3K CHESS/chess")
# => false (wrong quantity sorting)
```

The `valid?` method performs two levels of validation:

1. **Syntax check**: Verifies the string can be parsed as FEEN
2. **Canonicity check**: Ensures the string is in its canonical form through round-trip conversion

## Game Examples

As FEEN is rule-agnostic, it can represent positions from various board games. Here are some examples:

### International Chess

```ruby
feen_string = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess"
```

In this initial chess position, the third field `CHESS/chess` indicates it's the player with uppercase pieces' turn to move.

### Shogi (Japanese Chess)

```ruby
feen_string = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL - SHOGI/shogi"
```

**With pieces in hand and promotions:**

```ruby
feen_string = "lnsgk3l/5g3/p1ppB2pp/9/8B/2P6/P2PPPPPP/3K3R1/5rSNL 5P2g2sln SHOGI/shogi"
```

In this shogi position:
- The format supports promotions with the `+` prefix (e.g., `+P` for a promoted pawn)
- `5P2g2sln` shows pieces in hand in canonical FEEN order:
  - **Quantity descending**: 5 Pawns (5P), then 2 Golds (2g)
  - **Alphabetically**: then Lance (l), Knight (n), Silver (s)
- `SHOGI/shogi` indicates it's Sente's (Black's, uppercase) turn to move

### Makruk (Thai Chess)

```ruby
feen_string = "rnbqkbnr/8/pppppppp/8/8/PPPPPPPP/8/RNBKQBNR - MAKRUK/makruk"
```

### Xiangqi (Chinese Chess)

```ruby
feen_string = "rheagaehr/9/1c5c1/s1s1s1s1s/9/9/S1S1S1S1S/1C5C1/9/RHEAGAEHR - XIANGQI/xiangqi"
```

## Advanced Features

### Piece Name Notation (PNN) Support

FEEN supports the complete [PNN specification](https://sashite.dev/documents/pnn/1.0.0/) for representing pieces with state modifiers:

#### PNN Modifiers

- **Prefix `+`**: Enhanced state (e.g., promoted pieces in shogi)
- **Prefix `-`**: Diminished state (e.g., restricted movement)
- **Suffix `'`**: Intermediate state (e.g., castling rights, en passant eligibility)

#### Examples with PNN

```ruby
# Shogi position with promoted pieces on board
piece_placement = [
  ["", "", "", "", "+P", "", "", "", ""] # Promoted pawn on board
  # ... other ranks
]

# Pieces in hand with PNN modifiers
pieces_in_hand = ["+P", "+P", "+P", "B'", "B'", "-p", "P"]

result = Feen.dump(
  piece_placement: piece_placement,
  pieces_in_hand:  pieces_in_hand,
  games_turn:      %w[SHOGI shogi]
)
# => "8/8/8/8/4+P4/8/8/8/8 3+P2B'-pP SHOGI/shogi"
```

### Canonical Pieces in Hand Sorting

FEEN enforces canonical ordering of pieces in hand according to the specification:

1. **By quantity (descending)**
2. **By complete PNN representation (alphabetically ascending)**

```ruby
# Input pieces in any order
pieces = ["P", "B", "P", "+P", "B", "P", "+P", "+P"]

result = Feen::Dumper::PiecesInHand.dump(*pieces)
# => "3+P3P2B"
# Breakdown: 3×+P (most frequent), 3×P, 2×B (alphabetical within same quantity)
```

#### Complex Example from FEEN Specification

```ruby
# From FEEN spec v1.0.0 example
pieces = (["P"] * 10) + (["K"] * 5) + (["B"] * 3) + (["p'"] * 2) + ["+P", "-p", "R", "b", "q"]

result = Feen::Dumper::PiecesInHand.dump(*pieces)
# => "10P5K3B2p'+P-pRbq"
# Sorted by: quantity desc (10,5,3,2,1...), then alphabetical (+P,-p,R,b,q)
```

### Multi-dimensional Boards

FEEN supports arbitrary-dimensional board configurations:

```ruby
require "feen"

# 3D board (2×2×3 configuration)
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

### Hybrid Games

FEEN supports hybrid games mixing different piece sets:

```ruby
# Chess-Shogi hybrid position
feen_string = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR 3+P2B'-pP CHESS/shogi"
```

This represents a position where:
- The board uses chess-style pieces
- Pieces in hand use shogi-style promotion (`+P`) and intermediate states (`B'`, `-p`)
- Chess player to move, against shogi player

## Round-trip Consistency

FEEN.rb guarantees round-trip consistency - parsing and dumping produces identical canonical strings:

```ruby
original = "lnsgk3l/5g3/p1ppB2pp/9/8B/2P6/P2PPPPPP/3K3R1/5rSNL 5P2g2sln SHOGI/shogi"
parsed = Feen.parse(original)
dumped = Feen.dump(**parsed)

original == dumped # => true (guaranteed canonical form)
```

## Error Handling

### Validation Errors

```ruby
# Invalid PNN format
Feen::Dumper::PiecesInHand.dump("++P")
# => ArgumentError: Invalid PNN format: '++P'

# Invalid games turn
Feen.dump(
  piece_placement: [["P"]],
  pieces_in_hand:  [],
  games_turn:      %w[BOTH_UPPERCASE ALSO_UPPERCASE] # Both same case
)
# => ArgumentError: One variant must be uppercase and the other lowercase
```

### Safe Operations

```ruby
# Use safe_parse for user input
user_input = gets.chomp
position = Feen.safe_parse(user_input)

if position
  puts "Valid FEEN position!"
else
  puts "Invalid FEEN format"
end
```

## Performance Considerations

- **Parsing**: Optimized recursive descent parser with O(n) complexity
- **Validation**: Round-trip validation ensures canonical form
- **Memory**: Efficient array-based representation for large boards
- **Sorting**: In-place canonical sorting for pieces in hand

## Compatibility

- **Ruby version**: >= 3.2.0
- **FEEN specification**: v1.0.0 compliant
- **PNN specification**: v1.0.0 compliant
- **Thread safety**: All operations are thread-safe (no shared mutable state)

## Related Specifications

FEEN is part of a family of specifications for abstract strategy games:

- [FEEN Specification v1.0.0](https://sashite.dev/documents/feen/1.0.0/) - Board position notation
- [PNN Specification v1.0.0](https://sashite.dev/documents/pnn/1.0.0/) - Piece name notation
- [GAN Specification v1.0.0](https://sashite.dev/documents/gan/1.0.0/) - Game-qualified piece identifiers

## License

The [gem](https://rubygems.org/gems/feen) is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This project is maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of Chinese, Japanese, and Western chess cultures.
