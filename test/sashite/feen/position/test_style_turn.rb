#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/position/style_turn"

puts
puts "=== Position::StyleTurn Tests ==="
puts

StyleTurn = Sashite::Feen::Position::StyleTurn

# Mock style object that responds to :side and :to_s
MockStyle = Struct.new(:side, :abbr) do
  def to_s
    side == :first ? abbr.to_s.upcase : abbr.to_s.downcase
  end
end

# ============================================================================
# INITIALIZATION
# ============================================================================

puts "initialization:"

run_test("creates instance with valid styles") do
  active = MockStyle.new(:first, :C)
  inactive = MockStyle.new(:second, :C)
  st = StyleTurn.send(:new, active: active, inactive: inactive)
  raise "expected StyleTurn instance" unless StyleTurn === st
end

run_test("accepts any object responding to :side for active") do
  active = MockStyle.new(:second, :S)
  inactive = MockStyle.new(:first, :C)
  st = StyleTurn.send(:new, active: active, inactive: inactive)
  raise "expected StyleTurn instance" unless StyleTurn === st
end

run_test("raises ArgumentError when active does not respond to :side") do
  inactive = MockStyle.new(:second, :C)
  StyleTurn.send(:new, active: "not a style", inactive: inactive)
  raise "expected ArgumentError"
rescue ArgumentError => e
  raise "wrong message" unless e.message.include?("active must respond to :side")
end

run_test("raises ArgumentError when inactive does not respond to :side") do
  active = MockStyle.new(:first, :C)
  StyleTurn.send(:new, active: active, inactive: "not a style")
  raise "expected ArgumentError"
rescue ArgumentError => e
  raise "wrong message" unless e.message.include?("inactive must respond to :side")
end

run_test("raises ArgumentError when active is nil") do
  inactive = MockStyle.new(:second, :C)
  StyleTurn.send(:new, active: nil, inactive: inactive)
  raise "expected ArgumentError"
rescue ArgumentError => e
  raise "wrong message" unless e.message.include?("active must respond to :side")
end

run_test("raises ArgumentError when inactive is nil") do
  active = MockStyle.new(:first, :C)
  StyleTurn.send(:new, active: active, inactive: nil)
  raise "expected ArgumentError"
rescue ArgumentError => e
  raise "wrong message" unless e.message.include?("inactive must respond to :side")
end

# ============================================================================
# ACCESSORS
# ============================================================================

puts
puts "accessors:"

run_test("active_style returns the active style") do
  active = MockStyle.new(:first, :C)
  inactive = MockStyle.new(:second, :C)
  st = StyleTurn.send(:new, active: active, inactive: inactive)
  raise "wrong active_style" unless st.active_style == active
end

run_test("inactive_style returns the inactive style") do
  active = MockStyle.new(:first, :C)
  inactive = MockStyle.new(:second, :C)
  st = StyleTurn.send(:new, active: active, inactive: inactive)
  raise "wrong inactive_style" unless st.inactive_style == inactive
end

# ============================================================================
# FIRST_TO_MOVE?
# ============================================================================

puts
puts "first_to_move?:"

run_test("returns true when active side is :first") do
  active = MockStyle.new(:first, :C)
  inactive = MockStyle.new(:second, :C)
  st = StyleTurn.send(:new, active: active, inactive: inactive)
  raise "expected true" unless st.first_to_move? == true
end

run_test("returns false when active side is :second") do
  active = MockStyle.new(:second, :C)
  inactive = MockStyle.new(:first, :C)
  st = StyleTurn.send(:new, active: active, inactive: inactive)
  raise "expected false" unless st.first_to_move? == false
end

run_test("works with cross-style game (first to move)") do
  active = MockStyle.new(:first, :C)
  inactive = MockStyle.new(:second, :S)
  st = StyleTurn.send(:new, active: active, inactive: inactive)
  raise "expected true" unless st.first_to_move? == true
end

# ============================================================================
# SECOND_TO_MOVE?
# ============================================================================

puts
puts "second_to_move?:"

run_test("returns true when active side is :second") do
  active = MockStyle.new(:second, :C)
  inactive = MockStyle.new(:first, :C)
  st = StyleTurn.send(:new, active: active, inactive: inactive)
  raise "expected true" unless st.second_to_move? == true
end

run_test("returns false when active side is :first") do
  active = MockStyle.new(:first, :C)
  inactive = MockStyle.new(:second, :C)
  st = StyleTurn.send(:new, active: active, inactive: inactive)
  raise "expected false" unless st.second_to_move? == false
