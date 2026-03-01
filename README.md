# feen.rb

[![Version](https://img.shields.io/github/v/tag/sashite/feen.rb?label=Version&logo=github)](https://github.com/sashite/feen.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/feen.rb/main)
[![CI](https://github.com/sashite/feen.rb/actions/workflows/ruby.yml/badge.svg?branch=main)](https://github.com/sashite/feen.rb/actions)
[![License](https://img.shields.io/github/license/sashite/feen.rb?label=License&logo=github)](https://github.com/sashite/feen.rb/raw/main/LICENSE)

> **FEEN** (Field Expression Encoding Notation) implementation for Ruby.

## Overview

This library implements the [FEEN Specification v1.0.0](https://sashite.dev/specs/feen/1.0.0/), providing serialization and deserialization of board game positions between FEEN strings and [`Qi`](https://github.com/sashite/qi.rb) objects.

FEEN is a rule-agnostic, canonical position encoding for two-player, turn-based board games built on the [Sashité Game Protocol](https://sashite.dev/game-protocol/). A FEEN string encodes exactly three fields: **piece placement** (board structure and occupancy), **hands** (off-board pieces), and **style–turn** (player styles and active player).

### Implementation Constraints

| Constraint | Value | Rationale |
|------------|-------|-----------|
| Regular shapes only | Required | All ranks must have equal length within each dimension |
| Max string length | 4096 | Sufficient for realistic board positions |
| Max board dimensions | 3 | Sufficient for 1D, 2D, 3D boards |
| Max dimension size | 255 | Fits in 8-bit integer; covers 255×255×255 boards |

These constraints enable bounded memory usage and safe parsing.

Only regular board shapes are supported — every rank within a dimension must contain the same number of cells. For example, `9x10` and `8x8` boards are valid. Irregular structures where ranks have different sizes (e.g., ranks of 3, 2, and 4 cells) are not supported.

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
gem "qi", "~> 13.0"  # Position model
```

## Usage

### Parsing (FEEN String → Qi)

Convert a FEEN string into a `Qi` object.

```ruby
require "sashite/feen"

# Parse a Shōgi starting position
position = Sashite::Feen.parse("lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s")

# The result is a Qi
position.shape
# => [9, 9]

position.board
# => ["l", "n", "s", "g", "k^", "g", "s", "n", "l",
#     nil, "r", nil, nil, nil, nil, nil, "b", nil,
#     "p", "p", "p", "p", "p", "p", "p", "p", "p",
#     nil, nil, nil, nil, nil, nil, nil, nil, nil,
#     nil, nil, nil, nil, nil, nil, nil, nil, nil,
#     nil, nil, nil, nil, nil, nil, nil, nil, nil,
#     "P", "P", "P", "P", "P", "P", "P", "P", "P",
#     nil, "B", nil, nil, nil, nil, nil, "R", nil,
#     "L", "N", "S", "G", "K^", "G", "S", "N", "L"]

position.to_nested
# => [["l", "n", "s", "g", "k^", "g", "s", "n", "l"],
#     [nil, "r", nil, nil, nil, nil, nil, "b", nil],
#     ["p", "p", "p", "p", "p", "p", "p", "p", "p"],
#     [nil, nil, nil, nil, nil, nil, nil, nil, nil],
#     [nil, nil, nil, nil, nil, nil, nil, nil, nil],
#     [nil, nil, nil, nil, nil, nil, nil, nil, nil],
#     ["P", "P", "P", "P", "P", "P", "P", "P", "P"],
#     [nil, "B", nil, nil, nil, nil, nil, "R", nil],
#     ["L", "N", "S", "G", "K^", "G", "S", "N", "L"]]

position.first_player_hand   # => {}
position.second_player_hand  # => {}
position.first_player_style  # => "S"
position.second_player_style # => "s"
position.turn                # => :first

# Invalid input raises an error
Sashite::Feen.parse("invalid")  # => raises Sashite::Feen::ParseError
```

### Dumping (Qi → FEEN String)

Convert a `Qi` back to a canonical FEEN string.

```ruby
# From an existing Qi
position = Sashite::Feen.parse("8/8/8/8/8/8/8/8 / C/c")
Sashite::Feen.dump(position)
# => "8/8/8/8/8/8/8/8 / C/c"

# From a Qi built manually
position = Qi.new([1, 8], first_player_style: "C", second_player_style: "c")
  .board_diff(0 => "K^", 7 => "k^")
Sashite::Feen.dump(position)
# => "K^6k^ / C/c"
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

### Round-trip Examples

FEEN parsing and dumping are perfect inverses — any valid FEEN string round-trips through `Qi` without loss.

```ruby
# Chess starting position
feen = "-rnbqk^bn-r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/-RNBQK^BN-R / C/c"
position = Sashite::Feen.parse(feen)
Sashite::Feen.dump(position) == feen  # => true

# Xiangqi starting position
feen = "rheag^aehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAG^AEHR / X/x"
position = Sashite::Feen.parse(feen)
Sashite::Feen.dump(position) == feen  # => true
```

### Hands

Pieces in hand are represented as count maps (`Hash{String => Integer}`) in `Qi`. FEEN automatically handles aggregation (for serialization) and expansion (for parsing).

```ruby
# Shōgi mid-game with captured pieces
feen = "lnsgk^gsnl/1r5b1/pppp1pppp/9/9/9/PPPP1PPPP/1B5R1/LNSGK^GSNL P/p S/s"
position = Sashite::Feen.parse(feen)

position.first_player_hand   # => { "P" => 1 }
position.second_player_hand  # => { "p" => 1 }

# Multiple identical pieces are aggregated in FEEN
position = Qi.new([3, 3], first_player_style: "S", second_player_style: "s")
  .board_diff(4 => "K^")
  .first_player_hand_diff("P": 2, "B": 1)
  .second_player_hand_diff("p": 1)
Sashite::Feen.dump(position)
# => "3/1K^1/3 2PB/p S/s"
```

### Multi-dimensional Boards

`Qi` supports 1D, 2D, and 3D boards natively.

```ruby
# 1D board
feen = "k^+p4+PK^ / C/c"
position = Sashite::Feen.parse(feen)
position.shape  # => [8]
position.board
# => ["k^", "+p", nil, nil, nil, nil, "+P", "K^"]

# 3D board (2 layers × 2 ranks × 2 files)
feen = "ab/cd//AB/CD / G/g"
position = Sashite::Feen.parse(feen)
position.shape  # => [2, 2, 2]
position.to_nested
# => [[["a", "b"], ["c", "d"]],
#     [["A", "B"], ["C", "D"]]]
```

### Style–Turn Mapping

The FEEN style–turn field maps directly to `Qi`'s style and turn accessors.

```ruby
# First player to move (uppercase style is active)
position = Sashite::Feen.parse("8/8/8/8/8/8/8/8 / C/c")
position.first_player_style   # => "C"
position.second_player_style  # => "c"
position.turn                 # => :first

# Second player to move (lowercase style is active)
position = Sashite::Feen.parse("8/8/8/8/8/8/8/8 / c/C")
position.first_player_style   # => "C"
position.second_player_style  # => "c"
position.turn                 # => :second
```

## API Reference

### Module Methods

```ruby
# Parses a FEEN string into a Qi.
# Pieces on the board are EPIN token strings; empty squares are nil.
# Raises ParseError (or subclass) if the string is not valid.
#
# @param feen_string [String] FEEN string
# @return [Qi]
# @raise [ParseError] if invalid
def Sashite::Feen.parse(feen_string)

# Reports whether string is a valid FEEN position.
# Never raises; returns false for any invalid input.
# Uses an exception-free code path internally for performance.
#
# @param feen_string [String] FEEN string
# @return [Boolean]
def Sashite::Feen.valid?(feen_string)

# Serializes a Qi to a canonical FEEN string.
# Board pieces must be valid EPIN token strings.
# Style values must be valid SIN token strings.
#
# @param position [Qi] Position to serialize
# @return [String] Canonical FEEN string
# @raise [ArgumentError] if position contains invalid tokens
def Sashite::Feen.dump(position)
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
- **Qi integration**: Parses to and dumps from `Qi`, the shared position model across Sashité libraries
- **Zero external parsing dependencies**: EPIN and SIN validation is inlined for performance; only `Qi` is required at runtime
- **Canonical output**: `dump` always produces canonical form
- **Structured errors**: Hierarchical error classes for precise handling
- **Ruby idioms**: `valid?` predicate, `parse`/`dump` symmetry, `ArgumentError` for invalid input
- **Defensive limits**: Bounded memory usage via configurable constraints
- **Performance-oriented internals**: Exception-free validation path; exceptions only at the public API boundary

### Performance Architecture

Parsing is internally split into two layers to avoid using exceptions for control flow:

- **Validation layer** — Each sub-parser (`PiecePlacement`, `Hands`, `StyleTurn`) exposes a `safe_parse` method that returns `nil` on invalid input instead of raising an exception. This path performs all structural validation and data extraction without allocating exception objects or capturing backtraces.
- **Public API layer** — `parse` calls the validation layer internally. On failure, it raises the appropriate error class exactly once, at the boundary. `valid?` calls the same validation layer and returns a boolean directly, never raising and never constructing a `Qi` object on invalid input.

This dual-path design eliminates the cost of exception-based control flow on the hot path. Since `valid?` is commonly called on untrusted or invalid input, avoiding `raise`/`rescue` per rejection keeps validation at pure method-call speed. On the `parse` side, the single `raise` at the boundary is an acceptable cost — it happens once per invalid call, not once per sub-parser.

## Related Specifications

- [Game Protocol](https://sashite.dev/game-protocol/) — Conceptual foundation
- [FEEN Specification](https://sashite.dev/specs/feen/1.0.0/) — Official specification
- [FEEN Examples](https://sashite.dev/specs/feen/1.0.0/examples/) — Usage examples
- [EPIN Specification](https://sashite.dev/specs/epin/1.0.0/) — Piece token format
- [SIN Specification](https://sashite.dev/specs/sin/1.0.0/) — Style token format

## License

Available as open source under the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).
