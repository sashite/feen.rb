#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../../lib/sashite/feen/position/style_turn"
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
puts "=== Position::StyleTurn Tests ==="
puts

# ============================================================================
# CONSTRUCTOR TESTS
# ============================================================================

puts "Constructor:"

run_test("creates StyleTurn with active and inactive styles") do
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")
  st = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)
  raise "wrong active" unless st.active_style == active
  raise "wrong inactive" unless st.inactive_style == inactive
end

run_test("creates StyleTurn with different styles") do
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("s")
  st = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)
  raise "wrong active abbr" unless st.active_style.abbr == :C
  raise "wrong inactive abbr" unless st.inactive_style.abbr == :S
end

run_test("creates StyleTurn with second player active") do
  active = Sashite::Sin.parse("c")
  inactive = Sashite::Sin.parse("C")
  st = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)
  raise "wrong active side" unless st.active_style.side == :second
  raise "wrong inactive side" unless st.inactive_style.side == :first
end

# ============================================================================
# IMMUTABILITY TESTS
# ============================================================================

puts
puts "Immutability:"

run_test("StyleTurn is frozen after creation") do
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")
  st = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)
  raise "should be frozen" unless st.frozen?
end

# ============================================================================
# ATTRIBUTE ACCESSORS
# ============================================================================

puts
puts "Attribute accessors:"

run_test("active_style returns the active Sin::Identifier") do
  active = Sashite::Sin.parse("S")
  inactive = Sashite::Sin.parse("s")
  st = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)
  raise "wrong type" unless st.active_style.is_a?(Sashite::Sin::Identifier)
  raise "wrong abbr" unless st.active_style.abbr == :S
  raise "wrong side" unless st.active_style.side == :first
end

run_test("inactive_style returns the inactive Sin::Identifier") do
  active = Sashite::Sin.parse("S")
  inactive = Sashite::Sin.parse("s")
  st = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)
  raise "wrong type" unless st.inactive_style.is_a?(Sashite::Sin::Identifier)
  raise "wrong abbr" unless st.inactive_style.abbr == :S
  raise "wrong side" unless st.inactive_style.side == :second
end

# ============================================================================
# FIRST_TO_MOVE? TESTS
# ============================================================================

puts
puts "first_to_move?:"

run_test("returns true when first player is active") do
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")
  st = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)
  raise "should be true" unless st.first_to_move?
end

run_test("returns false when second player is active") do
  active = Sashite::Sin.parse("c")
  inactive = Sashite::Sin.parse("C")
  st = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)
  raise "should be false" if st.first_to_move?
end

run_test("returns true for cross-style with uppercase active") do
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("s")
  st = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)
  raise "should be true" unless st.first_to_move?
end

# ============================================================================
# SECOND_TO_MOVE? TESTS
# ============================================================================

puts
puts "second_to_move?:"

run_test("returns true when second player is active") do
  active = Sashite::Sin.parse("c")
  inactive = Sashite::Sin.parse("C")
  st = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)
  raise "should be true" unless st.second_to_move?
end

run_test("returns false when first player is active") do
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")
  st = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)
  raise "should be false" if st.second_to_move?
end

run_test("returns true for cross-style with lowercase active") do
  active = Sashite::Sin.parse("s")
  inactive = Sashite::Sin.parse("C")
  st = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)
  raise "should be true" unless st.second_to_move?
end

# ============================================================================
# FIRST_TO_MOVE? AND SECOND_TO_MOVE? MUTUAL EXCLUSION
# ============================================================================

puts
puts "Mutual exclusion:"

run_test("first_to_move? and second_to_move? are mutually exclusive") do
  active1 = Sashite::Sin.parse("C")
  inactive1 = Sashite::Sin.parse("c")
  st1 = Sashite::Feen::Position::StyleTurn.new(active: active1, inactive: inactive1)

  active2 = Sashite::Sin.parse("c")
  inactive2 = Sashite::Sin.parse("C")
  st2 = Sashite::Feen::Position::StyleTurn.new(active: active2, inactive: inactive2)

  raise "st1: should be exclusive" if st1.first_to_move? == st1.second_to_move?
  raise "st2: should be exclusive" if st2.first_to_move? == st2.second_to_move?
end

# ============================================================================
# TO_S TESTS
# ============================================================================

puts
puts "to_s:"

run_test("returns 'C/c' for Chess first to move") do
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")
  st = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)
  raise "wrong string: #{st.to_s}" unless st.to_s == "C/c"
end

run_test("returns 'c/C' for Chess second to move") do
  active = Sashite::Sin.parse("c")
  inactive = Sashite::Sin.parse("C")
  st = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)
  raise "wrong string: #{st.to_s}" unless st.to_s == "c/C"
