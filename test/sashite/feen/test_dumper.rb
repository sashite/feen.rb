#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../helper"
require_relative "../../../lib/sashite/feen/dumper"

puts
puts "=== Dumper Tests ==="
puts

Dumper = Sashite::Feen::Dumper

# ============================================================================
# BASIC DUMPING - MINIMAL POSITIONS
# ============================================================================

puts "Basic dumping - minimal positions:"

run_test("dumps minimal position") do
  result = Dumper.dump(
    piece_placement: { segments: [["K"]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: "C", inactive: "c" }
  )
  raise "expected 'K / C/c', got #{result.inspect}" unless result == "K / C/c"
end

run_test("dumps empty board position") do
  result = Dumper.dump(
    piece_placement: { segments: [[8]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: "C", inactive: "c" }
  )
  raise "expected '8 / C/c', got #{result.inspect}" unless result == "8 / C/c"
end

# ============================================================================
# BASIC DUMPING - CHESS POSITIONS
# ============================================================================

puts
puts "Basic dumping - Chess positions:"

run_test("dumps Chess initial position") do
  result = Dumper.dump(
    piece_placement: {
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
    },
    hands: { first: [], second: [] },
    style_turn: { active: "C", inactive: "c" }
  )
  raise "expected Chess initial" unless result == "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
end

run_test("dumps Chess position with second to move") do
  result = Dumper.dump(
    piece_placement: { segments: [["K", 6, "k"]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: "c", inactive: "C" }
  )
  raise "expected 'K6k / c/C'" unless result == "K6k / c/C"
end

# ============================================================================
# BASIC DUMPING - SHOGI POSITIONS
# ============================================================================

puts
puts "Basic dumping - Shogi positions:"

run_test("dumps Shogi initial position") do
  result = Dumper.dump(
    piece_placement: {
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
    },
    hands: { first: [], second: [] },
    style_turn: { active: "S", inactive: "s" }
  )
  raise "expected Shogi initial" unless result == "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s"
end

run_test("dumps Shogi position with hands") do
  result = Dumper.dump(
    piece_placement: {
      segments: [[9], [9], [9], [9], [9], [9], [9], [9], [9]],
      separators: ["/", "/", "/", "/", "/", "/", "/", "/"]
    },
    hands: {
      first: [{ piece: "P", count: 3 }, { piece: "L", count: 2 }],
      second: [{ piece: "p", count: 2 }]
    },
    style_turn: { active: "S", inactive: "s" }
  )
  raise "expected Shogi with hands" unless result == "9/9/9/9/9/9/9/9/9 3P2L/2p S/s"
end

# ============================================================================
# POSITIONS WITH HANDS
# ============================================================================

puts
puts "Positions with hands:"

run_test("dumps position with first hand only") do
  result = Dumper.dump(
    piece_placement: { segments: [[8]], separators: [] },
    hands: {
      first: [{ piece: "P", count: 2 }],
      second: []
    },
    style_turn: { active: "C", inactive: "c" }
  )
  raise "expected '8 2P/ C/c'" unless result == "8 2P/ C/c"
end

run_test("dumps position with second hand only") do
  result = Dumper.dump(
    piece_placement: { segments: [[8]], separators: [] },
    hands: {
      first: [],
      second: [{ piece: "n", count: 1 }]
    },
    style_turn: { active: "C", inactive: "c" }
  )
  raise "expected '8 /n C/c'" unless result == "8 /n C/c"
end

run_test("dumps position with both hands") do
  result = Dumper.dump(
    piece_placement: { segments: [[8]], separators: [] },
    hands: {
      first: [{ piece: "B", count: 3 }, { piece: "N", count: 1 }],
      second: [{ piece: "q", count: 2 }]
    },
    style_turn: { active: "C", inactive: "c" }
  )
  raise "expected '8 3BN/2q C/c'" unless result == "8 3BN/2q C/c"
end

# ============================================================================
# MULTI-DIMENSIONAL BOARDS
# ============================================================================

puts
puts "Multi-dimensional boards:"

run_test("dumps 1D board") do
  result = Dumper.dump(
    piece_placement: { segments: [["K", 2, "Q", 3, "R"]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: "C", inactive: "c" }
  )
  raise "expected 'K2Q3R / C/c'" unless result == "K2Q3R / C/c"
end

run_test("dumps 3D board") do
  result = Dumper.dump(
    piece_placement: {
      segments: [[4], [4], [4], [4]],
      separators: ["/", "//", "/"]
    },
    hands: { first: [], second: [] },
    style_turn: { active: "C", inactive: "c" }
  )
  raise "expected '4/4//4/4 / C/c'" unless result == "4/4//4/4 / C/c"
end

# ============================================================================
# CROSS-STYLE GAMES
# ============================================================================

puts
puts "Cross-style games:"

run_test("dumps Chess vs Shogi") do
  result = Dumper.dump(
    piece_placement: { segments: [["K", 6, "k"]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: "C", inactive: "s" }
  )
  raise "expected 'K6k / C/s'" unless result == "K6k / C/s"
end

run_test("dumps Xiangqi vs Go") do
  result = Dumper.dump(
    piece_placement: { segments: [[9]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: "X", inactive: "g" }
  )
  raise "expected '9 / X/g'" unless result == "9 / X/g"
end

# ============================================================================
# CANONICALIZATION
# ============================================================================

puts
puts "Canonicalization:"

run_test("canonicalizes consecutive empty counts") do
  result = Dumper.dump(
    piece_placement: { segments: [[2, 3, "K", 1, 2]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: "C", inactive: "c" }
  )
  raise "expected '5K3 / C/c' (merged empties)" unless result == "5K3 / C/c"
end

# ============================================================================
# RETURN TYPE
# ============================================================================

puts
puts "Return type:"

run_test("returns String") do
  result = Dumper.dump(
    piece_placement: { segments: [["K"]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: "C", inactive: "c" }
  )
  raise "expected String" unless ::String === result
end

# ============================================================================
# MODULE STRUCTURE
# ============================================================================

puts
puts "Module structure:"

run_test("module is frozen") do
  raise "expected frozen" unless Dumper.frozen?
end

run_test("dump is the only public method") do
  public_methods = Dumper.methods(false) - Object.methods
  raise "expected only :dump, got #{public_methods}" unless public_methods == [:dump]
end

run_test("sub-modules are accessible") do
  raise "missing PiecePlacement" unless defined?(Dumper::PiecePlacement)
  raise "missing Hands" unless defined?(Dumper::Hands)
  raise "missing StyleTurn" unless defined?(Dumper::StyleTurn)
end

# ============================================================================
# REAL-WORLD EXAMPLES
# ============================================================================

puts
puts "Real-world examples:"

run_test("dumps Xiangqi initial position") do
  result = Dumper.dump(
    piece_placement: {
      segments: [
        ["r", "h", "e", "a", "g", "a", "e", "h", "r"],
        [9],
        [1, "c", 5, "c", 1],
        ["p", 1, "p", 1, "p", 1, "p", 1, "p"],
        [9],
        [9],
        ["P", 1, "P", 1, "P", 1, "P", 1, "P"],
        [1, "C", 5, "C", 1],
        [9],
        ["R", "H", "E", "A", "G", "A", "E", "H", "R"]
      ],
      separators: ["/", "/", "/", "/", "/", "/", "/", "/", "/"]
    },
    hands: { first: [], second: [] },
    style_turn: { active: "X", inactive: "x" }
  )
  raise "expected Xiangqi initial" unless result == "rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x"
end

run_test("dumps Go empty board") do
  result = Dumper.dump(
    piece_placement: {
      segments: Array.new(19) { [19] },
      separators: Array.new(18) { "/" }
    },
    hands: { first: [], second: [] },
    style_turn: { active: "G", inactive: "g" }
  )
  expected = (["19"] * 19).join("/") + " / G/g"
  raise "expected Go 19x19 empty" unless result == expected
end

run_test("dumps Crazyhouse mid-game") do
  result = Dumper.dump(
    piece_placement: {
      segments: [[8], [8], [8], [8], [8], [8], [8], [8]],
      separators: ["/", "/", "/", "/", "/", "/", "/"]
    },
    hands: {
      first: [{ piece: "Q", count: 1 }, { piece: "P", count: 3 }],
      second: [{ piece: "n", count: 2 }, { piece: "p", count: 1 }]
    },
    style_turn: { active: "C", inactive: "c" }
  )
  raise "expected Crazyhouse" unless result == "8/8/8/8/8/8/8/8 Q3P/2np C/c"
end

puts
puts "All Dumper tests passed!"
puts
