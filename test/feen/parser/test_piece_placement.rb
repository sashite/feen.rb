# frozen_string_literal: true

require_relative "../../../lib/feen/parser/piece_placement"

# Helper method for assertions
def assert_equal(expected, actual, message = "")
  raise "#{message}\nExpected: #{expected.inspect}\nActual: #{actual.inspect}" unless expected == actual
end

def assert_raises(exception_class, message_pattern = nil)
  yield
  raise "Expected #{exception_class} to be raised"
rescue exception_class => e
  if message_pattern && !e.message.match?(message_pattern)
    raise "Expected error message to match #{message_pattern.inspect}, got: #{e.message}"
  end

  e
end

# ==========================================================================
# Basic parsing tests
# ==========================================================================

# Test simple rank with pieces
result = Feen::Parser::PiecePlacement.parse("rnbqkbnr")
expected = ["r", "n", "b", "q", "k", "b", "n", "r"]
assert_equal(expected, result)

# Test rank with empty squares
result = Feen::Parser::PiecePlacement.parse("r2qk2r")
expected = ["r", "", "", "q", "k", "", "", "r"]
assert_equal(expected, result)

# Test multiple ranks (standard chess starting position) - uniform 8x8
result = Feen::Parser::PiecePlacement.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
expected = [
  ["r", "n", "b", "q", "k", "b", "n", "r"],
  ["p", "p", "p", "p", "p", "p", "p", "p"],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["P", "P", "P", "P", "P", "P", "P", "P"],
  ["R", "N", "B", "Q", "K", "B", "N", "R"]
]
assert_equal(expected, result)

# ==========================================================================
# Shape validation tests
# ==========================================================================

# Test shape validation - inconsistent rank sizes
assert_raises(ArgumentError, /Inconsistent rank size/) do
  Feen::Parser::PiecePlacement.parse("rnbqkbnr/ppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR") # 7 pawns vs 8
end

# Test shape validation - inconsistent dimension sizes
assert_raises(ArgumentError, /Mixed separator depths/) do
  Feen::Parser::PiecePlacement.parse("kp/qr//KP") # Mixed separator depths (/ and //)
end

# ==========================================================================
# Piece format tests
# ==========================================================================

# Test pieces with prefixes
result = Feen::Parser::PiecePlacement.parse("+P-b")
expected = ["+P", "-b"]
assert_equal(expected, result)

# Test pieces with suffixes
result = Feen::Parser::PiecePlacement.parse("K=P>p<")
expected = ["K=", "P>", "p<"]
assert_equal(expected, result)

# Test pieces with both prefix and suffix
result = Feen::Parser::PiecePlacement.parse("+B=-P>")
expected = ["+B=", "-P>"]
assert_equal(expected, result)

# ==========================================================================
# Multi-dimensional board tests
# ==========================================================================

# Test multi-dimensional board (3D example) - uniform shape
result = Feen::Parser::PiecePlacement.parse("r2/k2//P2/K2")
expected = [
  [["r", "", ""], ["k", "", ""]],
  [["P", "", ""], ["K", "", ""]]
]
assert_equal(expected, result)

# Test invalid multi-dimensional structure - inconsistent sizes
assert_raises(ArgumentError, /Inconsistent rank size/) do
  Feen::Parser::PiecePlacement.parse("ab/cd///12/345") # "ab","cd" have 2 cells but "345" has 3
end

# ==========================================================================
# Edge case tests
# ==========================================================================

# Test edge case: single piece
result = Feen::Parser::PiecePlacement.parse("K")
expected = ["K"]
assert_equal(expected, result)

# Test edge case: single empty square
result = Feen::Parser::PiecePlacement.parse("1")
expected = [""]
assert_equal(expected, result)

# Test edge case: large number of empty squares
result = Feen::Parser::PiecePlacement.parse("15")
expected = [""] * 15
assert_equal(expected, result)

# ==========================================================================
# Input validation tests
# ==========================================================================

# Test invalid input: not a string
assert_raises(ArgumentError, /must be a string/) do
  Feen::Parser::PiecePlacement.parse(nil)
end

assert_raises(ArgumentError, /must be a string/) do
  Feen::Parser::PiecePlacement.parse(123)
end

# Test invalid input: empty string
assert_raises(ArgumentError, /cannot be empty/) do
  Feen::Parser::PiecePlacement.parse("")
end

# Test invalid characters
assert_raises(ArgumentError, /Invalid piece placement format/) do
  Feen::Parser::PiecePlacement.parse("K@Q")
end

assert_raises(ArgumentError, /Invalid piece placement format/) do
  Feen::Parser::PiecePlacement.parse("K Q")
end

# Test invalid prefix
assert_raises(ArgumentError, /Invalid piece placement format/) do
  Feen::Parser::PiecePlacement.parse("*K")
end

# Test invalid suffix
assert_raises(ArgumentError, /Invalid piece placement format/) do
  Feen::Parser::PiecePlacement.parse("K!")
end

# Test prefix without piece
assert_raises(ArgumentError, /Invalid piece placement format/) do
  Feen::Parser::PiecePlacement.parse("+")
end

# Test trailing separator
assert_raises(ArgumentError, /Invalid piece placement format/) do
  Feen::Parser::PiecePlacement.parse("K/")
end

assert_raises(ArgumentError, /Invalid piece placement format/) do
  Feen::Parser::PiecePlacement.parse("K/Q//")
end

# Test number starting with zero
assert_raises(ArgumentError, /Invalid piece placement format/) do
  Feen::Parser::PiecePlacement.parse("K01Q")
end

# ==========================================================================
# Complex valid cases
# ==========================================================================

