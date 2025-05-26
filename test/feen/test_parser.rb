# frozen_string_literal: true

require_relative "../../lib/feen/parser"

# File: test/feen/test_parser.rb

# --- Tests for valid cases ---

# Test 1: Initial chess position
result = Feen::Parser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess")
expected = {
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
  games_turn:      %w[CHESS chess],
  pieces_in_hand:  []
}
raise "Test 1 failed" unless result == expected

# Test 2: Shogi position with pieces in hand
result = Feen::Parser.parse("lnsgk2nl/1r4gs1/p1pppp1pp/1p4p2/7P1/2P6/PP1PPPP1P/1SG4R1/LN2KGSNL Bb SHOGI/shogi")
expected = {
  piece_placement: [
    ["l", "n", "s", "g", "k", "", "", "n", "l"],
    ["", "r", "", "", "", "", "g", "s", ""],
    ["p", "", "p", "p", "p", "p", "", "p", "p"],
    ["", "p", "", "", "", "", "p", "", ""],
    ["", "", "", "", "", "", "", "P", ""],
    ["", "", "P", "", "", "", "", "", ""],
    ["P", "P", "", "P", "P", "P", "P", "", "P"],
    ["", "S", "G", "", "", "", "", "R", ""],
    ["L", "N", "", "", "K", "G", "S", "N", "L"]
  ],
  games_turn:      %w[SHOGI shogi],
  pieces_in_hand:  %w[B b]
}
raise "Test 2 failed" unless result == expected

# Test 3: Chess position with black to move
result = Feen::Parser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - chess/CHESS")
expected = {
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
  games_turn:      %w[chess CHESS],
  pieces_in_hand:  []
}
raise "Test 3 failed" unless result == expected

# Test 4: Xiangqi position
result = Feen::Parser.parse("rheagaehr/9/1c5c1/s1s1s1s1s/9/9/S1S1S1S1S/1C5C1/9/RHEAGAEHR - XIANGQI/xiangqi")
expected = {
  piece_placement: [
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
  ],
  games_turn:      %w[XIANGQI xiangqi],
  pieces_in_hand:  []
}
raise "Test 4 failed" unless result == expected

# Test 5: Chess position with modified pieces (prefix/suffix)
result = Feen::Parser.parse("rnbqkbnr/pppppppp/8/4+P3/8/8/PPPP1PPP/RNBQKBNR - CHESS/chess")
expected = {
  piece_placement: [
    ["r", "n", "b", "q", "k", "b", "n", "r"],
    ["p", "p", "p", "p", "p", "p", "p", "p"],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "+P", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["P", "P", "P", "P", "", "P", "P", "P"],
    ["R", "N", "B", "Q", "K", "B", "N", "R"]
  ],
  games_turn:      %w[CHESS chess],
  pieces_in_hand:  []
}
raise "Test 5 failed" unless result == expected

# Test 6: 3D structure
result = Feen::Parser.parse("rnb/qkp//PR1/1KQ - FOO/bar")
expected = {
  piece_placement: [
    [
      %w[r n b],
      %w[q k p]
    ],
    [
      ["P", "R", ""],
      ["", "K", "Q"]
    ]
  ],
  games_turn:      %w[FOO bar],
  pieces_in_hand:  []
}
raise "Test 6 failed" unless result == expected

# Test 7: Position with many pieces in hand
result = Feen::Parser.parse("8/8/8/8/8/8/8/8 ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz CHESS/chess")
expected = {
  piece_placement: [
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""]
  ],
  games_turn:      %w[CHESS chess],
  pieces_in_hand:  %w[
    A B C D E F G H I J K L M
    N O P Q R S T U V W X Y Z
    a b c d e f g h i j k l m
    n o p q r s t u v w x y z
  ]
}
raise "Test 7 failed" unless result == expected

# --- Tests for error cases ---

# Test 8: Empty string
begin
  Feen::Parser.parse("")
  raise "Test 8 failed: should have raised ArgumentError for empty string"
rescue ArgumentError
  # Expected behavior
end

# Test 9: Nil passed as argument
begin
  Feen::Parser.parse(nil)
  raise "Test 9 failed: should have raised ArgumentError for nil input"
rescue ArgumentError
  # Expected behavior
end

# Test 10: Too few parts (missing one)
begin
  Feen::Parser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR -")
  raise "Test 10 failed: should have raised ArgumentError for missing field"
rescue ArgumentError
  # Expected behavior
end

# Test 11: Too many parts (extra one)
begin
  Feen::Parser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess extra")
  raise "Test 11 failed: should have raised ArgumentError for extra field"
rescue ArgumentError
  # Expected behavior
end

# Test 12: Multiple spaces between parts
begin
  Feen::Parser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR  - CHESS/chess")
  raise "Test 12 failed: should have raised ArgumentError for multiple spaces"
rescue ArgumentError
  # Expected behavior
end

# Test 13: Spaces at the beginning or end
begin
  Feen::Parser.parse(" rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess")
  raise "Test 13 failed: should have raised ArgumentError for leading space"
rescue ArgumentError
  # Expected behavior
end

begin
  Feen::Parser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess ")
  raise "Test 13 failed: should have raised ArgumentError for trailing space"
rescue ArgumentError
  # Expected behavior
end

# Test 14: Invalid piece placement
begin
  Feen::Parser.parse("rnbqkbnrx/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess")
  raise "Test 14 failed: should have raised ArgumentError for invalid piece placement"
rescue ArgumentError
  # Expected behavior
end

# Test 15: Invalid games turn format
begin
  Feen::Parser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESSxchess")
  raise "Test 15 failed: should have raised ArgumentError for invalid games turn format"
rescue ArgumentError
  # Expected behavior
end

begin
  Feen::Parser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/CHESS")
  raise "Test 15 failed: should have raised ArgumentError for both uppercase games"
rescue ArgumentError
  # Expected behavior
end

begin
  Feen::Parser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - chess/chess")
  raise "Test 15 failed: should have raised ArgumentError for both lowercase games"
rescue ArgumentError
  # Expected behavior
end

# Test 16: Invalid pieces in hand format
begin
  Feen::Parser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR 123 CHESS/chess")
  raise "Test 16 failed: should have raised ArgumentError for invalid pieces in hand"
rescue ArgumentError
  # Expected behavior
end

# Test 17: Unsorted pieces in hand
begin
  Feen::Parser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR ba CHESS/chess")
  raise "Test 17 failed: should have raised ArgumentError for unsorted pieces in hand"
rescue ArgumentError
  # Expected behavior
end

# Test 18: Testing safe_parse with invalid input (should return nil)
result = Feen::Parser.safe_parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR ba CHESS/chess")
expected = nil
raise "Test 18 failed: safe_parse should return nil for invalid input" unless result == expected

# Test 19: Testing safe_parse with valid input (should return same as parse)
result_safe = Feen::Parser.safe_parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess")
result_normal = Feen::Parser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess")
unless result_safe == result_normal
  raise "Test 19 failed: safe_parse should return the same result as parse for valid inputs"
end

# Test 20: Testing safe_parse with type conversion (Symbol to String)
result = Feen::Parser.safe_parse(:"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR - CHESS/chess")
raise "Test 20 failed: safe_parse should handle Symbol conversion" unless result == result_normal

puts "All tests passed successfully!"
