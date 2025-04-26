# Feen.rb

[![Version](https://img.shields.io/github/v/tag/sashite/feen.rb?label=Version&logo=github)](https://github.com/sashite/feen.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/feen.rb/main)
![Ruby](https://github.com/sashite/feen.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/feen.rb?label=License&logo=github)](https://github.com/sashite/feen.rb/raw/main/LICENSE.md)

> **FEEN** (Forsyth–Edwards Essential Notation) support for the Ruby language.

## What is FEEN?

FEEN (Forsyth–Edwards Essential Notation) is a compact, canonical, and rule-agnostic textual format for representing static board positions in two-player piece-placement games.

This gem implements the [FEEN Specification v1.0.0](https://sashite.dev/documents/feen/1.0.0/), providing a Ruby interface for:
- Multiple game types (chess, shogi, xiangqi, etc.)
- Hybrid or cross-game positions
- Arbitrary-dimensional boards
- Pieces in hand (as used in Shogi)

## Installation

```ruby
# In your Gemfile
gem "feen", ">= 5.0.0.beta2"
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
# position[:games_turn]      # Details about active player and game
# position[:pieces_in_hand]  # Array of pieces held for dropping
```

### Creating FEEN Strings

Convert position components to a FEEN string using named arguments:

```ruby
require "feen"

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

### Shogi Example

FEEN can represent positions from shogi (Japanese chess) with full support for promoted pieces and pieces in hand:

```
lnsgk3l/5g3/p1ppB2pp/9/8B/2P6/P2PPPPPP/3K3R1/5rSNL SHOGI/shogi N5P2g2snl
```

In this position:
- `SHOGI/shogi` indicates it's Sente's (Black's) turn to move
- `N5P2g2snl` shows the pieces in hand: Sente (Black) has a Knight and 5 Pawns, while Gote (White) has 2 Golds, 2 Silvers, a Knight, and a Lance

#### Notes on Shogi Notation in FEEN

- By convention, Sente's (Black's) pieces are represented in uppercase, while Gote's (White's) pieces are in lowercase
- Unlike in chess, in shogi, Black (Sente) is positioned at the bottom (south) of the board, and in the initial position, Black plays first (similar to White in chess)
- In the `SHOGI/shogi` games-turn field, uppercase `SHOGI` refers to the player using uppercase pieces (Sente/Black)

This demonstrates how FEEN adapts naturally to different game conventions while maintaining consistent notation principles.

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
  active_variant:   "CHESS",
  inactive_variant: "chess",
  pieces_in_hand:   []
)
# => "rnb/qkp//PR1/1KQ CHESS/chess -"
```

### Piece Modifiers

FEEN supports prefixes and suffixes for pieces to convey special states or capabilities:

- **Prefix `+`**: Indicates promotion or special state
  - Example: `+P` represents a promoted pawn in Shogi (e.g., a Dragon Horse)

- **Suffix `=`**: Indicates dual-option status or special capability
  - Example: `K=` represents a king eligible for both kingside and queenside castling
  - Example: `P=` represents a pawn that may be captured en passant from both left and right

- **Suffix `<`**: Indicates left-side constraint or condition
  - Example: `K<` represents a king eligible for queenside castling only
  - Example: `P<` represents a pawn that may be captured en passant from the left

- **Suffix `>`**: Indicates right-side constraint or condition
  - Example: `K>` represents a king eligible for kingside castling only
  - Example: `P>` represents a pawn that may be captured en passant from the right

These modifiers allow FEEN to encode rule-specific information like castling rights and en passant possibilities while maintaining its rule-agnostic design. When a piece is captured and becomes a "piece in hand" (available for dropping), its modifiers are typically removed.

### Sanitizing FEN Strings

FEEN includes utilities to clean FEN strings by validating and removing invalid castling rights and en passant targets:

```ruby
require "feen"

# FEN with invalid castling rights
fen_string = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQ1BNR w KQkq - 0 1"
cleaned_fen = Feen::Sanitizer.clean_fen(fen_string)
# => "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQ1BNR w kq - 0 1"
```

## Documentation

- [Official FEEN Specification v1.0.0](https://sashite.dev/documents/feen/1.0.0/)
- [API Documentation](https://rubydoc.info/github/sashite/feen.rb/main)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This [gem](https://rubygems.org/gems/feen) is maintained by [Sashité](https://sashite.com/).

With some [lines of code](https://github.com/sashite/), let's share the beauty of Chinese, Japanese and Western cultures through the game of chess!
