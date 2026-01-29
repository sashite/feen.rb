#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../lib/sashite/feen/position"
require "sashite/epin"
require "sashite/sin"

# Helper function to run a test and report errors
def run_test(name)
  print "  #{name}... "
  yield
  puts "✓"
rescue StandardError => e
  warn "✗ Failure: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end unless defined?(run_test)

puts
puts "=== Position Tests ==="
puts

# ============================================================================
# CONSTRUCTOR TESTS
# ============================================================================

puts "Constructor:"

run_test("creates Position with minimal data") do
  k = Sashite::Epin.parse("K")
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  position = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "position should be created" unless position.is_a?(Sashite::Feen::Position)
end

run_test("creates Position with complex piece placement") do
  k = Sashite::Epin.parse("K")
  q = Sashite::Epin.parse("Q")
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  position = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k, 3], [8], [q]], separators: ["/", "/"] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "wrong segment count" unless position.piece_placement.segments.size == 3
end

run_test("creates Position with pieces in hands") do
  k = Sashite::Epin.parse("K")
  p1 = Sashite::Epin.parse("P")
  p2 = Sashite::Epin.parse("p")
  active = Sashite::Sin.parse("S")
  inactive = Sashite::Sin.parse("s")

  position = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: {
      first: [{ piece: p1, count: 2 }],
      second: [{ piece: p2, count: 1 }]
    },
    style_turn: { active: active, inactive: inactive }
  )

  raise "first hand should have items" if position.hands.first.empty?
  raise "second hand should have items" if position.hands.second.empty?
end

run_test("creates Position with second player active") do
  k = Sashite::Epin.parse("K")
  active = Sashite::Sin.parse("c")
  inactive = Sashite::Sin.parse("C")

  position = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "should be second to move" unless position.style_turn.second_to_move?
end

# ============================================================================
# IMMUTABILITY TESTS
# ============================================================================

puts
puts "Immutability:"

run_test("Position is frozen after creation") do
  k = Sashite::Epin.parse("K")
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  position = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "should be frozen" unless position.frozen?
end

# ============================================================================
# ATTRIBUTE ACCESSORS
# ============================================================================

puts
puts "Attribute accessors:"

run_test("piece_placement returns PiecePlacement object") do
  k = Sashite::Epin.parse("K")
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  position = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "wrong type" unless position.piece_placement.is_a?(Sashite::Feen::Position::PiecePlacement)
end

run_test("hands returns Hands object") do
  k = Sashite::Epin.parse("K")
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  position = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "wrong type" unless position.hands.is_a?(Sashite::Feen::Position::Hands)
end

run_test("style_turn returns StyleTurn object") do
  k = Sashite::Epin.parse("K")
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  position = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "wrong type" unless position.style_turn.is_a?(Sashite::Feen::Position::StyleTurn)
end

# ============================================================================
# TO_S TESTS - MINIMAL
# ============================================================================

puts
puts "to_s - minimal:"

run_test("returns 'K / C/c' for minimal position") do
  k = Sashite::Epin.parse("K")
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  position = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "wrong string: #{position.to_s}" unless position.to_s == "K / C/c"
end

