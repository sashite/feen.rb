# Feen.rb

[![Version](https://img.shields.io/github/v/tag/sashite/feen.rb?label=Version&logo=github)](https://github.com/sashite/feen.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/feen.rb/main)
![Ruby](https://github.com/sashite/feen.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/feen.rb?label=License&logo=github)](https://github.com/sashite/feen.rb/raw/main/LICENSE.md)

> **FEEN** (Format for Encounter & Entertainment Notation) support for the Ruby language.

## What is FEEN?

FEEN (Format for Encounter & Entertainment Notation) is a compact, canonical, and rule-agnostic textual format for representing static board positions in two-player piece-placement games.

This gem implements the [FEEN Specification v1.0.0](https://sashite.dev/documents/feen/1.0.0/), providing a Ruby interface for:
- Representing positions from various games without knowledge of specific rules
- Supporting boards of arbitrary dimensions
- Encoding pieces in hand (as used in Shogi)
- Facilitating serialization and deserialization of positions

## Installation

```ruby
# In your Gemfile
gem "feen", ">= 5.0.0.beta3"
```

Or install manually:

```sh
gem install feen --pre
```

## FEEN Format

A FEEN record consists of three space-separated fields:

```
<PIECE-PLACEMENT> <GAMES-TURN> <PIECES-IN-HAND>
```

## Basic Usage

### Parsing FEEN Strings

Convert a FEEN string into a structured Ruby object:

```ruby
require "feen"

feen_string = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR CHESS/chess -"
position = Feen.parse(feen_string)

# Result is a hash with structured position data
# position[:piece_placement] # 2D array of board pieces
# position[:active_variant]  # Active player's variant
# position[:inactive_variant] # Inactive player's variant
# position[:pieces_in_hand]  # Array of pieces held for dropping
```

### Creating FEEN Strings

Convert position components to a FEEN string using named arguments:

```ruby
require "feen"

# Representation of a chess board in initial position
piece_placement = [
  [{ id: "r" }, { id: "n" }, { id: "b" }, { id: "q" }, { id: "k", suffix: "=" }, { id: "b" }, { id: "n" }, { id: "r" }],
  [{ id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }],
  [nil, nil, nil, nil, nil, nil, nil, nil],
  [nil, nil, nil, nil, nil, nil, nil, nil],
  [nil, nil, nil, nil, nil, nil, nil, nil],
  [nil, nil, nil, nil, nil, nil, nil, nil],
  [{ id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }],
  [{ id: "R" }, { id: "N" }, { id: "B" }, { id: "Q" }, { id: "K", suffix: "=" }, { id: "B" }, { id: "N" }, { id: "R" }]
]

result = Feen.dump(
  piece_placement:  piece_placement,
  active_variant:   "CHESS",
  inactive_variant: "chess",
  pieces_in_hand:   []
)
# => "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR CHESS/chess -"
```

### Validation

Check if a string is valid FEEN notation:

```ruby
require "feen"

Feen.valid?("rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR CHESS/chess -")
# => true

Feen.valid?("invalid feen string")
# => false
```

## FEN Compatibility

While FEEN is rule-agnostic, the gem provides utilities to convert from/to the FEN format used in chess:

### Converting FEN to FEEN

```ruby
require "feen"

fen_string = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
feen_string = Feen.from_fen(fen_string)
# => "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR CHESS/chess -"
```

### Converting FEEN to FEN

```ruby
require "feen"

feen_string = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR CHESS/chess -"
fen_string = Feen.to_fen(feen_string)
# => "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
```

> ⚠️ `Feen.to_fen` only supports FEEN positions where `games_turn` is `CHESS/chess` or `chess/CHESS`.

## Game Examples

As FEEN is rule-agnostic, it can represent positions from various board games. Here are some examples:

### International Chess

```ruby
feen_string = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR CHESS/chess -"
```

In this initial chess position:
- The `=` suffixes on kings indicate castling rights on both sides (though FEEN doesn't define this semantics)
- The first field `CHESS/chess` indicates it's the player with uppercase pieces' turn to move

### Shogi (Japanese Chess)

```ruby
feen_string = "lnsgk3l/5g3/p1ppB2pp/9/8B/2P6/P2PPPPPP/3K3R1/5rSNL SHOGI/shogi N5P2g2snl"
```

In this shogi position:
- The format supports promotions with the `+` prefix (e.g., `+P` for a promoted pawn)
- The notation allows for pieces in hand, indicated in the third field
- `SHOGI/shogi` indicates it's Sente's (Black's, uppercase) turn to move
- `N5P2g2snl` shows the pieces in hand: Sente has a Knight (N) and 5 Pawns (P), while Gote has 2 Golds (g), 2 Silvers (s), a Knight (n), and a Lance (l)

### Makruk (Thai Chess)

```ruby
feen_string = "rnbqkbnr/8/pppppppp/8/8/PPPPPPPP/8/RNBQKBNR MAKRUK/makruk -"
```

This initial Makruk position is easily represented in FEEN without needing to know the specific rules of the game.

### Xiangqi (Chinese Chess)

```ruby
feen_string = "rheagaehr/9/1c5c1/s1s1s1s1s/9/9/S1S1S1S1S/1C5C1/9/RHEAGAEHR XIANGQI/xiangqi -"
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
    [{ id: "r" }, { id: "n" }, { id: "b" }],
    [{ id: "q" }, { id: "k" }, { id: "p" }]
  ],
  [
    [{ id: "P" }, { id: "R" }, nil],
    [nil, { id: "K" }, { id: "Q" }]
  ]
]

result = Feen.dump(
  piece_placement:  piece_placement,
  active_variant:   "FOO",
  inactive_variant: "bar",
  pieces_in_hand:   []
)
# => "rnb/qkp//PR1/1KQ FOO/bar -"
```

### Piece Modifiers

FEEN supports prefixes and suffixes for pieces to denote various states or capabilities:

- **Prefix `+`**: May indicate promotion or special state
  - Example in shogi: `+P` may represent a promoted pawn

- **Suffix `=`**: May indicate dual-option status
  - Example in chess: `K=` may represent a king eligible for both kingside and queenside castling

- **Suffix `<`**: May indicate left-side constraint
  - Example in chess: `K<` may represent a king eligible for queenside castling only
  - Example in chess: `P<` may represent a pawn that may be captured _en passant_ from the left

- **Suffix `>`**: May indicate right-side constraint
  - Example in chess: `K>` may represent a king eligible for kingside castling only
  - Example in chess: `P>` may represent a pawn that may be captured en passant from the right

These modifiers have no defined semantics in the FEEN specification itself but provide a flexible framework for representing piece-specific conditions while maintaining FEEN's rule-agnostic nature.

### Sanitizing FEN Strings

The gem includes utilities to clean FEN strings by validating and removing invalid castling rights and en passant targets:

```ruby
require "feen"

# FEN with invalid castling rights
fen_string = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQ1BNR w KQkq - 0 1"
cleaned_fen = Feen::Sanitizer.clean_fen(fen_string)
# => "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQ1BNR w kq - 0 1"
```

## Documentation

- [Official FEEN Specification](https://sashite.dev/documents/feen/1.0.0/)
- [API Documentation](https://rubydoc.info/github/sashite/feen.rb/main)

## License

The [gem](https://rubygems.org/gems/feen) is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This project is maintained by [Sashité](https://sashite.com/) - a project dedicated to promoting chess variants and sharing the beauty of Chinese, Japanese, and Western chess cultures.
