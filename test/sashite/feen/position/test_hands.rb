#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../../lib/sashite/feen/position/hands"
require "sashite/epin"

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

run_test("returns '2PBN/3qr' for complex hands") do
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
# HAND TO_S TESTS
# ============================================================================

puts
puts "Hand to_s:"

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

run_test("returns 'PBN' for multiple pieces count 1") do
  p1 = Sashite::Epin.parse("P")
  p2 = Sashite::Epin.parse("B")
  p3 = Sashite::Epin.parse("N")
  hand = Sashite::Feen::Position::Hand.new([
    { piece: p1, count: 1 },
    { piece: p2, count: 1 },
    { piece: p3, count: 1 }
  ])
  raise "wrong string: #{hand.to_s}" unless hand.to_s == "PBN"
end

run_test("returns '2P3BN' for mixed counts") do
  p1 = Sashite::Epin.parse("P")
  p2 = Sashite::Epin.parse("B")
  p3 = Sashite::Epin.parse("N")
  hand = Sashite::Feen::Position::Hand.new([
    { piece: p1, count: 2 },
    { piece: p2, count: 3 },
    { piece: p3, count: 1 }
  ])
  raise "wrong string: #{hand.to_s}" unless hand.to_s == "2P3BN"
end

run_test("handles EPIN modifiers") do
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

run_test("different order is not ==") do
  p1 = Sashite::Epin.parse("P")
  p2 = Sashite::Epin.parse("B")
  hand1 = Sashite::Feen::Position::Hand.new([{ piece: p1, count: 1 }, { piece: p2, count: 1 }])
  hand2 = Sashite::Feen::Position::Hand.new([{ piece: p2, count: 1 }, { piece: p1, count: 1 }])
  raise "should not be equal" if hand1 == hand2
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

puts
puts "All Position::Hands tests passed!"
puts
