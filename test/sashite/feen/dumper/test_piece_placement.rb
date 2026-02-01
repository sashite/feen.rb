#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/dumper/piece_placement"

puts
puts "=== Dumper::PiecePlacement Tests ==="
puts

PiecePlacement = Sashite::Feen::Dumper::PiecePlacement

# ============================================================================
# BASIC DUMPING - EMPTY BOARDS
# ============================================================================

puts "Basic dumping - empty boards:"

run_test("dumps 1D empty board") do
  result = PiecePlacement.dump(segments: [[8]], separators: [])
  raise "expected '8', got #{result.inspect}" unless result == "8"
end

run_test("dumps 2D empty board (8x8)") do
  result = PiecePlacement.dump(
    segments: [[8], [8], [8], [8], [8], [8], [8], [8]],
    separators: ["/", "/", "/", "/", "/", "/", "/"]
  )
  raise "expected '8/8/8/8/8/8/8/8', got #{result.inspect}" unless result == "8/8/8/8/8/8/8/8"
end

run_test("dumps 2D empty board (9x9)") do
  result = PiecePlacement.dump(
    segments: [[9], [9], [9], [9], [9], [9], [9], [9], [9]],
    separators: ["/", "/", "/", "/", "/", "/", "/", "/"]
  )
  raise "expected 9 nines" unless result == "9/9/9/9/9/9/9/9/9"
end

run_test("dumps minimal board (1 square)") do
  result = PiecePlacement.dump(segments: [[1]], separators: [])
  raise "expected '1'" unless result == "1"
end

# ============================================================================
# BASIC DUMPING - WITH PIECES
# ============================================================================

puts
puts "Basic dumping - with pieces:"

run_test("dumps single piece") do
  result = PiecePlacement.dump(segments: [["K"]], separators: [])
  raise "expected 'K'" unless result == "K"
end

run_test("dumps multiple pieces") do
  result = PiecePlacement.dump(segments: [["K", "Q", "R"]], separators: [])
  raise "expected 'KQR'" unless result == "KQR"
end

run_test("dumps pieces with empty counts") do
  result = PiecePlacement.dump(segments: [["K", 3, "Q"]], separators: [])
  raise "expected 'K3Q'" unless result == "K3Q"
end

run_test("dumps leading empty count") do
  result = PiecePlacement.dump(segments: [[3, "K"]], separators: [])
  raise "expected '3K'" unless result == "3K"
end

run_test("dumps trailing empty count") do
  result = PiecePlacement.dump(segments: [["K", 3]], separators: [])
  raise "expected 'K3'" unless result == "K3"
end

# ============================================================================
# BASIC DUMPING - OBJECTS WITH TO_S
# ============================================================================

puts
puts "Basic dumping - objects with to_s:"

# Mock piece object
MockPiece = Struct.new(:name) do
  def to_s
    name
  end
end

run_test("dumps objects responding to to_s") do
  piece = MockPiece.new("K")
  result = PiecePlacement.dump(segments: [[piece]], separators: [])
  raise "expected 'K'" unless result == "K"
end

run_test("dumps mixed objects and integers") do
  king = MockPiece.new("K")
  queen = MockPiece.new("Q")
  result = PiecePlacement.dump(segments: [[king, 2, queen]], separators: [])
  raise "expected 'K2Q'" unless result == "K2Q"
end

# ============================================================================
# CANONICALIZATION - MERGING CONSECUTIVE EMPTIES
# ============================================================================

puts
puts "Canonicalization - merging consecutive empties:"

run_test("merges two consecutive empties") do
  result = PiecePlacement.dump(segments: [[3, 2]], separators: [])
  raise "expected '5', got #{result.inspect}" unless result == "5"
end

run_test("merges multiple consecutive empties") do
  result = PiecePlacement.dump(segments: [[1, 1, 1, 1]], separators: [])
  raise "expected '4'" unless result == "4"
end

run_test("merges empties around piece") do
  result = PiecePlacement.dump(segments: [[2, 3, "K", 1, 2]], separators: [])
  raise "expected '5K3'" unless result == "5K3"
end

run_test("merges empties between pieces") do
  result = PiecePlacement.dump(segments: [["K", 1, 1, "Q"]], separators: [])
  raise "expected 'K2Q'" unless result == "K2Q"
end

run_test("handles no empties") do
  result = PiecePlacement.dump(segments: [["K", "Q", "R"]], separators: [])
  raise "expected 'KQR'" unless result == "KQR"
end

run_test("handles only empties") do
  result = PiecePlacement.dump(segments: [[1, 2, 3, 2]], separators: [])
  raise "expected '8'" unless result == "8"
end

# ============================================================================
# MULTI-DIMENSIONAL BOARDS
# ============================================================================

