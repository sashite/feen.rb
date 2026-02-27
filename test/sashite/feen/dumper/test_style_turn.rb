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

run_test("dumps C/c with first to move") do
  result = StyleTurn.dump({ first: "C", second: "c" }, :first)
  raise "expected 'C/c'" unless result == "C/c"
end

run_test("dumps S/s with first to move") do
  result = StyleTurn.dump({ first: "S", second: "s" }, :first)
  raise "expected 'S/s'" unless result == "S/s"
end

run_test("dumps X/x with first to move") do
  result = StyleTurn.dump({ first: "X", second: "x" }, :first)
  raise "expected 'X/x'" unless result == "X/x"
end

run_test("dumps G/g with first to move") do
  result = StyleTurn.dump({ first: "G", second: "g" }, :first)
  raise "expected 'G/g'" unless result == "G/g"
end

# ============================================================================
# SECOND PLAYER TO MOVE
# ============================================================================

puts
puts "second player to move:"

run_test("dumps c/C with second to move") do
  result = StyleTurn.dump({ first: "C", second: "c" }, :second)
  raise "expected 'c/C'" unless result == "c/C"
end

run_test("dumps s/S with second to move") do
  result = StyleTurn.dump({ first: "S", second: "s" }, :second)
  raise "expected 's/S'" unless result == "s/S"
end

run_test("dumps x/X with second to move") do
  result = StyleTurn.dump({ first: "X", second: "x" }, :second)
  raise "expected 'x/X'" unless result == "x/X"
end

# ============================================================================
# CROSS-STYLE
# ============================================================================

puts
puts "cross-style:"

run_test("dumps C/s with first to move") do
  result = StyleTurn.dump({ first: "C", second: "s" }, :first)
  raise "expected 'C/s'" unless result == "C/s"
end

run_test("dumps s/C with second to move") do
  result = StyleTurn.dump({ first: "C", second: "s" }, :second)
  raise "expected 's/C'" unless result == "s/C"
end

run_test("dumps A/z with first to move") do
  result = StyleTurn.dump({ first: "A", second: "z" }, :first)
  raise "expected 'A/z'" unless result == "A/z"
end

run_test("dumps z/A with second to move") do
  result = StyleTurn.dump({ first: "A", second: "z" }, :second)
  raise "expected 'z/A'" unless result == "z/A"
end

# ============================================================================
# RETURN TYPE
# ============================================================================

puts
puts "return type:"

run_test("returns a String") do
  result = StyleTurn.dump({ first: "C", second: "c" }, :first)
  raise "expected String" unless result.is_a?(String)
end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

run_test("module is frozen") do
  raise "expected frozen" unless StyleTurn.frozen?
end

puts
puts "All Dumper::StyleTurn tests passed!"
puts
