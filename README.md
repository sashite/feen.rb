# Feen.rb

[![Version](https://img.shields.io/github/v/tag/sashite/feen.rb?label=Version&logo=github)](https://github.com/sashite/feen.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/feen.rb/main)
![Ruby](https://github.com/sashite/feen.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/feen.rb?label=License&logo=github)](https://github.com/sashite/feen.rb/raw/main/LICENSE.md)

> A Ruby library for **FEEN** (Forsyth–Edwards Enhanced Notation) - a compact, canonical, and rule-agnostic textual format for representing static board positions in two-player piece-placement games.

## What is FEEN?

FEEN is like taking a snapshot of any board game position and turning it into a text string. Think of it as a "save file" format that works across different board games - from Chess to Shōgi to custom variants.

**Key Features:**

- **Rule-agnostic**: No knowledge of specific game rules required
- **Canonical**: Equivalent positions yield identical strings
- **Cross-style support**: Handles hybrid configurations with different piece sets
- **Multi-dimensional**: Supports 2D, 3D, and higher dimensional boards
- **Captured pieces**: Full support for pieces-in-hand mechanics
- **Compact**: Efficient representation with compression for empty spaces

## Installation

Add this line to your application's Gemfile:

```ruby
gem "feen", ">= 5.0.0.beta10"
```

Or install it directly:

```bash
gem install feen --pre
```

## Quick Start

### Basic Example: Converting a Position to Text

```ruby
require "feen"

# Represent a simple 3x1 board with pieces "r", "k", "r"
board = [["r", "k", "r"]]

feen_string = Feen.dump(
  piece_placement: board,
  pieces_in_hand:  [],              # No captured pieces
  style_turn:      ["GAME", "game"] # GAME player's turn
)

feen_string # => "rkr / GAME/game"
```

### Basic Example: Converting Text Back to Position

```ruby
require "feen"

feen_string = "rkr / GAME/game"
position = Feen.parse(feen_string)

position[:piece_placement]  # => ["r", "k", "r"]
position[:pieces_in_hand]   # => []
position[:style_turn]       # => ["GAME", "game"]
```

## Understanding FEEN Format

A FEEN string has exactly **three parts separated by single spaces**:

```
<PIECE-PLACEMENT> <PIECES-IN-HAND> <STYLE-TURN>
```

### Part 1: Piece Placement

The board shows where pieces are placed, always from the point of view of the player who plays first in the initial position:

- **Pieces**: Represented by PNN notation (case matters!)
  - `K` = piece belonging to first player (uppercase style)
  - `k` = piece belonging to second player (lowercase style)
  - `+P` = enhanced piece (modifier allowed on board only)
  - `-R` = diminished piece (modifier allowed on board only)
  - `N'` = intermediate state piece (modifier allowed on board only)
- **Empty spaces**: Represented by numbers
  - `3` = three empty squares in a row
- **Ranks (rows)**: Separated by `/`
- **Higher dimensions**: Use multiple `/` characters (`//`, `///`, etc.)

**Examples:**

```ruby
"K"         # Single piece on 1x1 board
"3"         # Three empty squares
"Kqr"       # Three pieces: K, q, r
"K2r"       # K, two empty squares, then r
"Kqr/3/R2k" # 3x3 board with multiple ranks
"+K-r/N'"   # Board with piece modifiers
```

### Part 2: Pieces in Hand

Shows pieces that have been captured and are available for future placement:

- Format: `UPPERCASE_PIECES/lowercase_pieces`
- **Always separated by `/`** even if empty
- **Base form only**: No modifiers allowed (captured pieces revert to base type)
- Count notation: `3P` means three `P` pieces (never `1P` for single pieces)
- **Canonical sorting**: By quantity (descending), then alphabetical

**Examples:**

```ruby
"/"         # No pieces captured
"P/"        # First player has one P piece
"/p"        # Second player has one p piece
"2PK/3p"    # First player: 2 P's + 1 K, Second player: 3 p's
"3P2RK/2pb" # Sorted by quantity, then alphabetical
```

**Critical: Canonical Piece Sorting Algorithm**

Captured pieces are automatically sorted according to the FEEN specification:

1. **By player**: Uppercase pieces first, then lowercase pieces (separated by `/`)
2. **By quantity** (descending): Most frequent pieces first
3. **By base letter** (ascending): Alphabetical within same quantity
4. **By prefix** (specific order): For same base letter and quantity: `-`, `+`, then no prefix
5. **By suffix** (specific order): For same prefix: no suffix, then `'`

**Detailed sorting example:**

```ruby
# Input pieces: PP+P'PPP+P'KS'S-PB+B+B+P'BBBPPPSP-P-P'-PRB
# Step 1 - Group by base letter and modifiers:
# B: +B+B+BBBBB = 2+B + 5B
# K: K = K
# P: -P-P-P-P' + +P'+P'+P' + PPPPPPPPP = 3-P + -P' + 3+P' + 9P
# R: R = R
# S: SS + S' = 2S + S'

# Step 2 - Sort by quantity (desc), then letter (asc), then prefix/suffix:
# Result: "2+B5BK3-P-P'3+P'9PR2SS'"

# Canonical form: "2+B5BK3-P-P'3+P'9PR2SS'/"
```

### Part 3: Style Turn

Identifies the style type associated with each player and whose turn it is:

- Format: `ACTIVE_PLAYER/INACTIVE_PLAYER`
- **One must be uppercase, other lowercase** (semantically significant casing)
- The uppercase name identifies the style system for uppercase pieces
- The lowercase name identifies the style system for lowercase pieces
- First name refers to the player to move

**Examples:**

```ruby
"CHESS/chess" # CHESS player (uppercase pieces) to move
"shogi/SHOGI" # shogi player (lowercase pieces) to move
"CHESS/makruk" # Cross-style: CHESS vs makruk, CHESS to move
```

## Complete API Reference

### Core Methods

#### `Feen.dump(**options)`

Converts position components into a FEEN string.

**Parameters:**
- `piece_placement:` [Array] - Nested array representing the board
- `pieces_in_hand:` [Array] - List of captured pieces (strings, base form only)
- `style_turn:` [Array] - Two-element array: [active_player, inactive_player]

**Returns:** String - Canonical FEEN notation

**Example:**

```ruby
board = [
  ["r", "n", "k", "n", "r"],  # Back rank
  ["", "", "", "", ""],       # Empty rank
  ["P", "P", "P", "P", "P"]   # Front rank
]

feen = Feen.dump(
  piece_placement: board,
  pieces_in_hand:  ["Q", "p"],
  style_turn:      ["WHITE", "black"]
)
# => "rnknr/5/PPPPP Q/p WHITE/black"
```

#### `Feen.parse(feen_string)`

Converts a FEEN string back into position components.

**Parameters:**

- `feen_string` [String] - Valid FEEN notation

**Returns:** Hash with keys:

- `:piece_placement` - The board as nested arrays
- `:pieces_in_hand` - Captured pieces as array of strings
- `:style_turn` - [active_player, inactive_player]

**Example:**

```ruby
position = Feen.parse("rnknr/5/PPPPP Q/p WHITE/black")

position[:piece_placement]
# => [["r", "n", "k", "n", "r"], ["", "", "", "", ""], ["P", "P", "P", "P", "P"]]

position[:pieces_in_hand]
# => ["Q", "p"]

position[:style_turn]
# => ["WHITE", "black"]
```

#### `Feen.safe_parse(feen_string)`

Like `parse()` but returns `nil` instead of raising exceptions for invalid input.

**Example:**

```ruby
# Valid input
result = Feen.safe_parse("k/K / GAME/game")
# => { piece_placement: [["k"], ["K"]], pieces_in_hand: [], style_turn: ["GAME", "game"] }

# Invalid input
result = Feen.safe_parse("invalid")
# => nil
```

#### `Feen.valid?(feen_string)`

Checks if a string is valid, canonical FEEN notation.

**Returns:** Boolean

**Example:**

```ruby
Feen.valid?("k/K / GAME/game")    # => true
Feen.valid?("invalid")            # => false
Feen.valid?("k/K 3PK/ GAME/game") # => false (wrong piece order)
```

## Working with Different Board Sizes

### Standard 2D Boards

```ruby
# 8x8 chess-like board (empty)
board = Array.new(8) { Array.new(8, "") }

# 9x9 board with pieces in corners
board = Array.new(9) { Array.new(9, "") }
board[0][0] = "r"  # Top-left
board[8][8] = "R"  # Bottom-right

feen = Feen.dump(
  piece_placement: board,
  pieces_in_hand:  [],
  style_turn:      ["PLAYERA", "playerb"]
)

feen # => "r8/9/9/9/9/9/9/9/8R / PLAYERA/playerb"
```

### 3D Boards

```ruby
# Simple 2x2x2 cube
board_3d = [
  [["a", "b"], ["c", "d"]],  # First layer
  [["A", "B"], ["C", "D"]]   # Second layer
]

feen = Feen.dump(
  piece_placement: board_3d,
  pieces_in_hand:  [],
  style_turn:      ["UP", "down"]
)
# => "ab/cd//AB/CD / UP/down"
```

### Irregular Boards

```ruby
# Different sized ranks are allowed
irregular_board = [
  ["r", "k", "r"],      # 3 squares
  ["p", "p"],           # 2 squares
  ["P", "P", "P", "P"]  # 4 squares
]

feen = Feen.dump(
  piece_placement: irregular_board,
  pieces_in_hand:  [],
  style_turn:      ["GAME", "game"]
)
# => "rkr/pp/PPPP / GAME/game"
```

## Working with Captured Pieces

### Basic Captures

```ruby
# Player 1 captured 3 pawns and 1 rook
# Player 2 captured 2 pawns
captured = ["P", "P", "P", "R", "p", "p"]

feen = Feen.dump(
  piece_placement: [["k"], ["K"]],  # Minimal board
  pieces_in_hand:  captured,
  style_turn:      ["FIRST", "second"]
)
# => "k/K 3PR/2p FIRST/second"
```

### Understanding Canonical Piece Sorting

Captured pieces are automatically sorted in canonical order according to the FEEN specification:

1. **By player**: Uppercase pieces first, then lowercase pieces (separated by `/`)
2. **By quantity** (descending): Most frequent pieces first
3. **By base letter** (ascending): Alphabetical within same quantity
4. **By prefix** (specific order): For same base letter and quantity: `-`, `+`, then no prefix
5. **By suffix** (specific order): For same prefix: no suffix, then `'`

**Complex sorting example:**

```ruby
# Mixed pieces with modifiers
pieces = ["-B", "+B", "+B", "B", "B", "B", "B", "B", "K", "-P", "-P", "-P", "-P'", "+P'", "+P'", "+P'", "P", "P", "P", "P", "P", "P", "P", "P", "P", "R", "S", "S", "S'", "b", "p"]

# After canonical sorting: "2+B5BK3-P-P'3+P'9PR2SS'/bp"
# Breakdown:
# - Uppercase: 2+B (2 enhanced B), 5B (5 regular B), K (1 King), 3-P (3 diminished P), -P' (1 diminished P with intermediate state), 3+P' (3 enhanced P with intermediate state), 9P (9 regular P), R (1 Rook), 2S (2 regular S), S' (1 S with intermediate state)
# - Lowercase: b (1 bishop), p (1 pawn)
```

## Advanced Features

### Special Piece States (Board Only)

For games that need special piece states, use PNN modifiers **only on the board**:

```ruby
board = [
  ["+P", "K", "-R"],  # Enhanced pawn, King, diminished rook
  ["N'", "", "B"]     # Knight with intermediate state, empty, Bishop
]

# Note: Modifiers are allowed on the board
# Pieces in hand may or may not have modifiers depending on game rules
feen = Feen.dump(
  piece_placement: board,
  pieces_in_hand:  ["P", "+R'"],  # Modifiers allowed in hand per FEEN spec
  style_turn:      ["GAME", "game"]
)

feen # => "+PK-R/N'1B P+R'/ GAME/game"
```

### Cross-Style Scenarios

FEEN can represent positions mixing different game systems:

```ruby
# CHESS pieces vs makruk pieces
cross_style_feen = Feen.dump(
  piece_placement: [["K", "Q", "k", "m"]],  # Mixed piece types
  pieces_in_hand:  ["P", "s"],              # Captured from both sides
  style_turn:      ["CHESS", "makruk"]      # Different game systems
)

cross_style_feen # => "KQkm P/s CHESS/makruk"
```

### Dynamic Piece Ownership

FEEN supports piece ownership changes through capture and redeployment:

```ruby
# A piece's current owner is determined by its case
# Regardless of its original style system
board = [["r", "K"]]  # lowercase 'r' owned by second player
                      # uppercase 'K' owned by first player

feen = Feen.dump(
  piece_placement: board,
  pieces_in_hand:  [],
  style_turn:      ["CHESS", "shogi"]  # Cross-style game
)
# => "rK / CHESS/shogi"
```

## Error Handling

### Common Errors and Solutions

```ruby
# ERROR: Wrong argument types
Feen.dump(
  piece_placement: "not an array",  # Must be Array
  pieces_in_hand:  "not an array",  # Must be Array
  style_turn:      "not an array"   # Must be Array[2]
)
# => ArgumentError

# ERROR: Invalid pieces in captured pieces (if validation enabled)
Feen.dump(
  piece_placement: [["K"]],
  pieces_in_hand:  ["invalid_piece"], # Must follow PNN specification
  style_turn:      ["GAME", "game"]
)
# => ArgumentError (if validation enabled)

# ERROR: Same case in style_turn
Feen.dump(
  piece_placement: [["K"]],
  pieces_in_hand:  [],
  style_turn:      ["GAME", "ALSO"] # Must be different cases
)
# => ArgumentError

# ERROR: Invalid style identifiers
Feen.dump(
  piece_placement: [["K"]],
  pieces_in_hand:  [],
  style_turn:      ["game-1", "game2"] # Must follow SNN specification
)
# => ArgumentError
```

### Safe Parsing for User Input

```ruby
def process_user_feen(user_input)
  position = Feen.safe_parse(user_input)

  if position
    puts "Valid position with #{position[:pieces_in_hand].size} captured pieces"
    # Process the position...
  else
    puts "Invalid FEEN format. Please check your input."
  end
end
```

## Real-World Examples

### International Chess Starting Position

```ruby
chess_start = Feen.dump(
  piece_placement: [
    ["r", "n", "b", "q", "k", "b", "n", "r"],
    ["p", "p", "p", "p", "p", "p", "p", "p"],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["P", "P", "P", "P", "P", "P", "P", "P"],
    ["R", "N", "B", "Q", "K", "B", "N", "R"]
  ],
  pieces_in_hand: [],
  style_turn: ["CHESS", "chess"]
)
# => "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / CHESS/chess"
```

### Japanese Shōgi Starting Position

```ruby
shogi_start = Feen.dump(
  piece_placement: [
    ["l", "n", "s", "g", "k", "g", "s", "n", "l"],
    ["", "r", "", "", "", "", "", "b", ""],
    ["p", "p", "p", "p", "p", "p", "p", "p", "p"],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["P", "P", "P", "P", "P", "P", "P", "P", "P"],
    ["", "B", "", "", "", "", "", "R", ""],
    ["L", "N", "S", "G", "K", "G", "S", "N", "L"]
  ],
  pieces_in_hand: [],
  style_turn: ["SHOGI", "shogi"]
)
# => "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / SHOGI/shogi"
```

### Shōgi Position with Captured Pieces

```ruby
# Game in progress with captured pieces
shogi_midgame = Feen.dump(
  piece_placement: [
    ["l", "n", "s", "g", "k", "g", "s", "n", "l"],
    ["", "r", "", "", "", "", "", "", ""],
    ["p", "p", "p", "p", "p", "p", "p", "p", "p"],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", "", ""],
    ["P", "P", "P", "P", "P", "P", "P", "P", "P"],
    ["", "B", "", "", "", "", "", "R", ""],
    ["L", "N", "S", "G", "K", "G", "S", "N", "L"]
  ],
  pieces_in_hand: ["B", "P", "P", "b", "p"],  # Captured pieces
  style_turn: ["SHOGI", "shogi"]
)
# => "lnsgkgsnl/1r7/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL 2PB/bp SHOGI/shogi"
```

### Save/Load Game State

```ruby
class GameState
  def save_position(board, captured, current_player, opponent)
    feen = Feen.dump(
      piece_placement: board,
      pieces_in_hand:  captured,
      style_turn:      [current_player, opponent]
    )

    File.write("game_save.feen", feen)
  end

  def load_position(filename)
    feen_string = File.read(filename)
    Feen.parse(feen_string)
  rescue => e
    warn "Could not load game: #{e.message}"
    nil
  end
end
```

### Position Database

```ruby
class PositionDatabase
  def initialize
    @positions = {}
  end

  def store_position(name, board, captured, turn_info)
    feen = Feen.dump(
      piece_placement: board,
      pieces_in_hand:  captured,
      style_turn:      turn_info
    )

    @positions[name] = feen
  end

  def retrieve_position(name)
    feen = @positions[name]
    return nil unless feen

    Feen.parse(feen)
  end

  def validate_all_positions
    @positions.each do |name, feen|
      puts "Invalid position: #{name}" unless Feen.valid?(feen)
    end
  end
end

# Usage example:
db = PositionDatabase.new
db.store_position("start", [["r", "k", "r"]], [], ["GAME", "game"])
position = db.retrieve_position("start")
# => { piece_placement: [["r", "k", "r"]], pieces_in_hand: [], style_turn: ["GAME", "game"] }
```

## Best Practices

### 1. Always Validate Input

```ruby
def create_feen_safely(board, captured, turn)
  # Validate before creating
  return nil unless board.is_a?(Array)
  return nil unless captured.is_a?(Array)
  return nil unless turn.is_a?(Array) && turn.size == 2

  Feen.dump(
    piece_placement: board,
    pieces_in_hand:  captured,
    style_turn:      turn
  )
rescue ArgumentError => e
  puts "FEEN creation failed: #{e.message}"
  nil
end
```

### 2. Use Consistent Style Naming

```ruby
# Good: Follow SNN specification conventions
STYLE_IDENTIFIERS = {
  chess_white: "CHESS",
  chess_black: "chess",
  shogi_sente: "SHOGI",
  shogi_gote: "shogi",
  xiangqi_red: "XIANGQI",
  xiangqi_black: "xiangqi"
}

# Good: Clear piece type distinctions following PNN
CHESS_PIECES = %w[K Q R B N P]  # Uppercase for first player
CHESS_PIECES_LOWER = %w[k q r b n p]  # Lowercase for second player
```

### 3. Handle Cross-Style Scenarios Carefully

```ruby
def validate_cross_style_position(feen_string)
  position = Feen.parse(feen_string)
  styles = position[:style_turn]

  # Check if it's a cross-style game
  if styles[0].downcase != styles[1].downcase
    puts "Cross-style game detected: #{styles[0]} vs #{styles[1]}"
    # Consider piece identity ambiguity implications
  end
end
```

### 4. Round-trip Validation

```ruby
def verify_feen_consistency(original_feen)
  # Parse and re-dump to check canonical format
  position = Feen.parse(original_feen)
  regenerated = Feen.dump(**position)

  if original_feen == regenerated
    puts "✓ FEEN is canonical"
  else
    puts "✗ FEEN inconsistency detected"
    puts "Original:    #{original_feen}"
    puts "Regenerated: #{regenerated}"
  end
end
```

## FEEN Specification Compliance

This library implements **FEEN v1.0.0** specification with the following features:

### Core Properties ✓
- Rule-agnostic representation
- Canonical format enforcement
- Cross-style/hybrid position support
- Multi-dimensional board support
- Two-player limitation (exactly)
- 26-piece limit per player (a-z, A-Z)

### Field Support ✓
- **Piece Placement**: Full PNN notation with modifiers on board
- **Pieces in Hand**: Full PNN notation with modifiers (as per specification), canonical sorting
- **Style Turn**: SNN-compliant identifiers with semantic casing

### Advanced Features ✓
- Dynamic piece ownership through capture
- Irregular board shapes
- 3D and higher-dimensional boards
- Empty space compression
- Proper dimension separators (`/`, `//`, `///`)
- **Strict canonical piece sorting** per FEEN specification

### Canonical Sorting Implementation ✓
The library implements the exact sorting algorithm specified in FEEN v1.0.0:
1. Player separation (uppercase/lowercase)
2. Quantity (descending)
3. Base letter (ascending)
4. Prefix order: `-`, `+`, no prefix
5. Suffix order: no suffix, `'`

## Compatibility and Performance

- **Ruby Version**: >= 3.2.0
- **Thread Safety**: All operations are thread-safe
- **Memory**: Efficient array-based representation
- **Performance**: O(n) parsing and generation complexity
- **Format**: Full compliance with FEEN v1.0.0 specification

## Related Resources

- [FEEN Specification v1.0.0](https://sashite.dev/documents/feen/1.0.0/) - Complete format specification
- [PNN Specification v1.0.0](https://sashite.dev/documents/pnn/1.0.0/) - Piece notation details
- [SNN Specification v1.0.0](https://sashite.dev/documents/snn/1.0.0/) - Style name notation
- [GAN Specification v1.0.0](https://sashite.dev/documents/gan/1.0.0/) - Game-qualified identifiers

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sashite/feen.rb.

## License

The [gem](https://rubygems.org/gems/feen) is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This project is maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of Chinese, Japanese, and Western chess cultures.