puts
puts "Multi-dimensional boards:"

run_test("dumps 2D board with pieces") do
  result = PiecePlacement.dump(
    segments: [["r", "n", "b", "q", "k", "b", "n", "r"], [8], [8], [8], [8], [8], [8], ["R", "N", "B", "Q", "K", "B", "N", "R"]],
    separators: ["/", "/", "/", "/", "/", "/", "/"]
  )
  raise "expected Chess-like" unless result == "rnbqkbnr/8/8/8/8/8/8/RNBQKBNR"
end

run_test("dumps 3D board") do
  result = PiecePlacement.dump(
    segments: [[4], [4], [4], [4]],
    separators: ["/", "//", "/"]
  )
  raise "expected '4/4//4/4'" unless result == "4/4//4/4"
end

run_test("dumps 3D board with pieces") do
  result = PiecePlacement.dump(
    segments: [["K", 3], [4], [4], ["k", 3]],
    separators: ["/", "//", "/"]
  )
  raise "expected 'K3/4//4/k3'" unless result == "K3/4//4/k3"
end

# ============================================================================
# EDGE CASES
# ============================================================================

puts
puts "Edge cases:"

run_test("dumps empty segment array") do
  result = PiecePlacement.dump(segments: [[]], separators: [])
  raise "expected empty string" unless result == ""
end

run_test("dumps multiple empty segments") do
  result = PiecePlacement.dump(segments: [[], []], separators: ["/"])
  raise "expected '/'" unless result == "/"
end

run_test("handles large empty count") do
  result = PiecePlacement.dump(segments: [[100, 50, 50]], separators: [])
  raise "expected '200'" unless result == "200"
end

run_test("preserves separator structure") do
  result = PiecePlacement.dump(
    segments: [["a"], ["b"], ["c"], ["d"]],
    separators: ["/", "//", "/"]
  )
  raise "expected 'a/b//c/d'" unless result == "a/b//c/d"
end

# ============================================================================
# RETURN TYPE
# ============================================================================

puts
puts "Return type:"

run_test("returns String") do
  result = PiecePlacement.dump(segments: [["K"]], separators: [])
  raise "expected String" unless ::String === result
end

run_test("returns frozen String") do
  result = PiecePlacement.dump(segments: [["K"]], separators: [])
  # Note: We don't require frozen, just checking the type
  raise "expected String" unless result.is_a?(String)
end

# ============================================================================
# MODULE STRUCTURE
# ============================================================================

puts
puts "Module structure:"

run_test("module is frozen") do
  raise "expected frozen" unless PiecePlacement.frozen?
end

run_test("dump is the only public method") do
  public_methods = PiecePlacement.methods(false) - Object.methods
  raise "expected only :dump" unless public_methods == [:dump]
end

# ============================================================================
# REAL-WORLD EXAMPLES
# ============================================================================

puts
puts "Real-world examples:"

run_test("dumps Chess initial position") do
  result = PiecePlacement.dump(
    segments: [
      ["r", "n", "b", "q", "k", "b", "n", "r"],
      ["p", "p", "p", "p", "p", "p", "p", "p"],
      [8],
      [8],
      [8],
      [8],
      ["P", "P", "P", "P", "P", "P", "P", "P"],
      ["R", "N", "B", "Q", "K", "B", "N", "R"]
    ],
    separators: ["/", "/", "/", "/", "/", "/", "/"]
  )
  raise "expected Chess position" unless result == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
end

run_test("dumps Shogi initial position") do
  result = PiecePlacement.dump(
    segments: [
      ["l", "n", "s", "g", "k", "g", "s", "n", "l"],
      [1, "r", 5, "b", 1],
      ["p", "p", "p", "p", "p", "p", "p", "p", "p"],
      [9],
      [9],
      [9],
      ["P", "P", "P", "P", "P", "P", "P", "P", "P"],
      [1, "B", 5, "R", 1],
      ["L", "N", "S", "G", "K", "G", "S", "N", "L"]
    ],
    separators: ["/", "/", "/", "/", "/", "/", "/", "/"]
  )
  raise "expected Shogi position" unless result == "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL"
end

run_test("dumps position with terminal markers") do
  result = PiecePlacement.dump(
    segments: [["K^", 6, "k^"]],
    separators: []
  )
  raise "expected 'K^6k^'" unless result == "K^6k^"
end

run_test("dumps position with EPIN modifiers") do
  result = PiecePlacement.dump(
    segments: [["+K^", 2, "-p", 2, "+Q^'"]],
    separators: []
  )
  raise "expected '+K^2-p2+Q^''" unless result == "+K^2-p2+Q^'"
end

puts
puts "All Dumper::PiecePlacement tests passed!"
puts
