#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/dumper/style_turn"

puts
puts "=== Dumper::StyleTurn Tests ==="
puts

StyleTurn = Sashite::Feen::Dumper::StyleTurn

# ============================================================================
# FIRST PLAYER TO MOVE
# ============================================================================

puts "first player to move:"

Test("dumps C/c with first to move") do
  result = StyleTurn.dump("C", "c", :first)
  raise "expected 'C/c'" unless result == "C/c"
end

Test("dumps S/s with first to move") do
  result = StyleTurn.dump("S", "s", :first)
  raise "expected 'S/s'" unless result == "S/s"
end

Test("dumps X/x with first to move") do
  result = StyleTurn.dump("X", "x", :first)
  raise "expected 'X/x'" unless result == "X/x"
end

Test("dumps G/g with first to move") do
  result = StyleTurn.dump("G", "g", :first)
  raise "expected 'G/g'" unless result == "G/g"
end

# ============================================================================
# SECOND PLAYER TO MOVE
# ============================================================================

puts
puts "second player to move:"

Test("dumps c/C with second to move") do
  result = StyleTurn.dump("C", "c", :second)
  raise "expected 'c/C'" unless result == "c/C"
end

Test("dumps s/S with second to move") do
  result = StyleTurn.dump("S", "s", :second)
  raise "expected 's/S'" unless result == "s/S"
end

Test("dumps x/X with second to move") do
  result = StyleTurn.dump("X", "x", :second)
  raise "expected 'x/X'" unless result == "x/X"
end

# ============================================================================
# CROSS-STYLE
# ============================================================================

puts
puts "cross-style:"

Test("dumps C/s with first to move") do
  result = StyleTurn.dump("C", "s", :first)
  raise "expected 'C/s'" unless result == "C/s"
end

Test("dumps s/C with second to move") do
  result = StyleTurn.dump("C", "s", :second)
  raise "expected 's/C'" unless result == "s/C"
end

Test("dumps A/z with first to move") do
  result = StyleTurn.dump("A", "z", :first)
  raise "expected 'A/z'" unless result == "A/z"
end

Test("dumps z/A with second to move") do
  result = StyleTurn.dump("A", "z", :second)
  raise "expected 'z/A'" unless result == "z/A"
end

# ============================================================================
# RETURN TYPE
# ============================================================================

puts
puts "return type:"

Test("returns a String") do
  result = StyleTurn.dump("C", "c", :first)
  raise "expected String" unless result.is_a?(String)
end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

Test("module is frozen") do
  raise "expected frozen" unless StyleTurn.frozen?
end

puts
puts "All Dumper::StyleTurn tests passed!"
puts
