# Feen.rb

[![Version](https://img.shields.io/github/v/tag/sashite/feen.rb?label=Version&logo=github)](https://github.com/sashite/feen.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/feen.rb/main)
![Ruby](https://github.com/sashite/feen.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/feen.rb?label=License&logo=github)](https://github.com/sashite/feen.rb/raw/main/LICENSE.md)

> A Ruby library for **FEEN** (Forsyth–Edwards Enhanced Notation) - a flexible format for representing positions in two-player piece-placement games.

## What is FEEN?

FEEN is like taking a snapshot of any board game position and turning it into a text string. Think of it as a "save file" format that works across different board games - from Chess to Shōgi to custom variants.

**Key Features:**

- **Versatile**: Supports Chess, Shōgi, Xiangqi, and similar games
- **Bidirectional**: Convert positions to text and back
- **Compact**: Efficient representation
- **Rule-agnostic**: No knowledge of specific game rules required
- **Multi-dimensional**: Supports 2D, 3D, and higher dimensions

## Installation

Add this line to your application's Gemfile:

```ruby
gem "feen", ">= 5.0.0.beta9"
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
  games_turn:      ["GAME", "game"] # GAME player's turn
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
position[:games_turn]       # => ["GAME", "game"]
```

## Understanding FEEN Format

A FEEN string has exactly **three parts separated by single spaces**:

```
<BOARD> <CAPTURED_PIECES> <TURN_INFO>
```

### Part 1: Board Representation

The board shows where pieces are placed:

- **Pieces**: Represented by letters (case matters!)
  - `K` = piece belonging to first player (uppercase)
  - `k` = piece belonging to second player (lowercase)
- **Empty spaces**: Represented by numbers
  - `3` = three empty squares in a row
- **Ranks (rows)**: Separated by `/`

**Examples:**

```ruby
"K"         # Single piece on 1x1 board
"3"         # Three empty squares
"Kqr"       # Three pieces: K, q, r
"K2r"       # K, two empty squares, then r
"Kqr/3/R2k" # 3x3 board with multiple ranks
```

### Part 2: Captured Pieces (Pieces in Hand)

Shows pieces that have been captured and can potentially be used again:

- Format: `UPPERCASE_PIECES/lowercase_pieces`
- **Always separated by `/`** even if empty
- Count notation: `3P` means three `P` pieces
- **Base form only**: No special modifiers allowed here

**Examples:**

```ruby
"/"         # No pieces captured
"P/"        # First player has one P piece
"/p"        # Second player has one p piece
"2PK/3p"    # First player: 2 P's + 1 K, Second player: 3 p's
```

### Part 3: Turn Information

Shows whose turn it is and identifies the game types:

- Format: `ACTIVE_PLAYER/INACTIVE_PLAYER`
- **One must be uppercase, other lowercase**
- The uppercase/lowercase corresponds to piece ownership

**Examples:**

```ruby
"CHESS/chess" # CHESS player (uppercase pieces) to move
"shogi/SHOGI" # shogi player (lowercase pieces) to move
"GAME1/game2" # GAME1 player (uppercase pieces) to move (mixed game types)
```

## Complete API Reference

### Core Methods

#### `Feen.dump(**options)`

Converts position components into a FEEN string.

**Parameters:**
- `piece_placement:` [Array] - Nested array representing the board
- `pieces_in_hand:` [Array] - List of captured pieces (strings)
- `games_turn:` [Array] - Two-element array: [active_player, inactive_player]

**Returns:** String - FEEN notation

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
  games_turn:      ["WHITE", "black"]
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
- `:games_turn` - [active_player, inactive_player]

**Example:**

```ruby
position = Feen.parse("rnknr/5/PPPPP Q/p WHITE/black")

position[:piece_placement]
# => [["r", "n", "k", "n", "r"], ["", "", "", "", ""], ["P", "P", "P", "P", "P"]]

position[:pieces_in_hand]
# => ["Q", "p"]

position[:games_turn]
# => ["WHITE", "black"]
```

#### `Feen.safe_parse(feen_string)`

Like `parse()` but returns `nil` instead of raising exceptions for invalid input.

**Example:**

```ruby
# Valid input
result = Feen.safe_parse("k/K / GAME/game")
# => { piece_placement: [["k"], ["K"]], pieces_in_hand: [], games_turn: ["GAME", "game"] }

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
Feen.valid?("k/K P3K/ GAME/game") # => false (wrong piece order)
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
  games_turn:      ["PLAYERA", "playerb"]
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
  games_turn:      ["UP", "down"]
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
  games_turn:      ["GAME", "game"]
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
  games_turn:      ["FIRST", "second"]
)
# => "k/K 3PR/2p FIRST/second"
```

### Understanding Piece Sorting

Captured pieces are automatically sorted in canonical order:

1. **By quantity** (most frequent first)
2. **By letter** (alphabetical within same quantity)

```ruby
pieces = ["B", "B", "P", "P", "P", "R", "R"]
# Result: "3P2B2R/" (3P first, then 2B and 2R alphabetically)
```

## Advanced Features

### Special Piece States (On Board Only)

For games that need special piece states, use modifiers **only on the board**:

```ruby
board = [
  ["+P", "K", "-R"],  # Enhanced pawn, King, diminished rook
  ["N'", "", "B"]     # Knight with special state, empty, Bishop
]

# Note: Modifiers (+, -, ') are ONLY allowed on the board
# Pieces in hand must be in base form only
feen = Feen.dump(
  piece_placement: board,
  pieces_in_hand:  ["P", "R"],  # Base form only!
  games_turn:      ["GAME", "game"]
)

feen # => "+PK-R/N'1B PR/ GAME/game"
```

### Cross-Game Scenarios

FEEN can represent positions mixing different game systems:

```ruby
# FOO pieces vs bar pieces
mixed_feen = Feen.dump(
  piece_placement: ["K", "G", "k", "r"],  # Mixed piece types
  pieces_in_hand:  ["P", "g"],            # Captured from both sides
  games_turn:      ["bar", "FOO"]         # Different game systems
)

mixed_feen # => "KGkr P/g bar/FOO"
```

## Error Handling

### Common Errors and Solutions

```ruby
# ERROR: Wrong argument types
Feen.dump(
  piece_placement: "not an array",  # Must be Array
  pieces_in_hand:  "not an array",  # Must be Array
  games_turn:      "not an array"   # Must be Array[2]
)
# => ArgumentError

# ERROR: Modifiers in captured pieces
Feen.dump(
  piece_placement: [["K"]],
  pieces_in_hand:  ["+P"],          # Invalid: no modifiers allowed
  games_turn:      ["GAME", "game"]
)
# => ArgumentError

# ERROR: Same case in games_turn
Feen.dump(
  piece_placement: [["K"]],
  pieces_in_hand:  [],
  games_turn:      ["GAME", "ALSO"] # Must be different cases
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

### Save/Load Game State

```ruby
class GameState
  def save_position(board, captured, current_player, opponent)
    feen = Feen.dump(
      piece_placement: board,
      pieces_in_hand:  captured,
      games_turn:      [current_player, opponent]
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
      games_turn:      turn_info
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
# => { piece_placement: [["r", "k", "r"]], pieces_in_hand: [], games_turn: ["GAME", "game"] }
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
    games_turn:      turn
  )
rescue ArgumentError => e
  puts "FEEN creation failed: #{e.message}"
  nil
end
```

### 2. Use Consistent Naming

```ruby
# Good: Clear piece type distinctions
PLAYER_1_PIECES = %w[K Q R B N P]
PLAYER_2_PIECES = %w[k q r b n p]

# Good: Descriptive game identifiers
GAME_TYPES = {
  chess_white: "CHESS",
  chess_black: "chess",
  shogi_sente: "SHOGI",
  shogi_gote: "shogi"
}
```

### 3. Round-trip Validation

```ruby
def verify_feen_consistency(original_feen)
  # Parse and re-dump to check consistency
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

## Compatibility and Performance

- **Ruby Version**: >= 3.2.0
- **Thread Safety**: All operations are thread-safe
- **Memory**: Efficient array-based representation
- **Performance**: O(n) parsing and generation complexity

## Related Resources

- [FEEN Specification v1.0.0](https://sashite.dev/documents/feen/1.0.0/) - Complete format specification
- [PNN Specification v1.0.0](https://sashite.dev/documents/pnn/1.0.0/) - Piece notation details
- [GAN Specification v1.0.0](https://sashite.dev/documents/gan/1.0.0/) - Game-qualified identifiers

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sashite/feen.rb.

## License

The [gem](https://rubygems.org/gems/feen) is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This project is maintained by [Sashité](https://sashite.com/) — promoting chess variants and sharing the beauty of Chinese, Japanese, and Western chess cultures.