end

run_test("works with cross-style game (second to move)") do
  active = MockStyle.new(:second, :S)
  inactive = MockStyle.new(:first, :C)
  st = StyleTurn.send(:new, active: active, inactive: inactive)
  raise "expected true" unless st.second_to_move? == true
end

run_test("first_to_move? and second_to_move? are mutually exclusive") do
  active = MockStyle.new(:first, :C)
  inactive = MockStyle.new(:second, :C)
  st = StyleTurn.send(:new, active: active, inactive: inactive)
  raise "expected mutually exclusive" if st.first_to_move? == st.second_to_move?
end

# ============================================================================
# TO_S
# ============================================================================

puts
puts "to_s:"

run_test("returns canonical format with first to move") do
  active = MockStyle.new(:first, :C)
  inactive = MockStyle.new(:second, :C)
  st = StyleTurn.send(:new, active: active, inactive: inactive)
  raise "expected C/c" unless st.to_s == "C/c"
end

run_test("returns canonical format with second to move") do
  active = MockStyle.new(:second, :C)
  inactive = MockStyle.new(:first, :C)
  st = StyleTurn.send(:new, active: active, inactive: inactive)
  raise "expected c/C" unless st.to_s == "c/C"
end

run_test("returns canonical format for cross-style game") do
  active = MockStyle.new(:first, :C)
  inactive = MockStyle.new(:second, :S)
  st = StyleTurn.send(:new, active: active, inactive: inactive)
  raise "expected C/s" unless st.to_s == "C/s"
end

run_test("returns canonical format for Shogi") do
  active = MockStyle.new(:first, :S)
  inactive = MockStyle.new(:second, :S)
  st = StyleTurn.send(:new, active: active, inactive: inactive)
  raise "expected S/s" unless st.to_s == "S/s"
end

run_test("returns canonical format for Xiangqi") do
  active = MockStyle.new(:first, :X)
  inactive = MockStyle.new(:second, :X)
  st = StyleTurn.send(:new, active: active, inactive: inactive)
  raise "expected X/x" unless st.to_s == "X/x"
end

# ============================================================================
# EQUALITY (==)
# ============================================================================

puts
puts "equality:"

run_test("equal when active and inactive match") do
  a = StyleTurn.send(:new,
    active: MockStyle.new(:first, :C),
    inactive: MockStyle.new(:second, :C)
  )
  b = StyleTurn.send(:new,
    active: MockStyle.new(:first, :C),
    inactive: MockStyle.new(:second, :C)
  )
  raise "expected equal" unless a == b
end

run_test("not equal when active styles differ") do
  a = StyleTurn.send(:new,
    active: MockStyle.new(:first, :C),
    inactive: MockStyle.new(:second, :C)
  )
  b = StyleTurn.send(:new,
    active: MockStyle.new(:first, :S),
    inactive: MockStyle.new(:second, :C)
  )
  raise "expected not equal" if a == b
end

run_test("not equal when inactive styles differ") do
  a = StyleTurn.send(:new,
    active: MockStyle.new(:first, :C),
    inactive: MockStyle.new(:second, :C)
  )
  b = StyleTurn.send(:new,
    active: MockStyle.new(:first, :C),
    inactive: MockStyle.new(:second, :S)
  )
  raise "expected not equal" if a == b
end

run_test("not equal when active sides differ") do
  a = StyleTurn.send(:new,
    active: MockStyle.new(:first, :C),
    inactive: MockStyle.new(:second, :C)
  )
  b = StyleTurn.send(:new,
    active: MockStyle.new(:second, :C),
    inactive: MockStyle.new(:first, :C)
  )
  raise "expected not equal" if a == b
end

run_test("not equal to nil") do
  st = StyleTurn.send(:new,
    active: MockStyle.new(:first, :C),
    inactive: MockStyle.new(:second, :C)
  )
  raise "expected not equal" if st == nil
end

run_test("not equal to other types") do
  st = StyleTurn.send(:new,
    active: MockStyle.new(:first, :C),
    inactive: MockStyle.new(:second, :C)
  )
  raise "not equal to String" if st == "C/c"
  raise "not equal to Hash" if st == { active: :C, inactive: :c }
  raise "not equal to Array" if st == [:C, :c]
end

