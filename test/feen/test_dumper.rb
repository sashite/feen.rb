# frozen_string_literal: true

require_relative "../../lib/feen/dumper"

# File: test/feen/test_dumper.rb

# --- Tests for valid cases ---

# Test 1: Initial chess position
piece_placement = [
  ["r", "n", "b", "q", "k", "b", "n", "r"],
  ["p", "p", "p", "p", "p", "p", "p", "p"],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["P", "P", "P", "P", "P", "P", "P", "P"],
  ["R", "N", "B", "Q", "K", "B", "N", "R"]
]
games_turn = %w[CHESS chess]
pieces_in_hand = []

result = Feen::Dumper.dump(
  piece_placement: piece_placement,
  games_turn:      games_turn,
  pieces_in_hand:  pieces_in_hand
)
expected = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / CHESS/chess"
raise "Test 1 failed: expected #{expected}, got #{result}" unless result == expected

# Test 2: Shogi position with pieces in hand
piece_placement = [
  ["l", "n", "s", "g", "k", "", "", "n", "l"],
  ["", "r", "", "", "", "", "g", "s", ""],
  ["p", "", "p", "p", "p", "p", "", "p", "p"],
  ["", "p", "", "", "", "", "p", "", ""],
  ["", "", "", "", "", "", "", "P", ""],
  ["", "", "P", "", "", "", "", "", ""],
  ["P", "P", "", "P", "P", "P", "P", "", "P"],
  ["", "S", "G", "", "", "", "", "R", ""],
  ["L", "N", "", "", "K", "G", "S", "N", "L"]
]
games_turn = %w[SHOGI shogi]
pieces_in_hand = %w[B b]

result = Feen::Dumper.dump(
  piece_placement: piece_placement,
  games_turn:      games_turn,
  pieces_in_hand:  pieces_in_hand
)
expected = "lnsgk2nl/1r4gs1/p1pppp1pp/1p4p2/7P1/2P6/PP1PPPP1P/1SG4R1/LN2KGSNL B/b SHOGI/shogi"
raise "Test 2 failed: expected #{expected}, got #{result}" unless result == expected

# Test 3: Chess position with black to move
piece_placement = [
  ["r", "n", "b", "q", "k", "b", "n", "r"],
  ["p", "p", "p", "p", "p", "p", "p", "p"],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["P", "P", "P", "P", "P", "P", "P", "P"],
  ["R", "N", "B", "Q", "K", "B", "N", "R"]
]
games_turn = %w[chess CHESS]
pieces_in_hand = []

result = Feen::Dumper.dump(
  piece_placement: piece_placement,
  games_turn:      games_turn,
  pieces_in_hand:  pieces_in_hand
)
expected = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / chess/CHESS"
raise "Test 3 failed: expected #{expected}, got #{result}" unless result == expected

# Test 4: Xiangqi position
piece_placement = [
  ["r", "h", "e", "a", "g", "a", "e", "h", "r"],
  ["", "", "", "", "", "", "", "", ""],
  ["", "c", "", "", "", "", "", "c", ""],
  ["s", "", "s", "", "s", "", "s", "", "s"],
  ["", "", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", "", ""],
  ["S", "", "S", "", "S", "", "S", "", "S"],
  ["", "C", "", "", "", "", "", "C", ""],
  ["", "", "", "", "", "", "", "", ""],
  ["R", "H", "E", "A", "G", "A", "E", "H", "R"]
]
games_turn = %w[XIANGQI xiangqi]
pieces_in_hand = []

result = Feen::Dumper.dump(
  piece_placement: piece_placement,
  games_turn:      games_turn,
  pieces_in_hand:  pieces_in_hand
)
expected = "rheagaehr/9/1c5c1/s1s1s1s1s/9/9/S1S1S1S1S/1C5C1/9/RHEAGAEHR / XIANGQI/xiangqi"
raise "Test 4 failed: expected #{expected}, got #{result}" unless result == expected

# Test 5: Chess position with modified pieces (prefix/suffix)
piece_placement = [
  ["r", "n", "b", "q", "k<", "b", "n", "r"],
  ["p", "p", "p", "p", "p", "p", "p", "p"],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "+P", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["P", "P", "P", "P", "", "P", "P", "P"],
  ["R", "N", "B", "Q", "K>", "B", "N", "R"]
]
games_turn = %w[CHESS chess]
pieces_in_hand = []

result = Feen::Dumper.dump(
  piece_placement: piece_placement,
  games_turn:      games_turn,
  pieces_in_hand:  pieces_in_hand
)
expected = "rnbqk<bnr/pppppppp/8/4+P3/8/8/PPPP1PPP/RNBQK>BNR / CHESS/chess"
raise "Test 5 failed: expected #{expected}, got #{result}" unless result == expected

# Test 6: 3D structure
piece_placement = [
  [
    %w[r n b],
    %w[q k p]
  ],
  [
    ["P", "R", ""],
    ["", "K", "Q"]
  ]
]
games_turn = %w[FOO bar]
pieces_in_hand = []

result = Feen::Dumper.dump(
  piece_placement: piece_placement,
  games_turn:      games_turn,
  pieces_in_hand:  pieces_in_hand
)
expected = "rnb/qkp//PR1/1KQ / FOO/bar"
raise "Test 6 failed: expected #{expected}, got #{result}" unless result == expected

# Test 7: Position with many pieces in hand
piece_placement = [
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""]
]
games_turn = %w[CHESS chess]
pieces_in_hand = %w[
  A B C D E F G H I J K L M
  N O P Q R S T U V W X Y Z
  a b c d e f g h i j k l m
  n o p q r s t u v w x y z
]