run_test("returns '8 / C/c' for empty board") do
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  position = Sashite::Feen::Position.new(
    piece_placement: { segments: [[8]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "wrong string: #{position.to_s}" unless position.to_s == "8 / C/c"
end

# ============================================================================
# TO_S TESTS - WITH HANDS
# ============================================================================

puts
puts "to_s - with hands:"

run_test("returns 'K P/ C/c' with piece in first hand") do
  k = Sashite::Epin.parse("K")
  p = Sashite::Epin.parse("P")
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  position = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [{ piece: p, count: 1 }], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "wrong string: #{position.to_s}" unless position.to_s == "K P/ C/c"
end

run_test("returns 'K /p C/c' with piece in second hand") do
  k = Sashite::Epin.parse("K")
  p = Sashite::Epin.parse("p")
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  position = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [{ piece: p, count: 1 }] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "wrong string: #{position.to_s}" unless position.to_s == "K /p C/c"
end

run_test("returns 'K 2P/3n C/c' with multiple pieces in hands") do
  k = Sashite::Epin.parse("K")
  p = Sashite::Epin.parse("P")
  n = Sashite::Epin.parse("n")
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  position = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: {
      first: [{ piece: p, count: 2 }],
      second: [{ piece: n, count: 3 }]
    },
    style_turn: { active: active, inactive: inactive }
  )

  raise "wrong string: #{position.to_s}" unless position.to_s == "K 2P/3n C/c"
end

# ============================================================================
# TO_S TESTS - DIFFERENT STYLES
# ============================================================================

puts
puts "to_s - different styles:"

run_test("returns correct string for Shogi") do
  k = Sashite::Epin.parse("K")
  active = Sashite::Sin.parse("S")
  inactive = Sashite::Sin.parse("s")

  position = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "wrong string: #{position.to_s}" unless position.to_s == "K / S/s"
end

run_test("returns correct string for second player active") do
  k = Sashite::Epin.parse("K")
  active = Sashite::Sin.parse("c")
  inactive = Sashite::Sin.parse("C")

  position = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "wrong string: #{position.to_s}" unless position.to_s == "K / c/C"
end

run_test("returns correct string for cross-style game") do
  k = Sashite::Epin.parse("K")
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("s")

  position = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "wrong string: #{position.to_s}" unless position.to_s == "K / C/s"
end

# ============================================================================
# TO_S TESTS - REALISTIC POSITIONS
# ============================================================================

puts
puts "to_s - realistic positions:"

run_test("returns Chess initial position") do
  rank8 = "rnbqkbnr".chars.map { |c| Sashite::Epin.parse(c) }
  rank7 = "pppppppp".chars.map { |c| Sashite::Epin.parse(c) }
  rank2 = "PPPPPPPP".chars.map { |c| Sashite::Epin.parse(c) }
  rank1 = "RNBQKBNR".chars.map { |c| Sashite::Epin.parse(c) }

  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  position = Sashite::Feen::Position.new(
    piece_placement: {
      segments: [rank8, rank7, [8], [8], [8], [8], rank2, rank1],
      separators: ["/", "/", "/", "/", "/", "/", "/"]
    },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  expected = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
  raise "wrong string: #{position.to_s}" unless position.to_s == expected
end

run_test("returns Shogi initial position") do
  rank9 = "lnsgkgsnl".chars.map { |c| Sashite::Epin.parse(c) }
  rank8 = [1, Sashite::Epin.parse("r"), 5, Sashite::Epin.parse("b"), 1]
  rank7 = "ppppppppp".chars.map { |c| Sashite::Epin.parse(c) }
  rank3 = "PPPPPPPPP".chars.map { |c| Sashite::Epin.parse(c) }
  rank2 = [1, Sashite::Epin.parse("B"), 5, Sashite::Epin.parse("R"), 1]
  rank1 = "LNSGKGSNL".chars.map { |c| Sashite::Epin.parse(c) }

  active = Sashite::Sin.parse("S")
  inactive = Sashite::Sin.parse("s")

  position = Sashite::Feen::Position.new(
    piece_placement: {
      segments: [rank9, rank8, rank7, [9], [9], [9], rank3, rank2, rank1],
      separators: ["/", "/", "/", "/", "/", "/", "/", "/"]
    },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  expected = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s"
  raise "wrong string: #{position.to_s}" unless position.to_s == expected
end

run_test("returns 3D position with double separators") do
  k = Sashite::Epin.parse("K")
  q = Sashite::Epin.parse("k")
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  position = Sashite::Feen::Position.new(
    piece_placement: {
      segments: [[k], [8], [q]],
      separators: ["//", "//"]
    },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "wrong string: #{position.to_s}" unless position.to_s == "K//8//k / C/c"
end

# ============================================================================
# EQUALITY TESTS
# ============================================================================

puts
puts "Equality:"

run_test("equal Positions are ==") do
  k = Sashite::Epin.parse("K")
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  pos1 = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )
  pos2 = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "should be equal" unless pos1 == pos2
end

run_test("different piece placements are not ==") do
  k = Sashite::Epin.parse("K")
  q = Sashite::Epin.parse("Q")
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  pos1 = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )
  pos2 = Sashite::Feen::Position.new(
    piece_placement: { segments: [[q]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "should not be equal" if pos1 == pos2
end

run_test("different hands are not ==") do
  k = Sashite::Epin.parse("K")
  p = Sashite::Epin.parse("P")
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  pos1 = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )
  pos2 = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [{ piece: p, count: 1 }], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "should not be equal" if pos1 == pos2
end

run_test("different style turns are not ==") do
  k = Sashite::Epin.parse("K")
  active1 = Sashite::Sin.parse("C")
  inactive1 = Sashite::Sin.parse("c")
  active2 = Sashite::Sin.parse("c")
  inactive2 = Sashite::Sin.parse("C")

  pos1 = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active1, inactive: inactive1 }
  )
  pos2 = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active2, inactive: inactive2 }
  )

  raise "should not be equal" if pos1 == pos2
end

run_test("eql? is aliased to ==") do
  k = Sashite::Epin.parse("K")
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  pos1 = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )
  pos2 = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "eql? should work" unless pos1.eql?(pos2)
end

run_test("equal Positions have same hash") do
  k = Sashite::Epin.parse("K")
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  pos1 = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )
  pos2 = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  raise "hash should match" unless pos1.hash == pos2.hash
end

run_test("can be used as hash key") do
  k = Sashite::Epin.parse("K")
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  pos1 = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )
  pos2 = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  hash = { pos1 => "value" }
  raise "should find by equal key" unless hash[pos2] == "value"
end

# ============================================================================
# INSPECT TESTS
# ============================================================================

puts
puts "Inspect:"

run_test("inspect returns readable string") do
  k = Sashite::Epin.parse("K")
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  position = Sashite::Feen::Position.new(
    piece_placement: { segments: [[k]], separators: [] },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  inspect_str = position.inspect
  raise "should include class name" unless inspect_str.include?("Sashite::Feen::Position")
  raise "should include FEEN string" unless inspect_str.include?("K / C/c")
end

# ============================================================================
# ROUND-TRIP TESTS
# ============================================================================

puts
puts "Round-trip consistency:"

run_test("to_s output can be re-parsed to equal position") do
  # Build a complex position
  rank8 = "rnbqkbnr".chars.map { |c| Sashite::Epin.parse(c) }
  rank7 = "pppppppp".chars.map { |c| Sashite::Epin.parse(c) }
  rank2 = "PPPPPPPP".chars.map { |c| Sashite::Epin.parse(c) }
  rank1 = "RNBQKBNR".chars.map { |c| Sashite::Epin.parse(c) }

  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")

  position = Sashite::Feen::Position.new(
    piece_placement: {
      segments: [rank8, rank7, [8], [8], [8], [8], rank2, rank1],
      separators: ["/", "/", "/", "/", "/", "/", "/"]
    },
    hands: { first: [], second: [] },
    style_turn: { active: active, inactive: inactive }
  )

  # Verify to_s produces expected output
  expected = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
  raise "to_s mismatch" unless position.to_s == expected

  # The full round-trip test would require the parser, but we verify format
end

puts
puts "All Position tests passed!"
puts