run_test("eql? behaves like ==") do
  a = StyleTurn.send(:new,
    active: MockStyle.new(:first, :C),
    inactive: MockStyle.new(:second, :C)
  )
  b = StyleTurn.send(:new,
    active: MockStyle.new(:first, :C),
    inactive: MockStyle.new(:second, :C)
  )
  c = StyleTurn.send(:new,
    active: MockStyle.new(:second, :C),
    inactive: MockStyle.new(:first, :C)
  )
  raise "expected eql?" unless a.eql?(b)
  raise "expected not eql?" if a.eql?(c)
end

# ============================================================================
# HASH
# ============================================================================

puts
puts "hash:"

run_test("equal objects have equal hash codes") do
  a = StyleTurn.send(:new,
    active: MockStyle.new(:first, :C),
    inactive: MockStyle.new(:second, :C)
  )
  b = StyleTurn.send(:new,
    active: MockStyle.new(:first, :C),
    inactive: MockStyle.new(:second, :C)
  )
  raise "expected equal hashes" unless a.hash == b.hash
end

run_test("can be used as hash key") do
  a = StyleTurn.send(:new,
    active: MockStyle.new(:first, :C),
    inactive: MockStyle.new(:second, :C)
  )
  b = StyleTurn.send(:new,
    active: MockStyle.new(:first, :C),
    inactive: MockStyle.new(:second, :C)
  )
  hash = { a => "value" }
  raise "expected to find by equal key" unless hash[b] == "value"
end

# ============================================================================
# INSPECT
# ============================================================================

puts
puts "inspect:"

run_test("includes class name") do
  st = StyleTurn.send(:new,
    active: MockStyle.new(:first, :C),
    inactive: MockStyle.new(:second, :C)
  )
  raise "expected class name" unless st.inspect.include?("StyleTurn")
end

run_test("includes string representation") do
  st = StyleTurn.send(:new,
    active: MockStyle.new(:first, :C),
    inactive: MockStyle.new(:second, :C)
  )
  raise "expected to_s content" unless st.inspect.include?("C/c")
end

# ============================================================================
# IMMUTABILITY
# ============================================================================

puts
puts "immutability:"

run_test("instance is frozen") do
  st = StyleTurn.send(:new,
    active: MockStyle.new(:first, :C),
    inactive: MockStyle.new(:second, :C)
  )
  raise "expected frozen" unless st.frozen?
end

# ============================================================================
# REAL-WORLD EXAMPLES
# ============================================================================

puts
puts "real-world examples:"

run_test("Chess: first player (white) to move") do
  active = MockStyle.new(:first, :C)
  inactive = MockStyle.new(:second, :C)
  st = StyleTurn.send(:new, active: active, inactive: inactive)

  raise "expected first to move" unless st.first_to_move?
  raise "expected C/c" unless st.to_s == "C/c"
end

run_test("Chess: second player (black) to move") do
  active = MockStyle.new(:second, :C)
  inactive = MockStyle.new(:first, :C)
  st = StyleTurn.send(:new, active: active, inactive: inactive)

  raise "expected second to move" unless st.second_to_move?
  raise "expected c/C" unless st.to_s == "c/C"
end

run_test("Shogi: sente (first) to move") do
  active = MockStyle.new(:first, :S)
  inactive = MockStyle.new(:second, :S)
  st = StyleTurn.send(:new, active: active, inactive: inactive)

  raise "expected first to move" unless st.first_to_move?
  raise "expected S/s" unless st.to_s == "S/s"
end

run_test("Shogi: gote (second) to move") do
  active = MockStyle.new(:second, :S)
  inactive = MockStyle.new(:first, :S)
  st = StyleTurn.send(:new, active: active, inactive: inactive)

  raise "expected second to move" unless st.second_to_move?
  raise "expected s/S" unless st.to_s == "s/S"
end

run_test("Cross-style: Chess vs Shogi") do
  active = MockStyle.new(:first, :C)
  inactive = MockStyle.new(:second, :S)
  st = StyleTurn.send(:new, active: active, inactive: inactive)

  raise "expected first to move" unless st.first_to_move?
  raise "expected C/s" unless st.to_s == "C/s"
end

run_test("Cross-style: Shogi vs Xiangqi, second to move") do
  active = MockStyle.new(:second, :S)
  inactive = MockStyle.new(:first, :X)
  st = StyleTurn.send(:new, active: active, inactive: inactive)

  raise "expected second to move" unless st.second_to_move?
  raise "expected s/X" unless st.to_s == "s/X"
end

puts
puts "All Position::StyleTurn tests passed!"
puts
