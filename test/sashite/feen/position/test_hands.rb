#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/position/hands"

require "sashite/epin"

puts
puts "=== Position::Hands Tests ==="
puts

# ============================================================================
# HANDS CONSTRUCTOR TESTS
# ============================================================================

puts "Hands constructor:"

run_test("creates Hands with empty arrays") do
  hands = Sashite::Feen::Position::Hands.new(first: [], second: [])
  raise "first should be empty" unless hands.first.empty?
  raise "second should be empty" unless hands.second.empty?
end

run_test("creates Hands with items in first hand") do
  piece = Sashite::Epin.parse("P")
  first_items = [{ piece: piece, count: 2 }]
  hands = Sashite::Feen::Position::Hands.new(first: first_items, second: [])
  raise "first should have items" if hands.first.empty?
  raise "second should be empty" unless hands.second.empty?
end

run_test("creates Hands with items in second hand") do
  piece = Sashite::Epin.parse("p")
  second_items = [{ piece: piece, count: 1 }]
  hands = Sashite::Feen::Position::Hands.new(first: [], second: second_items)
  raise "first should be empty" unless hands.first.empty?
  raise "second should have items" if hands.second.empty?
end

run_test("creates Hands with items in both hands") do
  p1 = Sashite::Epin.parse("P")
  p2 = Sashite::Epin.parse("p")
  hands = Sashite::Feen::Position::Hands.new(
    first: [{ piece: p1, count: 2 }],
    second: [{ piece: p2, count: 3 }]
  )
  raise "first wrong size" unless hands.first.size == 1
  raise "second wrong size" unless hands.second.size == 1
end

# ============================================================================
# HANDS IMMUTABILITY TESTS
# ============================================================================

puts
puts "Hands immutability:"

run_test("Hands is frozen after creation") do
  hands = Sashite::Feen::Position::Hands.new(first: [], second: [])
  raise "should be frozen" unless hands.frozen?
end

# ============================================================================
# HANDS ATTRIBUTE ACCESSORS
# ============================================================================

puts
puts "Hands attribute accessors:"

run_test("first returns a Hand object") do
  hands = Sashite::Feen::Position::Hands.new(first: [], second: [])
  raise "wrong type" unless hands.first.is_a?(Sashite::Feen::Position::Hand)
end

run_test("second returns a Hand object") do
  hands = Sashite::Feen::Position::Hands.new(first: [], second: [])
  raise "wrong type" unless hands.second.is_a?(Sashite::Feen::Position::Hand)
end

# ============================================================================
# HANDS TO_S TESTS
# ============================================================================

puts
puts "Hands to_s:"

run_test("returns '/' for empty hands") do
  hands = Sashite::Feen::Position::Hands.new(first: [], second: [])
  raise "wrong string: #{hands.to_s}" unless hands.to_s == "/"
end

run_test("returns 'P/' for single piece in first hand") do
  piece = Sashite::Epin.parse("P")
  hands = Sashite::Feen::Position::Hands.new(
    first: [{ piece: piece, count: 1 }],
    second: []
  )
  raise "wrong string: #{hands.to_s}" unless hands.to_s == "P/"
end

run_test("returns '/p' for single piece in second hand") do
  piece = Sashite::Epin.parse("p")
  hands = Sashite::Feen::Position::Hands.new(
    first: [],
    second: [{ piece: piece, count: 1 }]
  )
  raise "wrong string: #{hands.to_s}" unless hands.to_s == "/p"
end

run_test("returns '2P/' for count > 1") do
  piece = Sashite::Epin.parse("P")
  hands = Sashite::Feen::Position::Hands.new(
    first: [{ piece: piece, count: 2 }],
    second: []
  )
  raise "wrong string: #{hands.to_s}" unless hands.to_s == "2P/"
end

run_test("returns 'P/p' for one piece each") do
  p1 = Sashite::Epin.parse("P")
  p2 = Sashite::Epin.parse("p")
  hands = Sashite::Feen::Position::Hands.new(
    first: [{ piece: p1, count: 1 }],
    second: [{ piece: p2, count: 1 }]
  )
  raise "wrong string: #{hands.to_s}" unless hands.to_s == "P/p"
end

