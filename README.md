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

# Invalid input raises ArgumentError
Sashite::Feen.parse("invalid")  # => raises ArgumentError
```

### Formatting (Position → String)

Convert a `Position` back to a canonical FEEN string.

```ruby
# Round-trip serialization
position = Sashite::Feen.parse("8/8/8/8/8/8/8/8 / C/c")
position.to_s  # => "8/8/8/8/8/8/8/8 / C/c"

# Build from components
position = Sashite::Feen::Position.new(piece_placement, hands, style_turn)
position.to_s  # => canonical FEEN string
```

### Validation

```ruby
# Boolean check
Sashite::Feen.valid?("lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s")  # => true
Sashite::Feen.valid?("8/8/8/8/8/8/8/8 / C/c")  # => true (empty board)
Sashite::Feen.valid?("k^+p4+PK^ / C/c")        # => true (1D board)
Sashite::Feen.valid?("a/b//c/d / G/g")         # => true (3D board)
Sashite::Feen.valid?("rkr//PPPP / G/g")        # => false (dimensional coherence)
Sashite::Feen.valid?("invalid")                # => false
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

### Queries

```ruby
position = Sashite::Feen.parse("lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s")

# Board metrics
position.squares_count  # => 81
position.pieces_count   # => 40
```

## API Reference

### Types

```ruby
# Position represents a complete FEEN position.
class Sashite::Feen::Position
  # Creates a Position from its three components.
  # Raises ArgumentError if components are invalid.
  #
  # @param piece_placement [PiecePlacement] Board structure and occupancy
  # @param hands [Hands] Off-board pieces
  # @param style_turn [StyleTurn] Player styles and active player
  # @return [Position]
  def initialize(piece_placement, hands, style_turn)

  # Returns the piece placement component.
  #
  # @return [PiecePlacement]
  def piece_placement

  # Returns the hands component.
  #
  # @return [Hands]
  def hands

  # Returns the style-turn component.
  #
  # @return [StyleTurn]
  def style_turn

  # Returns the total number of squares on the board.
  #
  # @return [Integer]
  def squares_count

  # Returns the total number of pieces (board + hands).
  #
  # @return [Integer]
  def pieces_count

  # Returns the canonical FEEN string.
  #
  # @return [String]
  def to_s
end
```

```ruby
# PiecePlacement represents board structure and occupancy.
class Sashite::Feen::Position::PiecePlacement
  # Returns the total number of squares.
  #
  # @return [Integer]
  def squares_count

  # Returns the number of pieces on the board.
  #
  # @return [Integer]
  def pieces_count

  # Returns the board dimensionality.
  #
  # @return [Integer] 1 for 1D, 2 for 2D, etc.
  def dimensions

  # Iterates over each square (empty counts or pieces).
  #
  # @yieldparam square [Integer, Sashite::Epin::Identifier]
  # @return [Enumerator] if no block given
  def each

  # Returns the canonical string representation.
  #
  # @return [String]
  def to_s
end
```

```ruby
# Hands represents off-board pieces for both players.
class Sashite::Feen::Position::Hands
  # Returns the first player's hand.
  #
  # @return [Hand]
  def first

  # Returns the second player's hand.
  #
  # @return [Hand]
  def second

  # Returns the total pieces in both hands.
  #
  # @return [Integer]
  def pieces_count

  # Returns the canonical string representation.
  #
  # @return [String]
  def to_s
end
```

```ruby
# Hand represents a single player's off-board pieces.
class Sashite::Feen::Position::Hand
  # Returns true if the hand contains no pieces.
  #
  # @return [Boolean]
  def empty?

  # Returns the number of distinct piece types.
  #
  # @return [Integer]
  def size

  # Returns the total number of pieces.
  #
  # @return [Integer]
  def pieces_count

  # Iterates over each piece type and its count.
  #
  # @yieldparam piece [Sashite::Epin::Identifier]
  # @yieldparam count [Integer]
  # @return [Enumerator] if no block given
  def each

  # Returns the canonical string representation.
  #
  # @return [String]
  def to_s
end
```