# Test complex valid cases with all features
result = Feen::Parser::PiecePlacement.parse("rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR")
assert_equal(8, result.length)
assert_equal("k=", result[0][4])
assert_equal("K=", result[7][4])

# Test consistent board shapes
result = Feen::Parser::PiecePlacement.parse("r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R")
assert_equal(8, result.length)
result.each do |rank|
  assert_equal(8, rank.length, "All ranks should have 8 cells")
end

# Test shogi position with consistent 9x9 board
result = Feen::Parser::PiecePlacement.parse("lnsgk3l/5g3/p1ppB2pp/9/8B/2P6/P2PPPPPP/3K3R1/5rSNL")
assert_equal(9, result.length)
result.each do |rank|
  assert_equal(9, rank.length, "All ranks should have 9 cells")
end

# Test xiangqi position with consistent 10x9 board (10 ranks, 9 files)
result = Feen::Parser::PiecePlacement.parse("rheagaehr/9/1c5c1/s1s1s1s1s/9/9/S1S1S1S1S/1C5C1/9/RHEAGAEHR")
assert_equal(10, result.length, "Xiangqi board should have 10 ranks")
result.each do |rank|
  assert_equal(9, rank.length, "Each rank should have 9 cells")
end
# Verify specific pieces in the Xiangqi starting position
assert_equal("r", result[0][0])
assert_equal("r", result[0][8])
assert_equal("a", result[0][3])
assert_equal("a", result[0][5])
assert_equal("c", result[2][1])
assert_equal("c", result[2][7])
assert_equal("s", result[3][0])
assert_equal("s", result[3][8])

# ==========================================================================
# Additional shape validation tests
# ==========================================================================

# Test 4x4 board
result = Feen::Parser::PiecePlacement.parse("4/4/4/4")
assert_equal(4, result.length)
result.each do |rank|
  assert_equal(4, rank.length)
end

# Test 4x8 board (rectangular)
result = Feen::Parser::PiecePlacement.parse("8/8/8/8")
assert_equal(4, result.length, "Should have 4 ranks")
result.each do |rank|
  assert_equal(8, rank.length, "Each rank should have 8 cells")
end

# Test 7x7 board (square)
result = Feen::Parser::PiecePlacement.parse("7/7/7/7/7/7/7")
assert_equal(7, result.length, "Should have 7 ranks")
result.each do |rank|
  assert_equal(7, rank.length, "Each rank should have 7 cells")
end

# Test 5x5x5 cube
result = Feen::Parser::PiecePlacement.parse("5/5/5/5/5//5/5/5/5/5//5/5/5/5/5//5/5/5/5/5//5/5/5/5/5")
assert_equal(5, result.length, "Should have 5 planes")
result.each do |plane|
  assert_equal(5, plane.length, "Each plane should have 5 ranks")
  plane.each do |rank|
    assert_equal(5, rank.length, "Each rank should have 5 cells")
  end
end

# Test complex but valid nested structure with mixed separator depths
result = Feen::Parser::PiecePlacement.parse("ab/cd//ef/gh///ij/kl//mn/op")
expected = [
  [
    [["a", "b"], ["c", "d"]],
    [["e", "f"], ["g", "h"]]
  ],
  [
    [["i", "j"], ["k", "l"]],
    [["m", "n"], ["o", "p"]]
  ]
]
assert_equal(expected, result)

# ==========================================================================
# Shape validation failure cases
# ==========================================================================

# Test shape validation failure - inconsistent rank sizes
assert_raises(ArgumentError, /Inconsistent rank size/) do
  Feen::Parser::PiecePlacement.parse("8/7/8/8") # Inconsistent 2D shape
end

# Test shape validation failure - inconsistent dimensions
assert_raises(ArgumentError, /Inconsistent rank size/) do
  Feen::Parser::PiecePlacement.parse("3/3/3//3/3//3/3/3") # Inconsistent 3D shape (3-2-3)
end

# ==========================================================================
# New separator inconsistency tests
# ==========================================================================

# Test mixed separator depths at the same level (generic case)
assert_raises(ArgumentError, /Mixed separator depths/) do
  Feen::Parser::PiecePlacement.parse("ab/cd//ef")
end

# Test mixed separator depths in a more complex structure
assert_raises(ArgumentError, /Mixed separator depths/) do
  Feen::Parser::PiecePlacement.parse("ab/cd///ef//gh")
end

# Test mixed separator depths in multiple segments
assert_raises(ArgumentError, /Mixed separator depths/) do
  Feen::Parser::PiecePlacement.parse("ab/cd//ef///gh/ij//kl")
end

# Our specific problematic case
assert_raises(ArgumentError, /Mixed separator depths/) do
  Feen::Parser::PiecePlacement.parse("kp/qr//KP")
end

# Test valid but complex multi-dimensional structure
result = Feen::Parser::PiecePlacement.parse("ab/cd//ef/gh//ij/kl")
expected = [
  [["a", "b"], ["c", "d"]],
  [["e", "f"], ["g", "h"]],
  [["i", "j"], ["k", "l"]]
]
assert_equal(expected, result)

# Test deeply nested structure
result = Feen::Parser::PiecePlacement.parse("ab/cd///ef/gh///ij/kl///mn/op")
expected = [
  [["a", "b"], ["c", "d"]],
  [["e", "f"], ["g", "h"]],
  [["i", "j"], ["k", "l"]],
  [["m", "n"], ["o", "p"]]
]
assert_equal(expected, result, "La structure 4D devrait être analysée correctement")

puts "✅ All PiecePlacement parse tests passed."
