#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/parser/style_turn"
require_relative "../../../../lib/sashite/feen/position/style_turn"

puts
puts "=== Position::StyleTurn Tests ==="
puts

# Helper to create StyleTurn from FEEN style-turn string
def parse_style_turn(input)
  parsed = Sashite::Feen::Parser::StyleTurn.parse(input)
  Sashite::Feen::Position::StyleTurn.new(**parsed)
end

# ============================================================================
# INITIALIZATION
# ============================================================================

puts "Initialization:"

run_test("creates instance from parsed data") do
  style_turn = parse_style_turn("C/c")
  raise "wrong type" unless style_turn.is_a?(Sashite::Feen::Position::StyleTurn)
end

run_test("instance is frozen") do
  style_turn = parse_style_turn("C/c")
  raise "should be frozen" unless style_turn.frozen?
end

run_test("creates instance with first player active") do
  style_turn = parse_style_turn("C/c")
  raise "should be first to move" unless style_turn.first_to_move?
end

run_test("creates instance with second player active") do
  style_turn = parse_style_turn("c/C")
  raise "should be second to move" unless style_turn.second_to_move?
end

# ============================================================================
# ACTIVE_STYLE ACCESSOR
# ============================================================================

puts
puts "active_style accessor:"

run_test("returns Sin::Identifier") do
  style_turn = parse_style_turn("C/c")
  raise "wrong type" unless style_turn.active_style.is_a?(Sashite::Sin::Identifier)
end

run_test("returns correct style for first player active") do
  style_turn = parse_style_turn("C/c")
  raise "wrong abbr" unless style_turn.active_style.abbr == :C
  raise "wrong side" unless style_turn.active_style.side == :first
end

run_test("returns correct style for second player active") do
  style_turn = parse_style_turn("c/C")
  raise "wrong abbr" unless style_turn.active_style.abbr == :C
  raise "wrong side" unless style_turn.active_style.side == :second
end

run_test("returns correct style for cross-style game") do
  style_turn = parse_style_turn("C/s")
  raise "wrong abbr" unless style_turn.active_style.abbr == :C
end

run_test("active_style responds to abbr") do
  style_turn = parse_style_turn("S/s")
  raise "should respond to abbr" unless style_turn.active_style.respond_to?(:abbr)
  raise "wrong abbr" unless style_turn.active_style.abbr == :S
end

run_test("active_style responds to side") do
  style_turn = parse_style_turn("S/s")
  raise "should respond to side" unless style_turn.active_style.respond_to?(:side)
  raise "wrong side" unless style_turn.active_style.side == :first
end

# ============================================================================
# INACTIVE_STYLE ACCESSOR
# ============================================================================

puts
puts "inactive_style accessor:"

run_test("returns Sin::Identifier") do
  style_turn = parse_style_turn("C/c")
  raise "wrong type" unless style_turn.inactive_style.is_a?(Sashite::Sin::Identifier)
end

run_test("returns correct style for first player active") do
  style_turn = parse_style_turn("C/c")
  raise "wrong abbr" unless style_turn.inactive_style.abbr == :C
  raise "wrong side" unless style_turn.inactive_style.side == :second
end

run_test("returns correct style for second player active") do
  style_turn = parse_style_turn("c/C")
  raise "wrong abbr" unless style_turn.inactive_style.abbr == :C
  raise "wrong side" unless style_turn.inactive_style.side == :first
end

run_test("returns correct style for cross-style game") do
  style_turn = parse_style_turn("C/s")
  raise "wrong abbr" unless style_turn.inactive_style.abbr == :S
  raise "wrong side" unless style_turn.inactive_style.side == :second
end

run_test("inactive_style responds to abbr") do
  style_turn = parse_style_turn("S/s")
  raise "should respond to abbr" unless style_turn.inactive_style.respond_to?(:abbr)
  raise "wrong abbr" unless style_turn.inactive_style.abbr == :S
end

run_test("inactive_style responds to side") do
  style_turn = parse_style_turn("S/s")
  raise "should respond to side" unless style_turn.inactive_style.respond_to?(:side)
  raise "wrong side" unless style_turn.inactive_style.side == :second
end

# ============================================================================
# FIRST_TO_MOVE?
# ============================================================================

puts
puts "first_to_move?:"

run_test("returns true when uppercase is active") do
  style_turn = parse_style_turn("C/c")
  raise "should be true" unless style_turn.first_to_move?
end

run_test("returns false when lowercase is active") do
  style_turn = parse_style_turn("c/C")
  raise "should be false" if style_turn.first_to_move?
end

run_test("returns true for S/s") do
  style_turn = parse_style_turn("S/s")
  raise "should be true" unless style_turn.first_to_move?
end

run_test("returns true for X/x") do
  style_turn = parse_style_turn("X/x")
  raise "should be true" unless style_turn.first_to_move?
end

run_test("returns true for cross-style C/s") do
  style_turn = parse_style_turn("C/s")
  raise "should be true" unless style_turn.first_to_move?
end

run_test("returns false for cross-style s/C") do
  style_turn = parse_style_turn("s/C")
  raise "should be false" if style_turn.first_to_move?
end

# ============================================================================
# SECOND_TO_MOVE?
# ============================================================================

puts
puts "second_to_move?:"

run_test("returns false when uppercase is active") do
  style_turn = parse_style_turn("C/c")
  raise "should be false" if style_turn.second_to_move?
end

run_test("returns true when lowercase is active") do
  style_turn = parse_style_turn("c/C")
  raise "should be true" unless style_turn.second_to_move?
end

run_test("returns true for s/S") do
  style_turn = parse_style_turn("s/S")
  raise "should be true" unless style_turn.second_to_move?
end

run_test("returns true for x/X") do
  style_turn = parse_style_turn("x/X")
  raise "should be true" unless style_turn.second_to_move?