run_test("returns '3q2PBN/' for complex hands (canonical order)") do
  # Input in non-canonical order, output should be canonical
  p1 = Sashite::Epin.parse("P")
  b1 = Sashite::Epin.parse("B")
  n1 = Sashite::Epin.parse("N")
  q2 = Sashite::Epin.parse("q")
  r2 = Sashite::Epin.parse("r")
  hands = Sashite::Feen::Position::Hands.new(
    first: [
      { piece: p1, count: 2 },
      { piece: b1, count: 1 },
      { piece: n1, count: 1 }
    ],
    second: [
      { piece: q2, count: 3 },
      { piece: r2, count: 1 }
    ]
  )
  # Canonical order for first hand: 2P (count 2), B, N (count 1, alphabetical)
  # Canonical order for second hand: 3q (count 3), r (count 1)
  raise "wrong string: #{hands.to_s}" unless hands.to_s == "2PBN/3qr"
end

# ============================================================================
# HANDS EQUALITY TESTS
# ============================================================================

puts
puts "Hands equality:"

run_test("equal Hands are ==") do
  piece = Sashite::Epin.parse("P")
  hands1 = Sashite::Feen::Position::Hands.new(
    first: [{ piece: piece, count: 2 }],
    second: []
  )
  hands2 = Sashite::Feen::Position::Hands.new(
    first: [{ piece: piece, count: 2 }],
    second: []
  )
  raise "should be equal" unless hands1 == hands2
end

run_test("different first hands are not ==") do
  p1 = Sashite::Epin.parse("P")
  p2 = Sashite::Epin.parse("N")
  hands1 = Sashite::Feen::Position::Hands.new(first: [{ piece: p1, count: 1 }], second: [])
  hands2 = Sashite::Feen::Position::Hands.new(first: [{ piece: p2, count: 1 }], second: [])
  raise "should not be equal" if hands1 == hands2
end

run_test("different second hands are not ==") do
  piece = Sashite::Epin.parse("P")
  p1 = Sashite::Epin.parse("p")
  p2 = Sashite::Epin.parse("n")
  hands1 = Sashite::Feen::Position::Hands.new(first: [{ piece: piece, count: 1 }], second: [{ piece: p1, count: 1 }])
  hands2 = Sashite::Feen::Position::Hands.new(first: [{ piece: piece, count: 1 }], second: [{ piece: p2, count: 1 }])
  raise "should not be equal" if hands1 == hands2
end

run_test("eql? is aliased to ==") do
  hands1 = Sashite::Feen::Position::Hands.new(first: [], second: [])
  hands2 = Sashite::Feen::Position::Hands.new(first: [], second: [])
  raise "eql? should work" unless hands1.eql?(hands2)
end

run_test("equal Hands have same hash") do
  piece = Sashite::Epin.parse("P")
  hands1 = Sashite::Feen::Position::Hands.new(first: [{ piece: piece, count: 2 }], second: [])
  hands2 = Sashite::Feen::Position::Hands.new(first: [{ piece: piece, count: 2 }], second: [])
  raise "hash should match" unless hands1.hash == hands2.hash
end

# ============================================================================
# HAND CONSTRUCTOR TESTS
# ============================================================================

puts
puts "Hand constructor:"

run_test("creates empty Hand") do
  hand = Sashite::Feen::Position::Hand.new([])
  raise "should be empty" unless hand.empty?
end

run_test("creates Hand with single item") do
  piece = Sashite::Epin.parse("P")
  hand = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 1 }])
  raise "wrong size" unless hand.size == 1
end

run_test("creates Hand with multiple items") do
  p1 = Sashite::Epin.parse("P")
  p2 = Sashite::Epin.parse("B")
  p3 = Sashite::Epin.parse("N")
  hand = Sashite::Feen::Position::Hand.new([
    { piece: p1, count: 2 },
    { piece: p2, count: 1 },
    { piece: p3, count: 3 }
  ])
  raise "wrong size" unless hand.size == 3
end

# ============================================================================
# HAND IMMUTABILITY TESTS
# ============================================================================

puts
puts "Hand immutability:"

run_test("Hand is frozen after creation") do
  hand = Sashite::Feen::Position::Hand.new([])
  raise "should be frozen" unless hand.frozen?
end

# ============================================================================
# HAND EMPTY? TESTS
# ============================================================================

puts
puts "Hand empty?:"

run_test("returns true for empty hand") do
  hand = Sashite::Feen::Position::Hand.new([])
  raise "should be empty" unless hand.empty?
end

run_test("returns false for non-empty hand") do
  piece = Sashite::Epin.parse("P")
  hand = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 1 }])
  raise "should not be empty" if hand.empty?
end

# ============================================================================
# HAND SIZE TESTS
# ============================================================================

puts
puts "Hand size:"

run_test("returns 0 for empty hand") do
  hand = Sashite::Feen::Position::Hand.new([])
  raise "wrong size" unless hand.size == 0