end

run_test("returns 'S/s' for Shogi first to move") do
  active = Sashite::Sin.parse("S")
  inactive = Sashite::Sin.parse("s")
  st = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)
  raise "wrong string: #{st.to_s}" unless st.to_s == "S/s"
end

run_test("returns 's/S' for Shogi second to move") do
  active = Sashite::Sin.parse("s")
  inactive = Sashite::Sin.parse("S")
  st = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)
  raise "wrong string: #{st.to_s}" unless st.to_s == "s/S"
end

run_test("returns 'C/s' for cross-style Chess vs Shogi") do
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("s")
  st = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)
  raise "wrong string: #{st.to_s}" unless st.to_s == "C/s"
end

run_test("returns 's/C' for cross-style Shogi vs Chess") do
  active = Sashite::Sin.parse("s")
  inactive = Sashite::Sin.parse("C")
  st = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)
  raise "wrong string: #{st.to_s}" unless st.to_s == "s/C"
end

# ============================================================================
# EQUALITY TESTS
# ============================================================================

puts
puts "Equality:"

run_test("equal StyleTurns are ==") do
  active1 = Sashite::Sin.parse("C")
  inactive1 = Sashite::Sin.parse("c")
  st1 = Sashite::Feen::Position::StyleTurn.new(active: active1, inactive: inactive1)

  active2 = Sashite::Sin.parse("C")
  inactive2 = Sashite::Sin.parse("c")
  st2 = Sashite::Feen::Position::StyleTurn.new(active: active2, inactive: inactive2)

  raise "should be equal" unless st1 == st2
end

run_test("different active styles are not ==") do
  active1 = Sashite::Sin.parse("C")
  inactive1 = Sashite::Sin.parse("c")
  st1 = Sashite::Feen::Position::StyleTurn.new(active: active1, inactive: inactive1)

  active2 = Sashite::Sin.parse("c")
  inactive2 = Sashite::Sin.parse("C")
  st2 = Sashite::Feen::Position::StyleTurn.new(active: active2, inactive: inactive2)

  raise "should not be equal" if st1 == st2
end

run_test("different style abbreviations are not ==") do
  active1 = Sashite::Sin.parse("C")
  inactive1 = Sashite::Sin.parse("c")
  st1 = Sashite::Feen::Position::StyleTurn.new(active: active1, inactive: inactive1)

  active2 = Sashite::Sin.parse("S")
  inactive2 = Sashite::Sin.parse("s")
  st2 = Sashite::Feen::Position::StyleTurn.new(active: active2, inactive: inactive2)

  raise "should not be equal" if st1 == st2
end

run_test("eql? is aliased to ==") do
  active1 = Sashite::Sin.parse("C")
  inactive1 = Sashite::Sin.parse("c")
  st1 = Sashite::Feen::Position::StyleTurn.new(active: active1, inactive: inactive1)

  active2 = Sashite::Sin.parse("C")
  inactive2 = Sashite::Sin.parse("c")
  st2 = Sashite::Feen::Position::StyleTurn.new(active: active2, inactive: inactive2)

  raise "eql? should work" unless st1.eql?(st2)
end

run_test("equal StyleTurns have same hash") do
  active1 = Sashite::Sin.parse("C")
  inactive1 = Sashite::Sin.parse("c")
  st1 = Sashite::Feen::Position::StyleTurn.new(active: active1, inactive: inactive1)

  active2 = Sashite::Sin.parse("C")
  inactive2 = Sashite::Sin.parse("c")
  st2 = Sashite::Feen::Position::StyleTurn.new(active: active2, inactive: inactive2)

  raise "hash should match" unless st1.hash == st2.hash
end

run_test("can be used as hash key") do
  active = Sashite::Sin.parse("C")
  inactive = Sashite::Sin.parse("c")
  st1 = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)
  st2 = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)

  hash = { st1 => "value" }
  raise "should find by equal key" unless hash[st2] == "value"
end

# ============================================================================
# ALL LETTERS
# ============================================================================

puts
puts "All letters:"

run_test("works with all uppercase/lowercase letter pairs") do
  ("A".."Z").each do |letter|
    active = Sashite::Sin.parse(letter)
    inactive = Sashite::Sin.parse(letter.downcase)
    st = Sashite::Feen::Position::StyleTurn.new(active: active, inactive: inactive)

    expected = "#{letter}/#{letter.downcase}"
    raise "wrong string for #{letter}" unless st.to_s == expected
    raise "should be first to move for #{letter}" unless st.first_to_move?
  end
end

puts
puts "All Position::StyleTurn tests passed!"
puts
