#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/dumper/style_turn"

puts
puts "=== Dumper::StyleTurn Tests ==="
puts

StyleTurn = Sashite::Feen::Dumper::StyleTurn

# ============================================================================
# BASIC DUMPING - FIRST PLAYER TO MOVE
# ============================================================================

puts "Basic dumping - first player to move:"

run_test("dumps first to move with same style") do
  result = StyleTurn.dump(active: "C", inactive: "c")
  raise "expected 'C/c', got #{result.inspect}" unless result == "C/c"
end

run_test("dumps first to move with Shogi style") do
  result = StyleTurn.dump(active: "S", inactive: "s")
  raise "expected 'S/s', got #{result.inspect}" unless result == "S/s"
end

run_test("dumps first to move with Xiangqi style") do
  result = StyleTurn.dump(active: "X", inactive: "x")
  raise "expected 'X/x', got #{result.inspect}" unless result == "X/x"
end

# ============================================================================
# BASIC DUMPING - SECOND PLAYER TO MOVE
# ============================================================================

puts
puts "Basic dumping - second player to move:"

run_test("dumps second to move with same style") do
  result = StyleTurn.dump(active: "c", inactive: "C")
  raise "expected 'c/C', got #{result.inspect}" unless result == "c/C"
end

run_test("dumps second to move with Shogi style") do
  result = StyleTurn.dump(active: "s", inactive: "S")
  raise "expected 's/S', got #{result.inspect}" unless result == "s/S"
end

run_test("dumps second to move with Go style") do
  result = StyleTurn.dump(active: "g", inactive: "G")
  raise "expected 'g/G', got #{result.inspect}" unless result == "g/G"
end

# ============================================================================
# CROSS-STYLE GAMES
# ============================================================================

puts
puts "Cross-style games:"

run_test("dumps Chess vs Shogi (first to move)") do
  result = StyleTurn.dump(active: "C", inactive: "s")
  raise "expected 'C/s', got #{result.inspect}" unless result == "C/s"
end

run_test("dumps Chess vs Shogi (second to move)") do
  result = StyleTurn.dump(active: "s", inactive: "C")
  raise "expected 's/C', got #{result.inspect}" unless result == "s/C"
end

run_test("dumps Xiangqi vs Go") do
  result = StyleTurn.dump(active: "X", inactive: "g")
  raise "expected 'X/g', got #{result.inspect}" unless result == "X/g"
end

run_test("dumps different letters") do
  result = StyleTurn.dump(active: "A", inactive: "z")
  raise "expected 'A/z', got #{result.inspect}" unless result == "A/z"
end

# ============================================================================
# DUMPING WITH OBJECTS
# ============================================================================

puts
puts "Dumping with objects:"

# Mock SIN object
MockSin = Struct.new(:letter) do
  def to_s
    letter
  end
end

run_test("dumps objects responding to to_s") do
  active = MockSin.new("C")
  inactive = MockSin.new("c")
  result = StyleTurn.dump(active: active, inactive: inactive)
  raise "expected 'C/c', got #{result.inspect}" unless result == "C/c"
end

run_test("dumps mixed strings and objects") do
  inactive = MockSin.new("s")
  result = StyleTurn.dump(active: "C", inactive: inactive)
  raise "expected 'C/s', got #{result.inspect}" unless result == "C/s"
end

# ============================================================================
# ALL LETTER STYLES
# ============================================================================

puts
puts "All letter styles:"

run_test("dumps A/a style") do
  result = StyleTurn.dump(active: "A", inactive: "a")
  raise "expected 'A/a'" unless result == "A/a"
end

run_test("dumps Z/z style") do
  result = StyleTurn.dump(active: "Z", inactive: "z")
  raise "expected 'Z/z'" unless result == "Z/z"
end

run_test("dumps M/m style") do
  result = StyleTurn.dump(active: "M", inactive: "m")
  raise "expected 'M/m'" unless result == "M/m"
end

# ============================================================================
# RETURN TYPE
# ============================================================================

puts
puts "Return type:"

run_test("returns String") do
  result = StyleTurn.dump(active: "C", inactive: "c")
  raise "expected String" unless ::String === result
end

run_test("returns String for cross-style") do
  result = StyleTurn.dump(active: "C", inactive: "s")
  raise "expected String" unless ::String === result
end

# ============================================================================
# MODULE STRUCTURE
# ============================================================================

puts
puts "Module structure:"

run_test("module is frozen") do
  raise "expected frozen" unless StyleTurn.frozen?
end

run_test("dump is the only public method") do
  public_methods = StyleTurn.methods(false) - Object.methods
  raise "expected only :dump, got #{public_methods}" unless public_methods == [:dump]
end

# ============================================================================
# REAL-WORLD EXAMPLES
# ============================================================================

puts
puts "Real-world examples:"

run_test("dumps Chess game (first to move)") do
  result = StyleTurn.dump(active: "C", inactive: "c")
  raise "expected 'C/c'" unless result == "C/c"
end

run_test("dumps Chess game (second to move)") do
  result = StyleTurn.dump(active: "c", inactive: "C")
  raise "expected 'c/C'" unless result == "c/C"
end

run_test("dumps Shogi game") do
  result = StyleTurn.dump(active: "S", inactive: "s")
  raise "expected 'S/s'" unless result == "S/s"
end

run_test("dumps Xiangqi game") do
  result = StyleTurn.dump(active: "X", inactive: "x")
  raise "expected 'X/x'" unless result == "X/x"
end

run_test("dumps Go game") do
  result = StyleTurn.dump(active: "G", inactive: "g")
  raise "expected 'G/g'" unless result == "G/g"
end

run_test("dumps hybrid Chess-Shogi game") do
  result = StyleTurn.dump(active: "C", inactive: "s")
  raise "expected 'C/s'" unless result == "C/s"
end

puts
puts "All Dumper::StyleTurn tests passed!"
puts