end

run_test("returns false for cross-style C/s") do
  style_turn = parse_style_turn("C/s")
  raise "should be false" if style_turn.second_to_move?
end

run_test("returns true for cross-style s/C") do
  style_turn = parse_style_turn("s/C")
  raise "should be true" unless style_turn.second_to_move?
end

# ============================================================================
# MUTUAL EXCLUSIVITY
# ============================================================================

puts
puts "Mutual exclusivity:"

run_test("first_to_move? and second_to_move? are mutually exclusive (first)") do
  style_turn = parse_style_turn("C/c")
  raise "should be mutually exclusive" if style_turn.first_to_move? == style_turn.second_to_move?
end

run_test("first_to_move? and second_to_move? are mutually exclusive (second)") do
  style_turn = parse_style_turn("c/C")
  raise "should be mutually exclusive" if style_turn.first_to_move? == style_turn.second_to_move?
end

run_test("exactly one is true for any valid style-turn") do
  ["C/c", "c/C", "S/s", "s/S", "C/s", "s/C"].each do |input|
    style_turn = parse_style_turn(input)
    first = style_turn.first_to_move?
    second = style_turn.second_to_move?
    raise "exactly one should be true for #{input}" unless first ^ second
  end
end

# ============================================================================
# TO_S
# ============================================================================

puts
puts "to_s:"

run_test("serializes C/c") do
  style_turn = parse_style_turn("C/c")
  raise "wrong string" unless style_turn.to_s == "C/c"
end

run_test("serializes c/C") do
  style_turn = parse_style_turn("c/C")
  raise "wrong string" unless style_turn.to_s == "c/C"
end

run_test("serializes S/s") do
  style_turn = parse_style_turn("S/s")
  raise "wrong string" unless style_turn.to_s == "S/s"
end

run_test("serializes cross-style C/s") do
  style_turn = parse_style_turn("C/s")
  raise "wrong string" unless style_turn.to_s == "C/s"
end

run_test("serializes cross-style s/C") do
  style_turn = parse_style_turn("s/C")
  raise "wrong string" unless style_turn.to_s == "s/C"
end

run_test("round-trip preserves original") do
  inputs = ["C/c", "c/C", "S/s", "s/S", "X/x", "x/X", "C/s", "s/C", "A/z", "z/A"]
  inputs.each do |input|
    style_turn = parse_style_turn(input)
    raise "round-trip failed for '#{input}'" unless style_turn.to_s == input
  end
end

# ============================================================================
# EQUALITY
# ============================================================================

puts
puts "Equality:"

run_test("equal style-turns are ==") do
  st1 = parse_style_turn("C/c")
  st2 = parse_style_turn("C/c")
  raise "should be equal" unless st1 == st2
end

run_test("different active styles are not ==") do
  st1 = parse_style_turn("C/c")
  st2 = parse_style_turn("S/s")
  raise "should not be equal" if st1 == st2
end

run_test("different turn order is not ==") do
  st1 = parse_style_turn("C/c")
  st2 = parse_style_turn("c/C")
  raise "should not be equal" if st1 == st2
end

run_test("cross-style vs same-style are not ==") do
  st1 = parse_style_turn("C/c")
  st2 = parse_style_turn("C/s")
  raise "should not be equal" if st1 == st2
end

run_test("== returns false for non-StyleTurn") do
  style_turn = parse_style_turn("C/c")
  raise "should not be equal to string" if style_turn == "C/c"
  raise "should not be equal to nil" if style_turn == nil
  raise "should not be equal to array" if style_turn == []
end

run_test("eql? is aliased to ==") do
  st1 = parse_style_turn("C/c")
  st2 = parse_style_turn("C/c")
  raise "eql? should work" unless st1.eql?(st2)
end

# ============================================================================
# HASH
# ============================================================================

puts
puts "Hash:"

run_test("equal style-turns have same hash") do
  st1 = parse_style_turn("C/c")
  st2 = parse_style_turn("C/c")
  raise "hashes should be equal" unless st1.hash == st2.hash
end

run_test("different style-turns have different hash") do
  st1 = parse_style_turn("C/c")
  st2 = parse_style_turn("c/C")
  raise "hashes should differ" if st1.hash == st2.hash
end

run_test("different styles have different hash") do
  st1 = parse_style_turn("C/c")
  st2 = parse_style_turn("S/s")
  raise "hashes should differ" if st1.hash == st2.hash
end

run_test("can be used as hash key") do
  st1 = parse_style_turn("C/c")
  st2 = parse_style_turn("C/c")
  hash = { st1 => "value" }
  raise "should find by equal key" unless hash[st2] == "value"
end

# ============================================================================
# INSPECT
# ============================================================================

puts
puts "Inspect:"

run_test("inspect includes class name") do
  style_turn = parse_style_turn("C/c")
  raise "should include class" unless style_turn.inspect.include?("StyleTurn")
end

run_test("inspect includes string representation") do
  style_turn = parse_style_turn("C/c")
  raise "should include to_s" unless style_turn.inspect.include?("C/c")
end

run_test("inspect format is #<Class string>") do
  style_turn = parse_style_turn("C/c")
  raise "wrong format" unless style_turn.inspect.match?(/^#<.*StyleTurn.*C\/c>$/)
end

# ============================================================================
# CLASS STRUCTURE
# ============================================================================

puts
puts "Class structure:"

run_test("StyleTurn is a Class") do
  raise "wrong type" unless Sashite::Feen::Position::StyleTurn.is_a?(Class)
end

run_test("StyleTurn is nested under Position") do
  raise "wrong nesting" unless Sashite::Feen::Position.const_defined?(:StyleTurn)
end

puts
puts "All Position::StyleTurn tests passed!"
puts
