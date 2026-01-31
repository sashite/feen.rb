#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/parser/hands"
require_relative "../../../../lib/sashite/feen/position/hands"

puts
puts "=== Position::Hands Tests ==="
puts

# Helper to create Hands from FEEN hands string
def parse_hands(input)
  parsed = Sashite::Feen::Parser::Hands.parse(input)
  Sashite::Feen::Position::Hands.new(**parsed)
end

# ============================================================================
# INITIALIZATION
# ============================================================================

puts "Initialization:"

run_test("creates instance from parsed data") do
  hands = parse_hands("/")
  raise "wrong type" unless hands.is_a?(Sashite::Feen::Position::Hands)
end

run_test("creates instance with pieces in first hand") do
  hands = parse_hands("P/")
  raise "first should not be empty" if hands.first.empty?
  raise "second should be empty" unless hands.second.empty?
end

run_test("creates instance with pieces in second hand") do
  hands = parse_hands("/p")
  raise "first should be empty" unless hands.first.empty?
  raise "second should not be empty" if hands.second.empty?
end

run_test("creates instance with pieces in both hands") do
  hands = parse_hands("P/p")
  raise "first should not be empty" if hands.first.empty?
  raise "second should not be empty" if hands.second.empty?
end

run_test("instance is frozen") do
  hands = parse_hands("/")
  raise "should be frozen" unless hands.frozen?
end

# ============================================================================
# FIRST ACCESSOR
# ============================================================================

puts
puts "first accessor:"

run_test("returns Hand instance") do
  hands = parse_hands("/")
  raise "wrong type" unless hands.first.is_a?(Sashite::Feen::Position::Hands::Hand)
end

run_test("returns empty Hand for empty first") do
  hands = parse_hands("/p")
  raise "should be empty" unless hands.first.empty?
end

run_test("returns populated Hand for first with pieces") do
  hands = parse_hands("3B2P/")
  raise "should not be empty" if hands.first.empty?
  raise "wrong size" unless hands.first.size == 2
end

run_test("first Hand has correct pieces") do
  hands = parse_hands("3B2P/")
  raise "wrong pieces_count" unless hands.first.pieces_count == 5
end

# ============================================================================
# SECOND ACCESSOR
# ============================================================================

puts
puts "second accessor:"

run_test("returns Hand instance") do
  hands = parse_hands("/")
  raise "wrong type" unless hands.second.is_a?(Sashite::Feen::Position::Hands::Hand)
end

run_test("returns empty Hand for empty second") do
  hands = parse_hands("P/")
  raise "should be empty" unless hands.second.empty?
end

run_test("returns populated Hand for second with pieces") do
  hands = parse_hands("/3b2p")
  raise "should not be empty" if hands.second.empty?
  raise "wrong size" unless hands.second.size == 2
end

run_test("second Hand has correct pieces") do
  hands = parse_hands("/3b2p")
  raise "wrong pieces_count" unless hands.second.pieces_count == 5
end

# ============================================================================
# PIECES_COUNT
# ============================================================================

puts
puts "pieces_count:"

run_test("returns 0 for empty hands") do
  hands = parse_hands("/")
  raise "wrong count" unless hands.pieces_count == 0
end

run_test("returns count for first hand only") do
  hands = parse_hands("3P/")
  raise "wrong count" unless hands.pieces_count == 3
end

run_test("returns count for second hand only") do
  hands = parse_hands("/3p")
  raise "wrong count" unless hands.pieces_count == 3
end

run_test("returns sum of both hands") do
  hands = parse_hands("3P/2p")
  raise "wrong count" unless hands.pieces_count == 5
end

run_test("sums across multiple items in both hands") do
  hands = parse_hands("3B2PNR/2qp")
  # First: 3 + 2 + 1 + 1 = 7
  # Second: 2 + 1 = 3
  # Total: 10
  raise "wrong count" unless hands.pieces_count == 10
end

run_test("handles complex hands") do
  hands = parse_hands("99P/99p")
  raise "wrong count" unless hands.pieces_count == 198
end

# ============================================================================
# TO_S
# ============================================================================

puts
puts "to_s:"

run_test("serializes empty hands as '/'") do
  hands = parse_hands("/")
  raise "wrong string" unless hands.to_s == "/"
end

run_test("serializes first hand only") do
  hands = parse_hands("P/")
  raise "wrong string" unless hands.to_s == "P/"
end

run_test("serializes second hand only") do
  hands = parse_hands("/p")
  raise "wrong string" unless hands.to_s == "/p"
end

run_test("serializes both hands") do
  hands = parse_hands("P/p")
  raise "wrong string" unless hands.to_s == "P/p"
end

run_test("serializes complex hands") do
  hands = parse_hands("3B2PNR/2qp")
  raise "wrong string" unless hands.to_s == "3B2PNR/2qp"
end

run_test("serializes hands with modifiers") do
  hands = parse_hands("+P^'/+p^'")
  raise "wrong string" unless hands.to_s == "+P^'/+p^'"