end

run_test("returns number of distinct piece types") do
  p1 = Sashite::Epin.parse("P")
  p2 = Sashite::Epin.parse("B")
  hand = Sashite::Feen::Position::Hand.new([
    { piece: p1, count: 5 },
    { piece: p2, count: 2 }
  ])
  raise "wrong size" unless hand.size == 2
end

# ============================================================================
# HAND ITEMS TESTS
# ============================================================================

puts
puts "Hand items:"

run_test("returns items array") do
  piece = Sashite::Epin.parse("P")
  items = [{ piece: piece, count: 2 }]
  hand = Sashite::Feen::Position::Hand.new(items)
  raise "wrong items" unless hand.items == items
end

# ============================================================================
# HAND EACH TESTS
# ============================================================================

puts
puts "Hand each:"

run_test("iterates over all items") do
  p1 = Sashite::Epin.parse("P")
  p2 = Sashite::Epin.parse("B")
  hand = Sashite::Feen::Position::Hand.new([
    { piece: p1, count: 2 },
    { piece: p2, count: 1 }
  ])

  collected = []
  hand.each { |item| collected << item }

  raise "wrong count" unless collected.size == 2
  raise "first item wrong" unless collected[0][:piece] == p1
  raise "second item wrong" unless collected[1][:piece] == p2
end

run_test("returns enumerator without block") do
  hand = Sashite::Feen::Position::Hand.new([])
  raise "should return Enumerator" unless hand.each.is_a?(Enumerator)
end

run_test("returns self with block") do
  hand = Sashite::Feen::Position::Hand.new([])
  result = hand.each { |_| }
  raise "should return self" unless result.equal?(hand)
end

# ============================================================================
# HAND TO_S TESTS - BASIC
# ============================================================================

puts
puts "Hand to_s - basic:"

run_test("returns '' for empty hand") do
  hand = Sashite::Feen::Position::Hand.new([])
  raise "wrong string: '#{hand.to_s}'" unless hand.to_s == ""
end

run_test("returns 'P' for single piece with count 1") do
  piece = Sashite::Epin.parse("P")
  hand = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 1 }])
  raise "wrong string: #{hand.to_s}" unless hand.to_s == "P"
end

run_test("returns '2P' for count > 1") do
  piece = Sashite::Epin.parse("P")
  hand = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 2 }])
  raise "wrong string: #{hand.to_s}" unless hand.to_s == "2P"
end

run_test("returns '10P' for large count") do
  piece = Sashite::Epin.parse("P")
  hand = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 10 }])
  raise "wrong string: #{hand.to_s}" unless hand.to_s == "10P"
end

# ============================================================================
# HAND TO_S TESTS - CANONICAL ORDERING
# ============================================================================

puts
puts "Hand to_s - canonical ordering:"

run_test("orders by multiplicity descending") do
  p1 = Sashite::Epin.parse("A")
  p2 = Sashite::Epin.parse("B")
  # Input: A with count 2, B with count 3 (wrong order)
  hand = Sashite::Feen::Position::Hand.new([
    { piece: p1, count: 2 },
    { piece: p2, count: 3 }
  ])
  # Output should be: 3B2A (B first because count 3 > 2)
  raise "wrong string: #{hand.to_s}" unless hand.to_s == "3B2A"
end

run_test("orders alphabetically within same count") do
  p1 = Sashite::Epin.parse("P")
  p2 = Sashite::Epin.parse("B")
  p3 = Sashite::Epin.parse("N")
  # Input: P, B, N (wrong alphabetical order)
  hand = Sashite::Feen::Position::Hand.new([
    { piece: p1, count: 1 },
    { piece: p2, count: 1 },
    { piece: p3, count: 1 }
  ])
  # Output should be: BNP (alphabetical)
  raise "wrong string: #{hand.to_s}" unless hand.to_s == "BNP"
end

run_test("orders uppercase before lowercase (same letter)") do
  p1 = Sashite::Epin.parse("p")
  p2 = Sashite::Epin.parse("P")
  # Input: lowercase p, uppercase P (wrong order)
  hand = Sashite::Feen::Position::Hand.new([
    { piece: p1, count: 1 },
    { piece: p2, count: 1 }
  ])
  # Output should be: Pp (uppercase first)
  raise "wrong string: #{hand.to_s}" unless hand.to_s == "Pp"
end