result = Feen::Dumper.dump(
  piece_placement: piece_placement,
  games_turn:      games_turn,
  pieces_in_hand:  pieces_in_hand
)
expected = "8/8/8/8/8/8/8/8 ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz CHESS/chess"
raise "Test 7 failed: expected #{expected}, got #{result}" unless result == expected

# Test 8: Empty board with no pieces in hand
piece_placement = [
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""]
]
games_turn = %w[CHESS chess]
pieces_in_hand = []

result = Feen::Dumper.dump(
  piece_placement: piece_placement,
  games_turn:      games_turn,
  pieces_in_hand:  pieces_in_hand
)
expected = "8/8/8/8/8/8/8/8 / CHESS/chess"
raise "Test 8 failed: expected #{expected}, got #{result}" unless result == expected

# --- Tests for error cases ---

# Test 9: Non-array piece placement
begin
  Feen::Dumper.dump(
    piece_placement: "invalid",
    games_turn:      %w[CHESS chess],
    pieces_in_hand:  []
  )
  raise "Test 9 failed: should have raised ArgumentError for non-array piece placement"
rescue ArgumentError
  # Expected behavior
end

# Test 10: Non-array games turn
begin
  Feen::Dumper.dump(
    piece_placement: [[""]],
    games_turn:      "invalid",
    pieces_in_hand:  []
  )
  raise "Test 10 failed: should have raised ArgumentError for non-array games turn"
rescue ArgumentError
  # Expected behavior
end

# Test 11: Games turn with wrong number of elements
begin
  Feen::Dumper.dump(
    piece_placement: [[""]],
    games_turn:      ["CHESS"],
    pieces_in_hand:  []
  )
  raise "Test 11 failed: should have raised ArgumentError for games turn with wrong size"
rescue ArgumentError
  # Expected behavior
end

begin
  Feen::Dumper.dump(
    piece_placement: [[""]],
    games_turn:      %w[CHESS chess extra],
    pieces_in_hand:  []
  )
  raise "Test 11 failed: should have raised ArgumentError for games turn with too many elements"
rescue ArgumentError
  # Expected behavior
end

# Test 12: Non-array pieces in hand
begin
  Feen::Dumper.dump(
    piece_placement: [[""]],
    games_turn:      %w[CHESS chess],
    pieces_in_hand:  "invalid"
  )
  raise "Test 12 failed: should have raised ArgumentError for non-array pieces in hand"
rescue ArgumentError
  # Expected behavior
end

# Test 13: Missing required parameters
begin
  Feen::Dumper.dump(
    games_turn:     %w[CHESS chess],
    pieces_in_hand: []
  )
  raise "Test 13 failed: should have raised ArgumentError for missing piece_placement"
rescue ArgumentError
  # Expected behavior
end

begin
  Feen::Dumper.dump(
    piece_placement: [[""]],
    pieces_in_hand:  []
  )
  raise "Test 13 failed: should have raised ArgumentError for missing games_turn"
rescue ArgumentError
  # Expected behavior
end

begin
  Feen::Dumper.dump(
    piece_placement: [[""]],
    games_turn:      %w[CHESS chess]
  )
  raise "Test 13 failed: should have raised ArgumentError for missing pieces_in_hand"
rescue ArgumentError
  # Expected behavior
end

# --- Edge case tests ---

# Test 14: Empty piece placement array
result = Feen::Dumper.dump(
  piece_placement: [],
  games_turn:      %w[CHESS chess],
  pieces_in_hand:  []
)
expected = " / CHESS/chess"
raise "Test 14 failed: expected #{expected}, got #{result}" unless result == expected

# Test 15: Game identifiers with different case requirements
begin
  Feen::Dumper.dump(
    piece_placement: [[""]],
    games_turn:      %w[chess chess],
    pieces_in_hand:  []
  )
  raise "Test 15 failed: should have raised ArgumentError for both lowercase game identifiers"
rescue ArgumentError
  # Expected behavior
end

begin
  Feen::Dumper.dump(
    piece_placement: [[""]],
    games_turn:      %w[CHESS CHESS],
    pieces_in_hand:  []
  )
  raise "Test 15 failed: should have raised ArgumentError for both uppercase game identifiers"
rescue ArgumentError
  # Expected behavior
end

# Test 16: Invalid characters in pieces in hand
begin
  Feen::Dumper.dump(
    piece_placement: [[""]],
    games_turn:      %w[CHESS chess],
    pieces_in_hand:  %w[1 2] # Only a-zA-Z allowed
  )
  raise "Test 16 failed: should have raised ArgumentError for invalid piece characters"
rescue ArgumentError
  # Expected behavior
end

puts "All tests passed successfully!"