```ruby
# StyleTurn represents player styles and the active player.
class Sashite::Feen::Position::StyleTurn
  # Returns the active player's style.
  #
  # @return [Sashite::Sin::Identifier]
  def active_style

  # Returns the inactive player's style.
  #
  # @return [Sashite::Sin::Identifier]
  def inactive_style

  # Returns true if first player is to move.
  #
  # @return [Boolean]
  def first_to_move?

  # Returns true if second player is to move.
  #
  # @return [Boolean]
  def second_to_move?

  # Returns the canonical string representation.
  #
  # @return [String]
  def to_s
end
```

### Constants

```ruby
Sashite::Feen::Constants::MAX_STRING_LENGTH  # => 4096
Sashite::Feen::Constants::MAX_DIMENSIONS     # => 3
Sashite::Feen::Constants::MAX_DIMENSION_SIZE # => 255
```

### Parsing

```ruby
# Parses a FEEN string into a Position.
# Raises ArgumentError if the string is not valid.
#
# @param feen_string [String] FEEN string
# @return [Position]
# @raise [ArgumentError] if invalid
def Sashite::Feen.parse(feen_string)
```

### Validation

```ruby
# Reports whether string is a valid FEEN position.
#
# @param feen_string [String] FEEN string
# @return [Boolean]
def Sashite::Feen.valid?(feen_string)
```

### Errors

All parsing and validation errors raise `ArgumentError` with descriptive messages:

| Message | Cause |
|---------|-------|
| `"input exceeds 4096 characters"` | String too long |
| `"invalid field count"` | Not exactly 3 space-separated fields |
| `"piece placement is empty"` | Field 1 is empty |
| `"piece placement starts with separator"` | Field 1 starts with `/` |
| `"piece placement ends with separator"` | Field 1 ends with `/` |
| `"empty segment"` | Segment between separators contains no tokens |
| `"invalid empty count"` | Empty count is zero or has leading zeros |
| `"invalid piece token"` | Token is not a valid EPIN identifier |
| `"consecutive empty counts must be merged"` | Adjacent empty counts violate canonical form |
| `"dimensional coherence violation"` | Separator of length N without N-1 separators in segments |
| `"exceeds 3 dimensions"` | Board has more than 3 dimensions |
| `"dimension size exceeds 255"` | A rank or layer exceeds 255 squares |
| `"invalid hands delimiter"` | Field 2 missing `/` or contains multiple `/` |
| `"invalid hand count"` | Multiplicity is 0, 1, or has leading zeros |
| `"hand items not aggregated"` | Identical EPIN tokens not combined |
| `"hand items not in canonical order"` | Items violate canonical ordering rules |
| `"invalid style-turn delimiter"` | Field 3 missing `/` or contains multiple `/` |
| `"invalid style token"` | Token is not a valid SIN identifier |
| `"style tokens must have opposite case"` | Both tokens uppercase or both lowercase |
| `"too many pieces for board size"` | Total pieces exceeds total squares |

## Design Principles

- **Spec conformance**: Strict adherence to FEEN v1.0.0
- **Pure composition**: Delegates to EPIN and SIN for token handling
- **Canonical output**: `to_s` always produces canonical form
- **Immutable positions**: Frozen instances prevent mutation
- **Ruby idioms**: `valid?` predicate, `to_s` conversion, `ArgumentError` for invalid input
- **Enumerable support**: `each` methods for iteration

## Related Specifications

- [Game Protocol](https://sashite.dev/game-protocol/) — Conceptual foundation
- [FEEN Specification](https://sashite.dev/specs/feen/1.0.0/) — Official specification
- [FEEN Examples](https://sashite.dev/specs/feen/1.0.0/examples/) — Usage examples
- [EPIN Specification](https://sashite.dev/specs/epin/1.0.0/) — Piece token format
- [SIN Specification](https://sashite.dev/specs/sin/1.0.0/) — Style token format

## License

Available as open source under the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).