run_test("orders state modifiers: - before + before none") do
  p1 = Sashite::Epin.parse("P")
  p2 = Sashite::Epin.parse("+P")
  p3 = Sashite::Epin.parse("-P")
  # Input: normal, enhanced, diminished (wrong order)
  hand = Sashite::Feen::Position::Hand.new([
    { piece: p1, count: 1 },
    { piece: p2, count: 1 },
    { piece: p3, count: 1 }
  ])
  # Output should be: -P+PP (diminished, enhanced, normal)
  raise "wrong string: #{hand.to_s}" unless hand.to_s == "-P+PP"
end

run_test("orders terminal marker: absent before present") do
  p1 = Sashite::Epin.parse("P^")
  p2 = Sashite::Epin.parse("P")
  # Input: terminal, non-terminal (wrong order)
  hand = Sashite::Feen::Position::Hand.new([
    { piece: p1, count: 1 },
    { piece: p2, count: 1 }
  ])
  # Output should be: PP^ (non-terminal first)
  raise "wrong string: #{hand.to_s}" unless hand.to_s == "PP^"
end

run_test("orders derivation marker: absent before present") do
  p1 = Sashite::Epin.parse("P'")
  p2 = Sashite::Epin.parse("P")
  # Input: derived, non-derived (wrong order)
  hand = Sashite::Feen::Position::Hand.new([
    { piece: p1, count: 1 },
    { piece: p2, count: 1 }
  ])
  # Output should be: PP' (non-derived first)
  raise "wrong string: #{hand.to_s}" unless hand.to_s == "PP'"
end

run_test("complex canonical ordering example") do
  # Create pieces in intentionally wrong order
  a3 = Sashite::Epin.parse("A")
  b2 = Sashite::Epin.parse("B")
  c_upper = Sashite::Epin.parse("C")
  c_lower = Sashite::Epin.parse("c")
  d_dim = Sashite::Epin.parse("-D")
  d_enh = Sashite::Epin.parse("+D")
  d_norm = Sashite::Epin.parse("D")

  # Input in wrong order
  hand = Sashite::Feen::Position::Hand.new([
    { piece: d_norm, count: 1 },
    { piece: c_lower, count: 1 },
    { piece: b2, count: 2 },
    { piece: d_enh, count: 1 },
    { piece: c_upper, count: 1 },
    { piece: a3, count: 3 },
    { piece: d_dim, count: 1 }
  ])

  # Expected canonical order:
  # 3A (count 3)
  # 2B (count 2)
  # C (count 1, letter C, uppercase)
  # c (count 1, letter C, lowercase)
  # -D (count 1, letter D, diminished)
  # +D (count 1, letter D, enhanced)
  # D (count 1, letter D, normal)
  expected = "3A2BCc-D+DD"
  raise "wrong string: #{hand.to_s}" unless hand.to_s == expected
end

run_test("canonical ordering with all modifiers combined") do
  p1 = Sashite::Epin.parse("+P^'")
  p2 = Sashite::Epin.parse("+P^")
  p3 = Sashite::Epin.parse("+P'")
  p4 = Sashite::Epin.parse("+P")

  # Input in wrong order
  hand = Sashite::Feen::Position::Hand.new([
    { piece: p1, count: 1 },  # +P^'
    { piece: p2, count: 1 },  # +P^
    { piece: p3, count: 1 },  # +P'
    { piece: p4, count: 1 }   # +P
  ])

  # Expected order (all same letter, same state, so by terminal then derivation):
  # +P (no terminal, no derived)
  # +P' (no terminal, derived)
  # +P^ (terminal, no derived)
  # +P^' (terminal, derived)
  expected = "+P+P'+P^+P^'"
  raise "wrong string: #{hand.to_s}" unless hand.to_s == expected
end

# ============================================================================
# HAND TO_S TESTS - EPIN MODIFIERS
# ============================================================================

puts
puts "Hand to_s - EPIN modifiers:"

run_test("handles enhanced pieces") do
  piece = Sashite::Epin.parse("+P")
  hand = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 2 }])
  raise "wrong string: #{hand.to_s}" unless hand.to_s == "2+P"
end

run_test("handles diminished pieces") do
  piece = Sashite::Epin.parse("-P")
  hand = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 2 }])
  raise "wrong string: #{hand.to_s}" unless hand.to_s == "2-P"
end

run_test("handles terminal pieces") do
  piece = Sashite::Epin.parse("P^")
  hand = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 2 }])
  raise "wrong string: #{hand.to_s}" unless hand.to_s == "2P^"
end

run_test("handles derived pieces") do
  piece = Sashite::Epin.parse("P'")
  hand = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 2 }])
  raise "wrong string: #{hand.to_s}" unless hand.to_s == "2P'"
end

