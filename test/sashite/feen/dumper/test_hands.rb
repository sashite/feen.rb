#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/dumper/hands"

puts
puts "=== Dumper::Hands Tests ==="
puts

Hands = Sashite::Feen::Dumper::Hands

# ============================================================================
# BASIC DUMPING - EMPTY HANDS
# ============================================================================

puts "Basic dumping - empty hands:"

run_test("dumps both hands empty") do
  result = Hands.dump(first: [], second: [])
  raise "expected '/', got #{result.inspect}" unless result == "/"
end

# ============================================================================
# BASIC DUMPING - FIRST HAND ONLY
# ============================================================================

puts
puts "Basic dumping - first hand only:"

run_test("dumps single piece in first hand") do
  result = Hands.dump(
    first: [{ piece: "P", count: 1 }],
    second: []
  )
  raise "expected 'P/', got #{result.inspect}" unless result == "P/"
end

run_test("dumps multiple pieces in first hand") do
  result = Hands.dump(
    first: [{ piece: "B", count: 2 }, { piece: "N", count: 1 }],
    second: []
  )
  raise "expected '2BN/', got #{result.inspect}" unless result == "2BN/"
end

# ============================================================================
# BASIC DUMPING - SECOND HAND ONLY
# ============================================================================

puts
puts "Basic dumping - second hand only:"

run_test("dumps single piece in second hand") do
  result = Hands.dump(
    first: [],
    second: [{ piece: "p", count: 1 }]
  )
  raise "expected '/p', got #{result.inspect}" unless result == "/p"
end

run_test("dumps multiple pieces in second hand") do
  result = Hands.dump(
    first: [],
    second: [{ piece: "b", count: 3 }, { piece: "n", count: 2 }]
  )
  raise "expected '/3b2n', got #{result.inspect}" unless result == "/3b2n"
end

# ============================================================================
# BASIC DUMPING - BOTH HANDS
# ============================================================================

puts
puts "Basic dumping - both hands:"

run_test("dumps pieces in both hands") do
  result = Hands.dump(
    first: [{ piece: "P", count: 2 }],
    second: [{ piece: "p", count: 1 }]
  )
  raise "expected '2P/p', got #{result.inspect}" unless result == "2P/p"
end

run_test("dumps complex hands") do
  result = Hands.dump(
    first: [{ piece: "B", count: 3 }, { piece: "P", count: 2 }, { piece: "N", count: 1 }],
    second: [{ piece: "q", count: 2 }, { piece: "r", count: 1 }]
  )
  raise "expected '3B2PN/2qr', got #{result.inspect}" unless result == "3B2PN/2qr"
end

# ============================================================================
# DUMPING WITH EPIN TOKENS
# ============================================================================

puts
puts "Dumping with EPIN tokens:"

run_test("dumps EPIN tokens with modifiers") do
  result = Hands.dump(
    first: [{ piece: "+P", count: 2 }],
    second: [{ piece: "-n", count: 1 }]
  )
  raise "expected '2+P/-n', got #{result.inspect}" unless result == "2+P/-n"
end

run_test("dumps EPIN tokens with terminal markers") do
  result = Hands.dump(
    first: [{ piece: "K^", count: 1 }],
    second: [{ piece: "k^", count: 1 }]
  )
  raise "expected 'K^/k^', got #{result.inspect}" unless result == "K^/k^"
end

run_test("dumps EPIN tokens with derivation markers") do
  result = Hands.dump(
    first: [{ piece: "P'", count: 3 }],
    second: [{ piece: "p'", count: 2 }]
  )
  raise "expected \"3P'/2p'\", got #{result.inspect}" unless result == "3P'/2p'"
end

run_test("dumps fully decorated EPIN tokens") do
  result = Hands.dump(
    first: [{ piece: "+K^'", count: 1 }],
    second: [{ piece: "-q^'", count: 1 }]
  )
  raise "expected \"+K^'/-q^'\", got #{result.inspect}" unless result == "+K^'/-q^'"
end

# ============================================================================
# PIECE SIDE INDEPENDENCE
# ============================================================================

puts
puts "Piece side independence:"

run_test("dumps uppercase pieces in second hand") do
  # Per spec: Piece Side is independent of Hand's associated Side
  result = Hands.dump(
    first: [],
    second: [{ piece: "P", count: 2 }]  # uppercase in second hand
  )
  raise "expected '/2P', got #{result.inspect}" unless result == "/2P"
end

run_test("dumps lowercase pieces in first hand") do
  result = Hands.dump(
    first: [{ piece: "p", count: 3 }],  # lowercase in first hand
    second: []
  )
  raise "expected '3p/', got #{result.inspect}" unless result == "3p/"
end

run_test("dumps mixed case in both hands") do
  result = Hands.dump(
    first: [{ piece: "P", count: 1 }, { piece: "n", count: 1 }],
    second: [{ piece: "p", count: 1 }, { piece: "N", count: 1 }]
  )
  raise "expected 'Pn/pN', got #{result.inspect}" unless result == "Pn/pN"
end

# ============================================================================
# RETURN TYPE
# ============================================================================

puts
puts "Return type:"

run_test("returns String") do
  result = Hands.dump(first: [], second: [])
  raise "expected String" unless ::String === result
end

run_test("returns String with content") do
  result = Hands.dump(
    first: [{ piece: "K", count: 1 }],
    second: [{ piece: "k", count: 1 }]
  )
  raise "expected String" unless ::String === result
end

# ============================================================================
# MODULE STRUCTURE
# ============================================================================

puts
puts "Module structure:"

run_test("module is frozen") do
  raise "expected frozen" unless Hands.frozen?
end

run_test("dump is the only public method") do
  public_methods = Hands.methods(false) - Object.methods
  raise "expected only :dump, got #{public_methods}" unless public_methods == [:dump]
end

# ============================================================================
# REAL-WORLD EXAMPLES
# ============================================================================

puts
puts "Real-world examples:"

run_test("dumps Chess empty hands") do
  result = Hands.dump(first: [], second: [])
  raise "expected '/', got #{result.inspect}" unless result == "/"
end

run_test("dumps Shogi mid-game hands") do
  result = Hands.dump(
    first: [
      { piece: "P", count: 3 },
      { piece: "L", count: 2 },
      { piece: "N", count: 1 },
      { piece: "S", count: 1 }
    ],
    second: [
      { piece: "p", count: 2 },
      { piece: "g", count: 1 }
    ]
  )
  raise "expected '3P2LNS/2pg', got #{result.inspect}" unless result == "3P2LNS/2pg"
end

run_test("dumps Crazyhouse hands") do
  result = Hands.dump(
    first: [
      { piece: "Q", count: 1 },
      { piece: "R", count: 2 },
      { piece: "B", count: 1 },
      { piece: "N", count: 1 },
      { piece: "P", count: 5 }
    ],
    second: [
      { piece: "r", count: 1 },
      { piece: "n", count: 2 },
      { piece: "p", count: 3 }
    ]
  )
  raise "wrong Crazyhouse hands" unless result == "Q2RBN5P/r2n3p"
end

run_test("dumps asymmetric hands") do
  result = Hands.dump(
    first: [{ piece: "R", count: 1 }],
    second: []
  )
  raise "expected 'R/', got #{result.inspect}" unless result == "R/"
end

puts
puts "All Dumper::Hands tests passed!"
puts
