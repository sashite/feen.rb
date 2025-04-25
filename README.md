# Feen.rb

[![Version](https://img.shields.io/github/v/tag/sashite/feen.rb?label=Version&logo=github)](https://github.com/sashite/feen.rb/releases)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/feen.rb/main)
[![CI](https://github.com/sashite/feen.rb/workflows/CI/badge.svg?branch=main)](https://github.com/sashite/feen.rb/actions?query=workflow%3Aci+branch%3Amain)
[![RuboCop](https://github.com/sashite/feen.rb/workflows/RuboCop/badge.svg?branch=main)](https://github.com/sashite/feen.rb/actions?query=workflow%3Arubocop+branch%3Amain)
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

Convert a position structure to a FEEN string:

```ruby
require "feen"

position = {
  piece_placement: [
    [{ id: "r" }, { id: "n" }, { id: "b" }, { id: "q" }, { id: "k", suffix: "=" }, { id: "b" }, { id: "n" }, { id: "r" }],
    [{ id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }],
    [nil, nil, nil, nil, nil, nil, nil, nil],
    [nil, nil, nil, nil, nil, nil, nil, nil],
    [nil, nil, nil, nil, nil, nil, nil, nil],
    [nil, nil, nil, nil, nil, nil, nil, nil],
    [{ id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }],
    [{ id: "R" }, { id: "N" }, { id: "B" }, { id: "Q" }, { id: "K", suffix: "=" }, { id: "B" }, { id: "N" }, { id: "R" }]
  ],
  games_turn:      {
    active_player:   "CHESS",
    inactive_player: "chess"
  },
  pieces_in_hand:  []
}

Feen.dump(position)
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

## Advanced Features

### Multi-dimensional Boards

FEEN supports arbitrary-dimensional board configurations:

```ruby
require "feen"

# 3D board
position = {
  piece_placement: [
    [
      [{ id: "r" }, { id: "n" }, { id: "b" }],
      [{ id: "q" }, { id: "k" }, { id: "p" }]
    ],
    [
      [{ id: "P" }, { id: "R" }, nil],
      [nil, { id: "K" }, { id: "Q" }]
    ]
  ],
  games_turn:      {
    active_player:   "CHESS",
    inactive_player: "chess"
  },
  pieces_in_hand:  []
}

Feen.dump(position)
# => "rnb/qkp//PR1/1KQ CHESS/chess -"
```

### Piece Modifiers

FEEN supports prefixes and suffixes for pieces:

- Prefix `+`: Often used for promotion (e.g., `+P` for promoted pawn in Shogi)
- Suffix `=`: Dual-option status (e.g., `K=` for king eligible for both castling sides)
- Suffix `<`: Left-side constraint (e.g., `K<` for queenside castling only)
- Suffix `>`: Right-side constraint (e.g., `K>` for kingside castling only)

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