run_test("handles all modifiers combined") do
  piece = Sashite::Epin.parse("+P^'")
  hand = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 2 }])
  raise "wrong string: #{hand.to_s}" unless hand.to_s == "2+P^'"
end

run_test("handles lowercase pieces") do
  piece = Sashite::Epin.parse("p")
  hand = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 3 }])
  raise "wrong string: #{hand.to_s}" unless hand.to_s == "3p"
end

# ============================================================================
# HAND EQUALITY TESTS
# ============================================================================

puts
puts "Hand equality:"

run_test("equal Hands are ==") do
  piece = Sashite::Epin.parse("P")
  hand1 = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 2 }])
  hand2 = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 2 }])
  raise "should be equal" unless hand1 == hand2
end

run_test("different pieces are not ==") do
  p1 = Sashite::Epin.parse("P")
  p2 = Sashite::Epin.parse("N")
  hand1 = Sashite::Feen::Position::Hand.new([{ piece: p1, count: 1 }])
  hand2 = Sashite::Feen::Position::Hand.new([{ piece: p2, count: 1 }])
  raise "should not be equal" if hand1 == hand2
end

run_test("different counts are not ==") do
  piece = Sashite::Epin.parse("P")
  hand1 = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 1 }])
  hand2 = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 2 }])
  raise "should not be equal" if hand1 == hand2
end

run_test("different order in items array means not == (items equality)") do
  p1 = Sashite::Epin.parse("P")
  p2 = Sashite::Epin.parse("B")
  hand1 = Sashite::Feen::Position::Hand.new([{ piece: p1, count: 1 }, { piece: p2, count: 1 }])
  hand2 = Sashite::Feen::Position::Hand.new([{ piece: p2, count: 1 }, { piece: p1, count: 1 }])
  # Items arrays are different, so equality based on items is false
  raise "should not be equal (items differ)" if hand1 == hand2
end

run_test("different order produces same to_s (canonical serialization)") do
  p1 = Sashite::Epin.parse("P")
  p2 = Sashite::Epin.parse("B")
  hand1 = Sashite::Feen::Position::Hand.new([{ piece: p1, count: 1 }, { piece: p2, count: 1 }])
  hand2 = Sashite::Feen::Position::Hand.new([{ piece: p2, count: 1 }, { piece: p1, count: 1 }])
  # But to_s should be the same (canonical)
  raise "to_s should be equal" unless hand1.to_s == hand2.to_s
  raise "to_s should be canonical" unless hand1.to_s == "BP"
end

run_test("eql? is aliased to ==") do
  piece = Sashite::Epin.parse("P")
  hand1 = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 1 }])
  hand2 = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 1 }])
  raise "eql? should work" unless hand1.eql?(hand2)
end

run_test("equal Hands have same hash") do
  piece = Sashite::Epin.parse("P")
  hand1 = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 2 }])
  hand2 = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 2 }])
  raise "hash should match" unless hand1.hash == hand2.hash
end

run_test("can be used as hash key") do
  piece = Sashite::Epin.parse("P")
  hand1 = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 2 }])
  hand2 = Sashite::Feen::Position::Hand.new([{ piece: piece, count: 2 }])

  hash = { hand1 => "value" }
  raise "should find by equal key" unless hash[hand2] == "value"
end

# ============================================================================
# ROUND-TRIP CONSISTENCY
# ============================================================================

puts
puts "Round-trip consistency:"

run_test("to_s always produces canonical output regardless of input order") do
  # Create items in various non-canonical orders and verify output is always canonical
  p = Sashite::Epin.parse("P")
  b = Sashite::Epin.parse("B")
  n = Sashite::Epin.parse("N")

  # Order 1: P, B, N
  hand1 = Sashite::Feen::Position::Hand.new([
    { piece: p, count: 1 },
    { piece: b, count: 1 },
    { piece: n, count: 1 }
  ])

  # Order 2: N, P, B
  hand2 = Sashite::Feen::Position::Hand.new([
    { piece: n, count: 1 },
    { piece: p, count: 1 },
    { piece: b, count: 1 }
  ])

  # Order 3: B, N, P
  hand3 = Sashite::Feen::Position::Hand.new([
    { piece: b, count: 1 },
    { piece: n, count: 1 },
    { piece: p, count: 1 }
  ])

  canonical = "BNP"
  raise "hand1 should be canonical" unless hand1.to_s == canonical
  raise "hand2 should be canonical" unless hand2.to_s == canonical
  raise "hand3 should be canonical" unless hand3.to_s == canonical
end

puts
puts "All Position::Hands tests passed!"
puts
