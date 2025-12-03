# Feen.rb

[![Version](https://img.shields.io/github/v/tag/sashite/feen.rb?label=Version&logo=github)](https://github.com/sashite/feen.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/feen.rb/main)
![Ruby](https://github.com/sashite/feen.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/feen.rb?label=License&logo=github)](https://github.com/sashite/feen.rb/raw/main/LICENSE.md)

> **FEEN** (Field Expression Encoding Notation) implementation for the Ruby language.

## What is FEEN?

FEEN (Field Expression Encoding Notation) is a universal, rule-agnostic notation for representing board game positions. It extends traditional FEN to support:

- **Multiple game systems** (Chess, Shōgi, Xiangqi, and more)
- **Cross-style games** where players use different piece sets
- **Multi-dimensional boards** (2D, 3D, and beyond)
- **Captured pieces** (pieces-in-hand for drop mechanics)
- **Arbitrarily large boards** with efficient empty square encoding
- **Completely irregular structures** (any valid combination of ranks and separators)
- **Board-less positions** (positions without piece placement, useful for pure style/turn tracking)

This gem implements the [FEEN Specification v1.0.0](https://sashite.dev/specs/feen/1.0.0/) as a pure functional library with immutable data structures.

## Installation

```ruby
gem "sashite-feen"
```

Or install manually:

```sh
gem install sashite-feen
```

## Quick Start

```ruby
require "sashite/feen"

# Parse a FEEN string into an immutable position object
position = Sashite::Feen.parse("+rnbq+k^bn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+K^BN+R / C/c")

# Access position components
position.placement  # Board configuration
position.hands      # Captured pieces
position.styles     # Game styles and active player

# Convert placement to array based on dimensionality
position.placement.to_a # => [[pieces...], [pieces...], ...] for 2D boards

# Convert back to canonical FEEN string
feen_string = Sashite::Feen.dump(position) # or position.to_s
```

## FEEN Format

A FEEN string consists of three space-separated fields:

```
<piece-placement> <pieces-in-hand> <style-turn>
```

**Example:**
```txt
+rnbq+k^bn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+K^BN+R / C/c
```

1. **Piece placement**: Board configuration using EPIN notation with `/` separators (can be empty for board-less positions)
2. **Pieces in hand**: Captured pieces for each player (format: `first/second`)
3. **Style-turn**: Game styles and active player (format: `active/inactive`)

See the [FEEN Specification](https://sashite.dev/specs/feen/1.0.0/) for complete format details.

## API Reference

### Module Methods

#### `Sashite::Feen.parse(string)`

Parses a FEEN string into an immutable `Position` object.

- **Parameter**: `string` (String) - FEEN notation string
- **Returns**: `Position` - Immutable position object
- **Raises**: `Sashite::Feen::Error` subclasses on invalid input

```ruby
position = Sashite::Feen.parse("8/8/8/8/8/8/8/8 / C/c")

# Board-less position (empty piece placement)
position = Sashite::Feen.parse(" / C/c")
```

#### `Sashite::Feen.dump(position)`

Converts a position object into its canonical FEEN string.

- **Parameter**: `position` (Position) - Position object
- **Returns**: `String` - Canonical FEEN string
- **Guarantees**: Deterministic output (same position always produces same string)

```ruby
feen_string = Sashite::Feen.dump(position)
```

### Position Object

The `Position` object is immutable and provides read-only access to three components:

```ruby
position.placement  # => Placement (board configuration)
position.hands      # => Hands (pieces in hand)
position.styles     # => Styles (style-turn information)
position.to_s       # => String (canonical FEEN)
```

**Equality and hashing:**
```ruby
position1 == position2  # Component-wise equality
position1.hash          # Consistent hash for same positions
```

### Placement Object

Represents the board configuration as a flat array of ranks with explicit separators.

```ruby
placement.ranks         # => Array<Array> - Flat array of all ranks
placement.separators    # => Array<String> - Separators between ranks (e.g., ["/", "//"])
placement.dimension     # => Integer - Board dimensionality (1 + max consecutive slashes)
placement.rank_count    # => Integer - Total number of ranks
placement.one_dimensional? # => Boolean - True if dimension is 1
placement.all_pieces    # => Array - All pieces (nils excluded)
placement.total_squares # => Integer - Total square count
placement.to_s          # => String - Piece placement field
placement.to_a          # => Array - Array representation (dimension-aware)
```

#### `to_a` - Dimension-Aware Array Conversion

The `to_a` method returns an array representation that adapts to the board's dimensionality:

- **1D boards**: Returns a single rank array (or empty array if no ranks)
- **2D+ boards**: Returns array of ranks

```ruby
# 1D board - Returns flat array
feen = "K^2P3k^ / C/c"
position = Sashite::Feen.parse(feen)
position.placement.to_a
# => [K, nil, nil, P, nil, nil, nil, k]

# 2D board - Returns array of arrays
feen = "+rnbq+k^bn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+K^BN+R / C/c"
position = Sashite::Feen.parse(feen)
position.placement.to_a
# => [[+r,n,b,q,+k^,b,n,+r], [+p,+p,+p,+p,+p,+p,+p,+p], [nil×8], ...]

# 3D board - Returns array of ranks (to be structured by application)
feen = "5/5//5/5 / R/r"
position = Sashite::Feen.parse(feen)
position.placement.to_a
# => [[nil×5], [nil×5], [nil×5], [nil×5]]

# Empty board
placement = Sashite::Feen::Placement.new([], [], 1)
placement.to_a
# => []
```

**Other methods:**

```ruby
# Access specific positions
first_rank = placement.ranks[0]
piece_at_a1 = first_rank[0] # Piece object or nil

# Check dimensionality
placement.dimension # => 2 (2D board)

# Inspect separator structure
placement.separators # => ["/", "/", "/", "/", "/", "/", "/"]
```

### Hands Object

Represents captured pieces held by each player.

```ruby
hands.first_player   # => Array - Pieces held by first player
hands.second_player  # => Array - Pieces held by second player
hands.empty?         # => Boolean - True if both hands are empty
hands.to_s           # => String - Pieces-in-hand field
```

**Example:**
```ruby
# Count pieces in hand
first_player_pawns = hands.first_player.count { |p| p.to_s == "P" }

# Check if any captures
hands.empty? # => false
```

### Styles Object

Represents game styles and indicates the active player.

```ruby
styles.active    # => SIN identifier - Active player's style
styles.inactive  # => SIN identifier - Inactive player's style
styles.to_s      # => String - Style-turn field
```

**Example:**
```ruby
# Determine active player
styles.active.to_s    # => "C" (first player Chess)
styles.inactive.to_s  # => "c" (second player Chess)

# Check if cross-style
styles.active.to_s.upcase != styles.inactive.to_s.upcase
```

## Examples

### Chess Positions

```ruby
# Starting position
chess_start = Sashite::Feen.parse(
  "+rnbq+k^bn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+K^BN+R / C/c"
)

# After 1.e4
after_e4 = Sashite::Feen.parse(
  "+rnbq+k^bn+r/+p+p+p+p+p+p+p+p/8/8/4P3/8/+P+P+P+P1+P+P+P/+RNBQ+K^BN+R / c/C"
)

# Ruy Lopez opening
ruy_lopez = Sashite::Feen.parse(
  "+r1bq+k^bn+r/+p+p+p+p1+p+p+p/2n5/1B2p3/4P3/5N2/+P+P+P+P1+P+P+P/+RNBQ+K^2+R / c/C"
)
```

### Shōgi with Captured Pieces

```ruby
# Starting position
shogi_start = Sashite::Feen.parse(
  "lnsgk^gsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGK^GSNL / S/s"
)

# Position with pieces in hand
shogi_midgame = Sashite::Feen.parse(
  "lnsgk^gsnl/1r5b1/pppp1pppp/9/4p4/9/PPPP1PPPP/1B5R1/LNSGK^GSNL P/p s/S"
)

# Access captured pieces
position = shogi_midgame
position.hands.first_player   # => [P] (one pawn)
position.hands.second_player  # => [p] (one pawn)

# Count specific pieces in hand
position.hands.first_player.count { |p| p.to_s == "P" } # => 1
```

### Cross-Style Games

```ruby
# Chess vs Makruk
chess_vs_makruk = Sashite::Feen.parse(
  "rnsmk^snr/8/pppppppp/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+K^BN+R / C/m"
)

# Chess vs Shōgi
chess_vs_shogi = Sashite::Feen.parse(
  "lnsgk^gsnl/1r5b1/pppppppp/9/9/9/+P+P+P+P+P+P+P+P/+RNBQ+K^BN+R / C/s"
)

# Check styles
position = chess_vs_makruk
position.styles.active.to_s    # => "C" (Chess, first player)
position.styles.inactive.to_s  # => "m" (Makruk, second player)
```

### Multi-Dimensional Boards

```ruby
# 3D Chess (Raumschach)
raumschach = Sashite::Feen.parse(
  "+rn+k^n+r/+p+p+p+p+p/5/5/5//buqbu/+p+p+p+p+p/5/5/5//5/5/5/5/5//5/5/5/+P+P+P+P+P/BUQBU//5/5/5/+P+P+P+P+P/+RN+K^N+R / R/r"
)

# Check dimensionality
raumschach.placement.dimension  # => 3 (3D board)
raumschach.placement.ranks.size # => 25 (total ranks)

# Inspect separator structure
level_seps = raumschach.placement.separators.count { |s| s == "//" }
rank_seps = raumschach.placement.separators.count { |s| s == "/" }
# level_seps => 4 (separates 5 levels)
# rank_seps => 20 (separates ranks within levels)
```

### Irregular Boards

```ruby
# Diamond-shaped board
diamond = Sashite::Feen.parse("3/4/5/4/3 / G/g")

# Check structure
diamond.placement.ranks.map(&:size) # => [3, 4, 5, 4, 3]

# Very large board
large_board = Sashite::Feen.parse("100/100/100 / G/g")
large_board.placement.total_squares # => 300

# Single square
single = Sashite::Feen.parse("K^ / C/c")
single.placement.rank_count # => 1
```

### Completely Irregular Structures

FEEN supports any valid combination of ranks and separators:

```ruby
# Extreme irregularity with variable separators
feen = "99999/3///K^/k^//r / G/g"
position = Sashite::Feen.parse(feen)

# Access the structure
position.placement.ranks.size      # => 5 ranks
position.placement.separators      # => ["/", "///", "/", "//"]
position.placement.dimension       # => 4 (max separator is "///")

# Each rank can have different sizes
position.placement.ranks[0].size   # => 99999
position.placement.ranks[1].size   # => 3
position.placement.ranks[2].size   # => 1
position.placement.ranks[3].size   # => 1
position.placement.ranks[4].size   # => 1

# Round-trip preservation
Sashite::Feen.dump(position) == feen # => true
```

### Empty Ranks

FEEN supports empty ranks (ranks with no pieces):

```ruby
# Trailing separator creates empty rank
feen = "K^/// / C/c"
position = Sashite::Feen.parse(feen)

position.placement.ranks.size  # => 2
position.placement.ranks[0]    # => [K^]
position.placement.ranks[1]    # => [] (empty rank)
position.placement.separators  # => ["///"]

# Round-trip preserves structure
Sashite::Feen.dump(position) == feen # => true
```

### Board-less Positions

FEEN supports positions without piece placement, useful for tracking only style and turn information:

```ruby
# Position with empty board (no piece placement)
board_less = Sashite::Feen.parse(" / C/c")

board_less.placement.ranks.size     # => 1
board_less.placement.dimension      # => 1
board_less.placement.to_a           # => []

# Convert back to FEEN
Sashite::Feen.dump(board_less) # => " / C/c"
```

### Working with Positions

```ruby
# Compare positions
position1 = Sashite::Feen.parse("8/8/8/8/8/8/8/8 / C/c")
position2 = Sashite::Feen.parse("8/8/8/8/8/8/8/8 / C/c")
position1 == position2 # => true

# Round-trip parsing
original = "+rnbq+k^bn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+K^BN+R / C/c"
position = Sashite::Feen.parse(original)
Sashite::Feen.dump(position) == original # => true

# Extract specific information
position.placement.ranks[0] # First rank (array of pieces/nils)
position.hands.first_player.size # Number of captured pieces
```

### State Modifiers and Derivation

```ruby
# Enhanced pieces (promoted, with special rights)
enhanced = Sashite::Feen.parse("+K^+Q+R+B/8/8/8/8/8/8/8 / C/c")

# Diminished pieces (weakened, vulnerable)
diminished = Sashite::Feen.parse("-K^-Q-R-B/8/8/8/8/8/8/8 / C/c")

# Foreign pieces (using opponent's style)
foreign = Sashite::Feen.parse("K^'Q'R'B'/k^'q'r'b'/8/8/8/8/8/8 / C/s")
```

## Error Handling

FEEN defines specific error classes for different validation failures:

```ruby
begin
  position = Sashite::Feen.parse("invalid feen")
rescue Sashite::Feen::Error => e
  # Base error class catches all FEEN errors
  warn "FEEN error: #{e.message}"
end
```

### Error Hierarchy

```txt
Sashite::Feen::Error             # Base error class
├── Error::Syntax                # Malformed FEEN structure
├── Error::Piece                 # Invalid EPIN notation
├── Error::Style                 # Invalid SIN notation
├── Error::Count                 # Invalid piece counts
└── Error::Validation            # Other semantic violations
```

### Common Errors

```ruby
# Syntax error - wrong field count
Sashite::Feen.parse("8/8/8/8/8/8/8/8 /")
# => Error::Syntax: "FEEN must have exactly 3 space-separated fields, got 2"

# Style error - invalid SIN
Sashite::Feen.parse("8/8/8/8/8/8/8/8 / 1/2")
# => Error::Style: "failed to parse SIN '1': invalid SIN notation: '1' (must be a single letter A-Z or a-z)"

# Count error - invalid quantity
Sashite::Feen.parse("8/8/8/8/8/8/8/8 0P/ C/c")
# => Error::Count: "piece count must be at least 1, got 0"
```

## Properties

- **Purely functional**: Immutable data structures, no side effects
- **Canonical output**: Deterministic string generation (same position → same string)
- **Specification compliant**: Strict adherence to [FEEN v1.0.0](https://sashite.dev/specs/feen/1.0.0/)
- **Minimal API**: Two methods (`parse` and `dump`) for complete functionality
- **Universal**: Supports any abstract strategy board game
- **Completely flexible**: Accepts any valid combination of ranks and separators
- **Perfect round-trip**: `parse(dump(position)) == position` guaranteed
- **Dimension-aware**: Intelligent array conversion based on board structure
- **Composable**: Built on [EPIN](https://github.com/sashite/epin.rb) and [SIN](https://github.com/sashite/sin.rb) specifications

## Dependencies

- [sashite-epin](https://github.com/sashite/epin.rb) — Extended Piece Identifier Notation
- [sashite-sin](https://github.com/sashite/sin.rb) — Style Identifier Notation

## Documentation

- [FEEN Specification v1.0.0](https://sashite.dev/specs/feen/1.0.0/) — Complete technical specification
- [FEEN Examples](https://sashite.dev/specs/feen/1.0.0/examples/) — Comprehensive examples
- [API Documentation](https://rubydoc.info/github/sashite/feen.rb/main) — Full API reference
- [GitHub Wiki](https://github.com/sashite/feen.rb/wiki) — Advanced usage and patterns

## Development

```sh
# Clone the repository
git clone https://github.com/sashite/feen.rb.git
cd feen.rb

# Install dependencies
bundle install

# Run tests
ruby test.rb

# Generate documentation
yard doc
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Add tests for your changes
4. Ensure all tests pass (`ruby test.rb`)
5. Commit your changes (`git commit -am 'Add new feature'`)
6. Push to the branch (`git push origin feature/new-feature`)
7. Create a Pull Request

## License

Available as open source under the [MIT License](https://opensource.org/licenses/MIT).

## About

Maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of board game cultures.
