#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/dumper/hand"

puts
puts "=== Dumper::Hand Tests ==="
puts

Hand = Sashite::Feen::Dumper::Hand

# ============================================================================
# BASIC DUMPING - EMPTY HAND
# ============================================================================

puts "Basic dumping - empty hand:"

run_test("dumps empty hand") do
  result = Hand.dump([])
  raise "expected empty string, got #{result.inspect}" unless result == ""
end

# ============================================================================
# BASIC DUMPING - SINGLE PIECES
# ============================================================================

puts
puts "Basic dumping - single pieces:"

run_test("dumps single piece with count 1") do
  result = Hand.dump([{ piece: "P", count: 1 }])
  raise "expected 'P', got #{result.inspect}" unless result == "P"
end

run_test("dumps single piece with count 2") do
  result = Hand.dump([{ piece: "P", count: 2 }])
  raise "expected '2P', got #{result.inspect}" unless result == "2P"
end

run_test("dumps single piece with large count") do
  result = Hand.dump([{ piece: "P", count: 10 }])
  raise "expected '10P', got #{result.inspect}" unless result == "10P"
end

# ============================================================================
# BASIC DUMPING - MULTIPLE PIECES
# ============================================================================

puts
puts "Basic dumping - multiple pieces:"

run_test("dumps multiple pieces with count 1") do
  result = Hand.dump([
    { piece: "P", count: 1 },
    { piece: "N", count: 1 },
    { piece: "R", count: 1 }
  ])
  raise "expected 'PNR', got #{result.inspect}" unless result == "PNR"
end

run_test("dumps multiple pieces with mixed counts") do
  result = Hand.dump([
    { piece: "B", count: 3 },
    { piece: "P", count: 2 },
    { piece: "N", count: 1 }
  ])
  raise "expected '3B2PN', got #{result.inspect}" unless result == "3B2PN"
end

run_test("dumps pieces in given order") do
  result = Hand.dump([
    { piece: "R", count: 1 },
    { piece: "N", count: 1 },
    { piece: "B", count: 1 }
  ])
  raise "expected 'RNB' (order preserved), got #{result.inspect}" unless result == "RNB"
end

# ============================================================================
# DUMPING WITH OBJECTS
# ============================================================================

puts
puts "Dumping with objects:"

# Mock piece object
MockPiece = Struct.new(:name) do
  def to_s
    name
  end
end

run_test("dumps objects responding to to_s") do
  piece = MockPiece.new("K")
  result = Hand.dump([{ piece: piece, count: 1 }])
  raise "expected 'K', got #{result.inspect}" unless result == "K"
end

run_test("dumps mixed objects with counts") do
  king = MockPiece.new("K")
  queen = MockPiece.new("Q")
  result = Hand.dump([
    { piece: king, count: 2 },
    { piece: queen, count: 1 }
  ])
  raise "expected '2KQ', got #{result.inspect}" unless result == "2KQ"
end

# ============================================================================
# DUMPING WITH EPIN-LIKE TOKENS
# ============================================================================

puts
puts "Dumping with EPIN-like tokens:"

run_test("dumps piece with state modifier") do
  result = Hand.dump([{ piece: "+P", count: 1 }])
  raise "expected '+P', got #{result.inspect}" unless result == "+P"
end

run_test("dumps piece with terminal marker") do
  result = Hand.dump([{ piece: "K^", count: 1 }])
  raise "expected 'K^', got #{result.inspect}" unless result == "K^"
end

run_test("dumps piece with derivation marker") do
  result = Hand.dump([{ piece: "P'", count: 1 }])
  raise "expected \"P'\", got #{result.inspect}" unless result == "P'"
end

run_test("dumps fully decorated EPIN token") do
  result = Hand.dump([{ piece: "+K^'", count: 2 }])
  raise "expected \"2+K^'\", got #{result.inspect}" unless result == "2+K^'"
end

run_test("dumps mixed EPIN tokens") do
  result = Hand.dump([
    { piece: "+P", count: 3 },
    { piece: "-N", count: 2 },
    { piece: "B^", count: 1 }
  ])
  raise "expected '3+P2-NB^', got #{result.inspect}" unless result == "3+P2-NB^"
end

# ============================================================================
# EDGE CASES
# ============================================================================

puts
puts "Edge cases:"

run_test("dumps lowercase pieces") do
  result = Hand.dump([
    { piece: "p", count: 2 },
    { piece: "n", count: 1 }
  ])
  raise "expected '2pn', got #{result.inspect}" unless result == "2pn"
end

run_test("dumps very large count") do
  result = Hand.dump([{ piece: "P", count: 999 }])
  raise "expected '999P', got #{result.inspect}" unless result == "999P"
end

run_test("handles count exactly 1") do
  result = Hand.dump([{ piece: "K", count: 1 }])
  raise "expected 'K' (no prefix), got #{result.inspect}" unless result == "K"
end

run_test("handles count exactly 2") do
  result = Hand.dump([{ piece: "K", count: 2 }])
  raise "expected '2K', got #{result.inspect}" unless result == "2K"
end

# ============================================================================
# RETURN TYPE
# ============================================================================

puts
puts "Return type:"

run_test("returns String") do
  result = Hand.dump([])
  raise "expected String" unless ::String === result
end

run_test("returns String for non-empty hand") do
  result = Hand.dump([{ piece: "K", count: 1 }])
  raise "expected String" unless ::String === result
end

# ============================================================================
# MODULE STRUCTURE
# ============================================================================

puts
puts "Module structure:"

run_test("module is frozen") do
  raise "expected frozen" unless Hand.frozen?
end

run_test("dump is the only public method") do
  public_methods = Hand.methods(false) - Object.methods
  raise "expected only :dump, got #{public_methods}" unless public_methods == [:dump]
end

# ============================================================================
# REAL-WORLD EXAMPLES
# ============================================================================

puts
puts "Real-world examples:"

run_test("dumps Shogi captured pieces (first player)") do
  result = Hand.dump([
    { piece: "P", count: 3 },
    { piece: "L", count: 2 },
    { piece: "N", count: 1 },
    { piece: "S", count: 1 }
  ])
  raise "expected '3P2LNS', got #{result.inspect}" unless result == "3P2LNS"
end

run_test("dumps Shogi captured pieces (second player)") do
  result = Hand.dump([
    { piece: "p", count: 2 },
    { piece: "g", count: 1 }
  ])
  raise "expected '2pg', got #{result.inspect}" unless result == "2pg"
end

run_test("dumps Crazyhouse-style hand") do
  result = Hand.dump([
    { piece: "Q", count: 1 },
    { piece: "R", count: 2 },
    { piece: "B", count: 1 },
    { piece: "N", count: 1 },
    { piece: "P", count: 5 }
  ])
  raise "expected 'Q2RBNP' or similar" unless result == "Q2RBN5P"
end

puts
puts "All Dumper::Hand tests passed!"
puts