end

run_test("round-trip preserves original") do
  inputs = ["/", "P/", "/p", "P/p", "3B2PNR/2qp", "+P^'/+p^'"]
  inputs.each do |input|
    hands = parse_hands(input)
    raise "round-trip failed for '#{input}'" unless hands.to_s == input
  end
end

# ============================================================================
# EQUALITY
# ============================================================================

puts
puts "Equality:"

run_test("equal hands are ==") do
  h1 = parse_hands("3B2P/p")
  h2 = parse_hands("3B2P/p")
  raise "should be equal" unless h1 == h2
end

run_test("different first hands are not ==") do
  h1 = parse_hands("3B2P/p")
  h2 = parse_hands("3B3P/p")
  raise "should not be equal" if h1 == h2
end

run_test("different second hands are not ==") do
  h1 = parse_hands("3B2P/p")
  h2 = parse_hands("3B2P/2p")
  raise "should not be equal" if h1 == h2
end

run_test("empty hands are equal") do
  h1 = parse_hands("/")
  h2 = parse_hands("/")
  raise "should be equal" unless h1 == h2
end

run_test("== returns false for non-Hands") do
  hands = parse_hands("P/p")
  raise "should not be equal to string" if hands == "P/p"
  raise "should not be equal to nil" if hands == nil
  raise "should not be equal to array" if hands == []
end

run_test("eql? is aliased to ==") do
  h1 = parse_hands("3B2P/p")
  h2 = parse_hands("3B2P/p")
  raise "eql? should work" unless h1.eql?(h2)
end

# ============================================================================
# HASH
# ============================================================================

puts
puts "Hash:"

run_test("equal hands have same hash") do
  h1 = parse_hands("3B2P/p")
  h2 = parse_hands("3B2P/p")
  raise "hashes should be equal" unless h1.hash == h2.hash
end

run_test("different hands have different hash") do
  h1 = parse_hands("3B2P/p")
  h2 = parse_hands("3B2P/2p")
  raise "hashes should differ" if h1.hash == h2.hash
end

run_test("empty hands have same hash") do
  h1 = parse_hands("/")
  h2 = parse_hands("/")
  raise "hashes should be equal" unless h1.hash == h2.hash
end

run_test("can be used as hash key") do
  h1 = parse_hands("3B2P/p")
  h2 = parse_hands("3B2P/p")
  hash = { h1 => "value" }
  raise "should find by equal key" unless hash[h2] == "value"
end

# ============================================================================
# INSPECT
# ============================================================================

puts
puts "Inspect:"

run_test("inspect includes class name") do
  hands = parse_hands("P/p")
  raise "should include class" unless hands.inspect.include?("Hands")
end

run_test("inspect includes string representation") do
  hands = parse_hands("3B2P/p")
  raise "should include to_s" unless hands.inspect.include?("3B2P/p")
end

run_test("inspect for empty hands") do
  hands = parse_hands("/")
  raise "should include class" unless hands.inspect.include?("Hands")
  raise "should include separator" unless hands.inspect.include?("/")
end

run_test("inspect format is #<Class string>") do
  hands = parse_hands("P/p")
  raise "wrong format" unless hands.inspect.match?(/^#<.*Hands.*P\/p>$/)
end

# ============================================================================
# INTEGRATION WITH HAND
# ============================================================================

puts
puts "Integration with Hand:"

run_test("first hand iteration works") do
  hands = parse_hands("3B2P/")
  pieces = []
  hands.first.each { |piece, _| pieces << piece.to_s }
  raise "wrong pieces" unless pieces == ["B", "P"]
end

run_test("second hand iteration works") do
  hands = parse_hands("/3b2p")
  pieces = []
  hands.second.each { |piece, _| pieces << piece.to_s }
  raise "wrong pieces" unless pieces == ["b", "p"]
end

run_test("can access individual counts") do
  hands = parse_hands("3B2P/5q")
  raise "wrong B count" unless hands.first.items[0][:count] == 3
  raise "wrong P count" unless hands.first.items[1][:count] == 2
  raise "wrong q count" unless hands.second.items[0][:count] == 5
end

run_test("Hand objects are frozen") do
  hands = parse_hands("P/p")
  raise "first should be frozen" unless hands.first.frozen?
  raise "second should be frozen" unless hands.second.frozen?
end

# ============================================================================
# CLASS STRUCTURE
# ============================================================================

puts
puts "Class structure:"

run_test("Hands is a Class") do
  raise "wrong type" unless Sashite::Feen::Position::Hands.is_a?(Class)
end

run_test("Hands is nested under Position") do
  raise "wrong nesting" unless Sashite::Feen::Position.const_defined?(:Hands)
end

run_test("Hand is nested under Hands") do
  raise "wrong nesting" unless Sashite::Feen::Position::Hands.const_defined?(:Hand)
end

puts
puts "All Position::Hands tests passed!"
puts
