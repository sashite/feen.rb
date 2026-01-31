#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../../helper"
require_relative "../../../../../lib/sashite/feen/parser/hands"
require_relative "../../../../../lib/sashite/feen/position/hands"

puts
puts "=== Position::Hands::Hand Tests ==="
puts

# Helper to create Hand from FEEN hand string
def parse_hand(input)
  # Parse as first hand (input/)
  parsed = Sashite::Feen::Parser::Hands.parse("#{input}/")
  Sashite::Feen::Position::Hands::Hand.new(parsed[:first])
end

# ============================================================================
# INITIALIZATION
# ============================================================================

puts "Initialization:"

run_test("creates instance from parsed data") do
  hand = parse_hand("P")
  raise "wrong type" unless hand.is_a?(Sashite::Feen::Position::Hands::Hand)
end

run_test("creates empty hand") do
  hand = parse_hand("")
  raise "should be empty" unless hand.empty?
end

run_test("instance is frozen") do
  hand = parse_hand("P")
  raise "should be frozen" unless hand.frozen?
end

run_test("items accessor returns items") do
  hand = parse_hand("2P")
  raise "wrong items count" unless hand.items.size == 1
end

run_test("items contain :piece and :count") do
  hand = parse_hand("2P")
  item = hand.items[0]
  raise "missing :piece" unless item.key?(:piece)
  raise "missing :count" unless item.key?(:count)
end

# ============================================================================
# EMPTY?
# ============================================================================

puts
puts "empty?:"

run_test("returns true for empty hand") do
  hand = parse_hand("")
  raise "should be empty" unless hand.empty?
end

run_test("returns false for hand with one item") do
  hand = parse_hand("P")
  raise "should not be empty" if hand.empty?
end

run_test("returns false for hand with multiple items") do
  hand = parse_hand("BNR")
  raise "should not be empty" if hand.empty?
end

# ============================================================================
# SIZE
# ============================================================================

puts
puts "size:"

run_test("returns 0 for empty hand") do
  hand = parse_hand("")
  raise "wrong size" unless hand.size == 0
end

run_test("returns 1 for single item") do
  hand = parse_hand("P")
  raise "wrong size" unless hand.size == 1
end

run_test("returns 1 for single item with count") do
  hand = parse_hand("3P")
  raise "wrong size" unless hand.size == 1
end

run_test("returns number of distinct piece types") do
  hand = parse_hand("BNR")
  raise "wrong size" unless hand.size == 3
end

run_test("returns correct size for mixed counts") do
  hand = parse_hand("3B2PN")
  raise "wrong size" unless hand.size == 3
end

# ============================================================================
# PIECES_COUNT
# ============================================================================

puts
puts "pieces_count:"

run_test("returns 0 for empty hand") do
  hand = parse_hand("")
  raise "wrong count" unless hand.pieces_count == 0
end

run_test("returns 1 for single implicit piece") do
  hand = parse_hand("P")
  raise "wrong count" unless hand.pieces_count == 1
end

run_test("returns count for explicit multiplicity") do
  hand = parse_hand("3P")
  raise "wrong count" unless hand.pieces_count == 3
end

run_test("sums counts across items") do
  hand = parse_hand("3B2P")
  raise "wrong count" unless hand.pieces_count == 5
end

run_test("sums mixed implicit and explicit counts") do
  hand = parse_hand("3BNR")
  raise "wrong count" unless hand.pieces_count == 5
end

run_test("handles large counts") do
  hand = parse_hand("99P")
  raise "wrong count" unless hand.pieces_count == 99
end

# ============================================================================
# EACH
# ============================================================================

puts
puts "each:"

run_test("yields nothing for empty hand") do
  hand = parse_hand("")
  count = 0
  hand.each { count += 1 }
  raise "should yield nothing" unless count == 0
end

run_test("yields piece and count for each item") do
  hand = parse_hand("2P")
  hand.each do |piece, count|
    raise "piece should be Epin::Identifier" unless piece.is_a?(Sashite::Epin::Identifier)
    raise "count should be Integer" unless count.is_a?(Integer)
    raise "wrong count" unless count == 2
  end
end

run_test("yields each item in order") do
  hand = parse_hand("BNR")
  pieces = []
  hand.each { |piece, _| pieces << piece.to_s }
  raise "wrong order" unless pieces == ["B", "N", "R"]
end

run_test("yields correct counts") do
  hand = parse_hand("3B2PN")
  counts = []
  hand.each { |_, count| counts << count }
  raise "wrong counts" unless counts == [3, 2, 1]
end

run_test("returns Enumerator when no block given") do
  hand = parse_hand("P")
  enum = hand.each
  raise "wrong type" unless enum.is_a?(Enumerator)
end

run_test("Enumerator works correctly") do
  hand = parse_hand("BN")
  result = hand.each.to_a
  raise "wrong count" unless result.size == 2
  raise "wrong structure" unless result[0].is_a?(Array)
  raise "wrong element count" unless result[0].size == 2
end

# ============================================================================
# ENUMERABLE
# ============================================================================

puts
puts "Enumerable:"

run_test("includes Enumerable") do
  raise "should include Enumerable" unless Sashite::Feen::Position::Hands::Hand.include?(Enumerable)
end

run_test("responds to map") do
  hand = parse_hand("P")
  raise "should respond to map" unless hand.respond_to?(:map)
end

run_test("responds to select") do
  hand = parse_hand("P")
  raise "should respond to select" unless hand.respond_to?(:select)
