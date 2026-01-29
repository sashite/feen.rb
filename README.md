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
position.piece_placement  # => PiecePlacement object
position.hands            # => Hands object
position.style_turn       # => StyleTurn object

# Invalid input raises ArgumentError
Sashite::Feen.parse("invalid")  # => raises ArgumentError
```

### Formatting (Position → String)

Convert a `Position` back to a FEEN string.

```ruby
# From Position object
position = Sashite::Feen::Position.new(
  piece_placement: piece_placement,
  hands: hands,
  style_turn: style_turn
)
position.to_s  # => "lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s"
```

### Validation

```ruby
# Boolean check
Sashite::Feen.valid?("lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s")  # => true
Sashite::Feen.valid?("k^+p4+PK^ / C/c")                                                     # => true
Sashite::Feen.valid?("invalid")                                                             # => false
Sashite::Feen.valid?("")                                                                    # => false
```

### Accessing Fields

```ruby
position = Sashite::Feen.parse("lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s")

# Get piece placement
position.piece_placement  # => PiecePlacement object

# Get hands
position.hands            # => Hands object
position.hands.first      # => First player's hand
position.hands.second     # => Second player's hand

# Get style-turn
position.style_turn                # => StyleTurn object
position.style_turn.active_style   # => Active player's style (SIN identifier)
position.style_turn.inactive_style # => Inactive player's style (SIN identifier)
```

### Working with Piece Placement

```ruby
position = Sashite::Feen.parse("rheag^aehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAG^AEHR / X/x")

# Iterate over segments
position.piece_placement.each_segment do |segment|
  # Process each segment (rank)
end

# Access as array of tokens
position.piece_placement.to_a
```

### Working with Hands

```ruby
# Parse position with pieces in hand
position = Sashite::Feen.parse("r1bq1b1r/+p+p+p+p1k^+p+p/2n2n2/4p3/4P3/5N2/+P+P+P+P1+P+P+P/-RNBQK^2+R p/B C/c")

# Access hands
position.hands.first   # => First player's hand items
position.hands.second  # => Second player's hand items

# Check if hands are empty
position.hands.first.empty?   # => false
position.hands.second.empty?  # => false
```

### Working with Style-Turn

```ruby
# Chess position after 1.e4 (second player to move)
position = Sashite::Feen.parse("-rnbqk^bn-r/+p+p+p+p+p+p+p+p/8/8/4P3/8/+P+P+P+P1+P+P+P/-RNBQK^BN-R / c/C")

# Get active player info
position.style_turn.active_style    # => SIN identifier for active player
position.style_turn.inactive_style  # => SIN identifier for inactive player

# Check which side is active
position.style_turn.first_to_move?   # => false
position.style_turn.second_to_move?  # => true
```

### Multi-Dimensional Boards

```ruby
# 3D Raumschach position (5×5×5)
feen_3d = "-rnk^n-r/+p+p+p+p+p/5/5/5//buqbu/+p+p+p+p+p/5/5/5//5/5/5/5/5//5/5/5/+P+P+P+P+P/BUQBU//5/5/5/+P+P+P+P+P/-RNK^N-R / R/r"
position = Sashite::Feen.parse(feen_3d)

# 1D Chess (size 8)
feen_1d = "k^+p4+PK^ / C/c"
position = Sashite::Feen.parse(feen_1d)
```

## API Reference

### Types

```ruby
# Position represents a complete FEEN position with all three fields.
class Sashite::Feen::Position
  # Creates a Position from its three components.
  # Raises ArgumentError if any component is invalid.
  #
  # @param piece_placement [PiecePlacement] Board occupancy
  # @param hands [Hands] Off-board pieces
  # @param style_turn [StyleTurn] Styles and active player
  # @return [Position]
  def initialize(piece_placement:, hands:, style_turn:)

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

  # Returns the canonical FEEN string representation.
  #
  # @return [String]
  def to_s
end
```

### Parsing

```ruby
# Parses a FEEN string into a Position.
# Raises ArgumentError if the string is not valid.
#
# @param string [String] FEEN string
# @return [Position]
# @raise [ArgumentError] if invalid
def Sashite::Feen.parse(string)
```

### Validation

```ruby
# Reports whether string is a valid FEEN position.
#
# @param string [String] FEEN string
# @return [Boolean]
def Sashite::Feen.valid?(string)
```

### Errors

All parsing and validation errors raise `ArgumentError` with descriptive messages:

| Message | Cause |
|---------|-------|
| `"empty input"` | String length is 0 |
| `"input too long"` | String exceeds 4096 characters |
| `"invalid field count"` | Not exactly 3 space-separated fields |
| `"piece placement starts with separator"` | Field 1 starts with `/` |
| `"piece placement ends with separator"` | Field 1 ends with `/` |
| `"invalid empty count"` | Zero or leading zeros in empty count |
| `"invalid EPIN token"` | Piece token failed EPIN validation |
| `"invalid hands delimiter"` | Field 2 missing `/` delimiter |
| `"invalid hand count"` | Count is 0, 1, or has leading zeros |
| `"invalid SIN token"` | Style token failed SIN validation |
| `"style tokens must have opposite case"` | Both styles same case |

## Design Principles

- **Spec conformance**: Strict adherence to FEEN v1.0.0 specification
- **Bounded values**: Length and dimension limits prevent resource exhaustion
- **Canonical output**: `to_s` always produces canonical form
- **Composition**: Delegates to EPIN and SIN for token validation
- **Ruby idioms**: `valid?` predicate, `to_s` conversion, `ArgumentError` for invalid input
- **Immutable positions**: Frozen instances prevent mutation
- **No runtime dependencies**: Only EPIN and SIN gems required

## Related Specifications

- [Game Protocol](https://sashite.dev/game-protocol/) — Conceptual foundation
- [FEEN Specification](https://sashite.dev/specs/feen/1.0.0/) — Official specification
- [FEEN Examples](https://sashite.dev/specs/feen/1.0.0/examples/) — Usage examples
- [EPIN Specification](https://sashite.dev/specs/epin/1.0.0/) — Piece token format
- [SIN Specification](https://sashite.dev/specs/sin/1.0.0/) — Style token format

## License

Available as open source under the [Apache License 2.0](https://opensource.org/licenses/Apache-2.0).
