# feen.rb

[![Version](https://img.shields.io/github/v/tag/sashite/feen.rb?label=Version&logo=github)](https://github.com/sashite/feen.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/feen.rb/main)
[![CI](https://github.com/sashite/feen.rb/actions/workflows/ruby.yml/badge.svg?branch=main)](https://github.com/sashite/feen.rb/actions)
[![License](https://img.shields.io/github/license/sashite/feen.rb?label=License&logo=github)](https://github.com/sashite/feen.rb/raw/main/LICENSE)

> **FEEN** (Field Expression Encoding Notation) implementation for Ruby.

## Overview

This library implements the [FEEN Specification v1.0.0](https://sashite.dev/specs/feen/1.0.0/).

### Implementation Constraints

| Constraint | Value | Rationale |
|------------|-------|-----------|
| Max string length | 4096 | Sufficient for realistic board positions |
| Max board dimensions | 3 | Sufficient for 1D, 2D, 3D boards |
| Max dimension size | 255 | Fits in 8-bit integer; covers 256×256×256 boards |

These constraints enable bounded memory usage and safe parsing.

## Installation

```ruby
# In your Gemfile
gem "sashite-feen"
```

Or install manually:

```sh
gem install sashite-feen
```

## Dependencies

```ruby
gem "sashite-epin"  # Extended Piece Identifier Notation
gem "sashite-sin"   # Style Identifier Notation
```

## Usage

### Parsing (String → Position)

Convert a FEEN string into a `Position` object.

```ruby
require "sashite/feen"

# Standard parsing (raises on error)
position = Sashite::Feen.parse("lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s")

# Access components
position.piece_placement  # => PiecePlacement
position.hands            # => Hands
position.style_turn       # => StyleTurn

# Invalid input raises ParseError
Sashite::Feen.parse("invalid")  # => raises Sashite::Feen::ParseError
```

### Formatting (Position → String)

Convert a `Position` back to a canonical FEEN string.

```ruby
# Round-trip serialization
position = Sashite::Feen.parse("8/8/8/8/8/8/8/8 / C/c")
position.to_s  # => "8/8/8/8/8/8/8/8 / C/c"
```

### Validation

```ruby
# Boolean check (never raises)
Sashite::Feen.valid?("lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s")  # => true
Sashite::Feen.valid?("8/8/8/8/8/8/8/8 / C/c")  # => true (empty board)
Sashite::Feen.valid?("k^+p4+PK^ / C/c")        # => true (1D board)
Sashite::Feen.valid?("a/b//c/d / G/g")         # => true (3D board)
Sashite::Feen.valid?("rkr//PPPP / G/g")        # => false (dimensional coherence)
Sashite::Feen.valid?("invalid")                # => false
Sashite::Feen.valid?(nil)                      # => false
```

### Dumping (Structured Data → String)

Serialize structured position data directly to a FEEN string.

```ruby
# Dump an empty Chess board
Sashite::Feen.dump(
  piece_placement: {
    segments: [[8], [8], [8], [8], [8], [8], [8], [8]],
    separators: ["/", "/", "/", "/", "/", "/", "/"]
  },
  hands: { first: [], second: [] },
  style_turn: { active: "C", inactive: "c" }
)
# => "8/8/8/8/8/8/8/8 / C/c"

# Dump a position with pieces and hands
Sashite::Feen.dump(
  piece_placement: {
    segments: [["K", 6, "k"]],
    separators: []
  },
  hands: {
    first: [{ piece: "P", count: 2 }],
    second: [{ piece: "p", count: 1 }]
  },
  style_turn: { active: "S", inactive: "s" }
)
# => "K6k 2P/p S/s"
```

### Accessing Piece Placement

```ruby
position = Sashite::Feen.parse("lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s")

position.piece_placement.squares_count  # => 81
position.piece_placement.pieces_count   # => 40
position.piece_placement.dimensions     # => 2

# Iterate over squares
position.piece_placement.each do |square|
  case square
  when Integer then puts "#{square} empty squares"
  when Sashite::Epin::Identifier then puts "Piece: #{square}"
  end
end
```

### Accessing Hands

```ruby
position = Sashite::Feen.parse("8/8/8/8/8/8/8/8 3P2B/3p2b C/c")

position.hands.first.pieces_count   # => 5
position.hands.second.pieces_count  # => 5
position.hands.first.empty?         # => false

# Iterate over hand items
position.hands.first.each do |piece, count|
  puts "#{count}x #{piece}"
end
```

### Accessing Style–Turn

```ruby
position = Sashite::Feen.parse("8/8/8/8/8/8/8/8 / C/c")

position.style_turn.active_style    # => Sashite::Sin::Identifier (C)
position.style_turn.inactive_style  # => Sashite::Sin::Identifier (c)
position.style_turn.first_to_move?  # => true
position.style_turn.second_to_move? # => false
```

### Aggregate Queries

```ruby
position = Sashite::Feen.parse("lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s")

# Board metrics
position.squares_count  # => 81
position.pieces_count   # => 40 (board + hands)
```

## API Reference

### Module Methods

```ruby
# Parses a FEEN string into a Position.
# Raises ParseError (or subclass) if the string is not valid.
#
# @param feen_string [String] FEEN string
# @return [Position]
# @raise [ParseError] if invalid
def Sashite::Feen.parse(feen_string)

# Reports whether string is a valid FEEN position.
# Never raises; returns false for any invalid input.
#
# @param feen_string [String] FEEN string
# @return [Boolean]
def Sashite::Feen.valid?(feen_string)

# Serializes structured position data to a FEEN string.
# Does not validate input; assumes caller provides valid data.
#
# @param piece_placement [Hash] with :segments and :separators
# @param hands [Hash] with :first and :second (arrays of {piece:, count:})
# @param style_turn [Hash] with :active and :inactive (SIN strings)
# @return [String] Canonical FEEN string
def Sashite::Feen.dump(piece_placement:, hands:, style_turn:)
```

### Position

```ruby
# Position represents a complete FEEN position.
# Instances are immutable and created only via Feen.parse.
class Sashite::Feen::Position
  # Returns the piece placement component.
  # @return [PiecePlacement]
  def piece_placement

  # Returns the hands component.
  # @return [Hands]
  def hands

  # Returns the style-turn component.
  # @return [StyleTurn]
  def style_turn

  # Returns the total number of squares on the board.
  # @return [Integer]
  def squares_count

  # Returns the total number of pieces (board + hands).
  # @return [Integer]
  def pieces_count

  # Returns the canonical FEEN string.
  # @return [String]
  def to_s
end
```

### PiecePlacement

```ruby
# PiecePlacement represents board structure and occupancy.
class Sashite::Feen::Position::PiecePlacement
  include Enumerable

  # Returns the total number of squares.
  # @return [Integer]
  def squares_count

  # Returns the number of pieces on the board.
  # @return [Integer]
  def pieces_count

  # Returns the board dimensionality (1, 2, or 3).
  # @return [Integer]
  def dimensions

  # Iterates over each square (empty counts or pieces).
  # @yieldparam square [Integer, Sashite::Epin::Identifier]
  # @return [Enumerator] if no block given
  def each

  # Returns the canonical string representation.
  # @return [String]
  def to_s
end
```

### Hands

```ruby
# Hands represents off-board pieces for both players.
class Sashite::Feen::Position::Hands
  # Returns the first player's hand.
  # @return [Hand]
  def first

  # Returns the second player's hand.
  # @return [Hand]
  def second

  # Returns the total pieces in both hands.
  # @return [Integer]
  def pieces_count

  # Returns the canonical string representation.
  # @return [String]
  def to_s
end
```

### Hand

```ruby
# Hand represents a single player's off-board pieces.
# This is an internal class; instances are accessed via Hands#first and Hands#second.
class Sashite::Feen::Position::Hands::Hand
  include Enumerable

  # Returns true if the hand contains no pieces.
  # @return [Boolean]
  def empty?

  # Returns the number of distinct piece types.
  # @return [Integer]
  def size

  # Returns the total number of pieces.
  # @return [Integer]
  def pieces_count

  # Iterates over each piece type and its count.
  # @yieldparam piece [Sashite::Epin::Identifier]
  # @yieldparam count [Integer]
  # @return [Enumerator] if no block given
  def each

  # Returns the canonical string representation.
  # @return [String]
  def to_s
end
```

### StyleTurn

```ruby
# StyleTurn represents player styles and the active player.
class Sashite::Feen::Position::StyleTurn
  # Returns the active player's style.
  # @return [Sashite::Sin::Identifier]
  def active_style

  # Returns the inactive player's style.
  # @return [Sashite::Sin::Identifier]
  def inactive_style

  # Returns true if first player is to move.
  # @return [Boolean]
  def first_to_move?

  # Returns true if second player is to move.
  # @return [Boolean]
  def second_to_move?

  # Returns the canonical string representation.
  # @return [String]
  def to_s
end
```

### Constants

```ruby
Sashite::Feen::Limits::MAX_STRING_LENGTH  # => 4096
Sashite::Feen::Limits::MAX_DIMENSIONS     # => 3
Sashite::Feen::Limits::MAX_DIMENSION_SIZE # => 255
```

### Error Hierarchy

All errors inherit from `Sashite::Feen::Error`, which inherits from `ArgumentError`:

```
ArgumentError
└── Sashite::Feen::Error
    └── Sashite::Feen::ParseError
        ├── Sashite::Feen::PiecePlacementError
        ├── Sashite::Feen::HandsError
        ├── Sashite::Feen::StyleTurnError
        └── Sashite::Feen::CardinalityError
```

You can rescue at any level:

```ruby
# Catch all FEEN errors
begin
  Sashite::Feen.parse(input)
rescue Sashite::Feen::Error => e
  puts "FEEN error: #{e.message}"
end

# Catch specific field errors
begin
  Sashite::Feen.parse(input)
rescue Sashite::Feen::PiecePlacementError => e
  puts "Board error: #{e.message}"
rescue Sashite::Feen::HandsError => e
  puts "Hands error: #{e.message}"
end

# Or catch as standard ArgumentError
begin
  Sashite::Feen.parse(input)
rescue ArgumentError => e
  puts "Invalid argument: #{e.message}"
end
```

### Error Messages

| Error Class | Message | Cause |
|-------------|---------|-------|
| `ParseError` | `"input exceeds 4096 characters"` | String too long |
| `ParseError` | `"invalid field count"` | Not exactly 3 space-separated fields |
| `PiecePlacementError` | `"piece placement is empty"` | Field 1 is empty |
| `PiecePlacementError` | `"piece placement starts with separator"` | Field 1 starts with `/` |
| `PiecePlacementError` | `"piece placement ends with separator"` | Field 1 ends with `/` |
| `PiecePlacementError` | `"invalid empty count"` | Empty count is zero or has leading zeros |
| `PiecePlacementError` | `"invalid piece token"` | Token is not a valid EPIN identifier |
| `PiecePlacementError` | `"dimensional coherence violation"` | Separator depth mismatch |
| `PiecePlacementError` | `"exceeds 3 dimensions"` | Board has more than 3 dimensions |
| `PiecePlacementError` | `"dimension size exceeds 255"` | A rank exceeds 255 squares |
| `HandsError` | `"invalid hands delimiter"` | Field 2 missing `/` or has multiple |
| `HandsError` | `"invalid hand count"` | Multiplicity is 0, 1, or has leading zeros |
| `HandsError` | `"hand items not aggregated"` | Identical EPIN tokens not combined |
| `HandsError` | `"hand items not in canonical order"` | Items violate ordering rules |
| `StyleTurnError` | `"invalid style-turn delimiter"` | Field 3 missing `/` or has multiple |
| `StyleTurnError` | `"invalid style token"` | Token is not a valid SIN identifier |
| `StyleTurnError` | `"style tokens must have opposite case"` | Both tokens same case |
| `CardinalityError` | `"too many pieces for board size"` | Total pieces exceeds total squares |

## Design Principles

- **Spec conformance**: Strict adherence to FEEN v1.0.0
- **Pure composition**: Delegates to EPIN and SIN for token handling
- **Canonical output**: `to_s` always produces canonical form
- **Immutable positions**: Frozen instances prevent mutation
- **Structured errors**: Hierarchical error classes for precise handling
- **Ruby idioms**: `valid?` predicate, `to_s` conversion, Enumerable support
- **Defensive limits**: Bounded memory usage via configurable constraints

## Related Specifications

- [Game Protocol](https://sashite.dev/game-protocol/) — Conceptual foundation
- [FEEN Specification](https://sashite.dev/specs/feen/1.0.0/) — Official specification
- [FEEN Examples](https://sashite.dev/specs/feen/1.0.0/examples/) — Usage examples
- [EPIN Specification](https://sashite.dev/specs/epin/1.0.0/) — Piece token format
- [SIN Specification](https://sashite.dev/specs/sin/1.0.0/) — Style token format

## License

Available as open source under the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).