end

run_test("responds to any?") do
  hand = parse_hand("P")
  raise "should respond to any?" unless hand.respond_to?(:any?)
end

run_test("map works correctly") do
  hand = parse_hand("BN")
  result = hand.map { |piece, count| "#{count}x#{piece}" }
  raise "wrong result" unless result == ["1xB", "1xN"]
end

run_test("select works correctly") do
  hand = parse_hand("3B2PN")
  high_count = hand.select { |_, count| count >= 2 }
  raise "wrong count" unless high_count.size == 2
end

run_test("any? works correctly") do
  hand = parse_hand("3BN")
  raise "should find high count" unless hand.any? { |_, count| count > 2 }
  raise "should not find very high" if hand.any? { |_, count| count > 10 }
end

run_test("to_a works correctly") do
  hand = parse_hand("BN")
  array = hand.to_a
  raise "wrong size" unless array.size == 2
  raise "elements should be arrays" unless array.all? { |e| e.is_a?(Array) }
end

# ============================================================================
# TO_S
# ============================================================================

puts
puts "to_s:"

run_test("serializes empty hand as empty string") do
  hand = parse_hand("")
  raise "wrong string" unless hand.to_s == ""
end

run_test("serializes single piece without count") do
  hand = parse_hand("P")
  raise "wrong string" unless hand.to_s == "P"
end

run_test("serializes piece with count >= 2") do
  hand = parse_hand("3P")
  raise "wrong string" unless hand.to_s == "3P"
end

run_test("serializes multiple items") do
  hand = parse_hand("BNR")
  raise "wrong string" unless hand.to_s == "BNR"
end

run_test("serializes mixed counts") do
  hand = parse_hand("3B2PN")
  raise "wrong string" unless hand.to_s == "3B2PN"
end

run_test("serializes pieces with modifiers") do
  hand = parse_hand("+P^'")
  raise "wrong string" unless hand.to_s == "+P^'"
end

run_test("serializes count with modifiers") do
  hand = parse_hand("3+P^'")
  raise "wrong string" unless hand.to_s == "3+P^'"
end

run_test("round-trip preserves original") do
  inputs = ["", "P", "3P", "BNR", "3B2PN", "+P^'", "3+P^'"]
  inputs.each do |input|
    hand = parse_hand(input)
    raise "round-trip failed for '#{input}'" unless hand.to_s == input
  end
end

# ============================================================================
# EQUALITY
# ============================================================================

puts
puts "Equality:"

run_test("equal hands are ==") do
  h1 = parse_hand("3B2P")
  h2 = parse_hand("3B2P")
  raise "should be equal" unless h1 == h2
end

run_test("different hands are not ==") do
  h1 = parse_hand("3B2P")
  h2 = parse_hand("3B3P")
  raise "should not be equal" if h1 == h2
end

run_test("empty hands are equal") do
  h1 = parse_hand("")
  h2 = parse_hand("")
  raise "should be equal" unless h1 == h2
end

run_test("== returns false for non-Hand") do
  hand = parse_hand("P")
  raise "should not be equal to string" if hand == "P"
  raise "should not be equal to nil" if hand == nil
  raise "should not be equal to array" if hand == []
end

run_test("eql? is aliased to ==") do
  h1 = parse_hand("3B2P")
  h2 = parse_hand("3B2P")
  raise "eql? should work" unless h1.eql?(h2)
end

# ============================================================================
# HASH
# ============================================================================

puts
puts "Hash:"

run_test("equal hands have same hash") do
  h1 = parse_hand("3B2P")
  h2 = parse_hand("3B2P")
  raise "hashes should be equal" unless h1.hash == h2.hash
end

run_test("different hands have different hash") do
  h1 = parse_hand("3B2P")
  h2 = parse_hand("3B3P")
  raise "hashes should differ" if h1.hash == h2.hash
end

run_test("empty hands have same hash") do
  h1 = parse_hand("")
  h2 = parse_hand("")
  raise "hashes should be equal" unless h1.hash == h2.hash
end

run_test("can be used as hash key") do
  h1 = parse_hand("3B2P")
  h2 = parse_hand("3B2P")
  hash = { h1 => "value" }
  raise "should find by equal key" unless hash[h2] == "value"
end

# ============================================================================
# INSPECT
# ============================================================================

puts
puts "Inspect:"

run_test("inspect includes class name") do
  hand = parse_hand("P")
  raise "should include class" unless hand.inspect.include?("Hand")
end

run_test("inspect includes string representation") do
  hand = parse_hand("3B2P")
  raise "should include to_s" unless hand.inspect.include?("3B2P")
end

run_test("inspect for empty hand") do
  hand = parse_hand("")
  raise "should include class" unless hand.inspect.include?("Hand")
end

run_test("inspect format is #<Class string>") do
  hand = parse_hand("P")
  raise "wrong format" unless hand.inspect.match?(/^#<.*Hand.*P>$/)
end

# ============================================================================
# CLASS STRUCTURE
# ============================================================================

puts
puts "Class structure:"

run_test("Hand is a Class") do
  raise "wrong type" unless Sashite::Feen::Position::Hands::Hand.is_a?(Class)
end

run_test("Hand is nested under Hands") do
  raise "wrong nesting" unless Sashite::Feen::Position::Hands.const_defined?(:Hand)
end

puts
puts "All Position::Hands::Hand tests passed!"
puts
