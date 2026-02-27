#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/parser/style_turn"

puts
puts "=== Parser::StyleTurn Tests ==="
puts

StyleTurn = Sashite::Feen::Parser::StyleTurn
StyleTurnError = Sashite::Feen::StyleTurnError

# ============================================================================
# VALID INPUTS - FIRST PLAYER TO MOVE
# ============================================================================

puts "valid inputs - first player to move:"

run_test("parses C/c with first to move") do
  result = StyleTurn.parse("C/c")
  raise "wrong first style" unless result[:styles][:first] == "C"
  raise "wrong second style" unless result[:styles][:second] == "c"
  raise "wrong turn" unless result[:turn] == :first
end

run_test("parses S/s with first to move") do
  result = StyleTurn.parse("S/s")
  raise "wrong first style" unless result[:styles][:first] == "S"
  raise "wrong second style" unless result[:styles][:second] == "s"
  raise "wrong turn" unless result[:turn] == :first
end

run_test("parses X/x with first to move") do
  result = StyleTurn.parse("X/x")
  raise "wrong first style" unless result[:styles][:first] == "X"
  raise "wrong second style" unless result[:styles][:second] == "x"
  raise "wrong turn" unless result[:turn] == :first
end

run_test("parses G/g with first to move") do
  result = StyleTurn.parse("G/g")
  raise "wrong turn" unless result[:turn] == :first
end

# ============================================================================
# VALID INPUTS - SECOND PLAYER TO MOVE
# ============================================================================

puts
puts "valid inputs - second player to move:"

run_test("parses c/C with second to move") do
  result = StyleTurn.parse("c/C")
  raise "wrong first style" unless result[:styles][:first] == "C"
  raise "wrong second style" unless result[:styles][:second] == "c"
  raise "wrong turn" unless result[:turn] == :second
end

run_test("parses s/S with second to move") do
  result = StyleTurn.parse("s/S")
  raise "wrong first style" unless result[:styles][:first] == "S"
  raise "wrong second style" unless result[:styles][:second] == "s"
  raise "wrong turn" unless result[:turn] == :second
end

run_test("parses x/X with second to move") do
  result = StyleTurn.parse("x/X")
  raise "wrong turn" unless result[:turn] == :second
end

# ============================================================================
# VALID INPUTS - CROSS-STYLE
# ============================================================================

puts
puts "valid inputs - cross-style:"

run_test("parses C/s (Chess first vs Shogi second, first to move)") do
  result = StyleTurn.parse("C/s")
  raise "wrong first style" unless result[:styles][:first] == "C"
  raise "wrong second style" unless result[:styles][:second] == "s"
  raise "wrong turn" unless result[:turn] == :first
end

run_test("parses s/C (Chess first vs Shogi second, second to move)") do
  result = StyleTurn.parse("s/C")
  raise "wrong first style" unless result[:styles][:first] == "C"
  raise "wrong second style" unless result[:styles][:second] == "s"
  raise "wrong turn" unless result[:turn] == :second
end

run_test("parses A/z (different letters)") do
  result = StyleTurn.parse("A/z")
  raise "wrong first style" unless result[:styles][:first] == "A"
  raise "wrong second style" unless result[:styles][:second] == "z"
  raise "wrong turn" unless result[:turn] == :first
end

run_test("parses z/A (different letters, second to move)") do
  result = StyleTurn.parse("z/A")
  raise "wrong first style" unless result[:styles][:first] == "A"
  raise "wrong second style" unless result[:styles][:second] == "z"
  raise "wrong turn" unless result[:turn] == :second
end

# ============================================================================
# RETURN STRUCTURE
# ============================================================================

puts
puts "return structure:"

run_test("returns a Hash") do
  result = StyleTurn.parse("C/c")
  raise "wrong type" unless result.is_a?(Hash)
end

run_test("returns hash with :styles key") do
  result = StyleTurn.parse("C/c")
  raise "missing :styles" unless result.key?(:styles)
end

run_test("returns hash with :turn key") do
  result = StyleTurn.parse("C/c")
  raise "missing :turn" unless result.key?(:turn)
end

run_test("styles values are Strings") do
  result = StyleTurn.parse("C/c")
  raise "first not String" unless result[:styles][:first].is_a?(String)
  raise "second not String" unless result[:styles][:second].is_a?(String)
end

run_test("turn is a Symbol") do
  result = StyleTurn.parse("C/c")
  raise "turn not Symbol" unless result[:turn].is_a?(Symbol)
end

# ============================================================================
# ALL LETTERS
# ============================================================================

puts
puts "all letters:"

run_test("accepts all uppercase/lowercase pairs") do
  ("A".."Z").each do |upper|
    lower = upper.downcase
    result = StyleTurn.parse("#{upper}/#{lower}")
    raise "failed for #{upper}/#{lower}" unless result[:turn] == :first
    raise "wrong first for #{upper}" unless result[:styles][:first] == upper
    raise "wrong second for #{lower}" unless result[:styles][:second] == lower
  end
end

# ============================================================================
# INVALID INPUTS - DELIMITER
# ============================================================================

puts
puts "invalid inputs - delimiter:"

run_test("raises for missing delimiter") do
  StyleTurn.parse("Cc")
  raise "should have raised"
rescue StyleTurnError
  # Expected
end

run_test("raises for multiple delimiters") do
  StyleTurn.parse("C/c/x")
  raise "should have raised"
rescue StyleTurnError
  # Expected
end

run_test("raises for empty input") do
  StyleTurn.parse("")
  raise "should have raised"
rescue StyleTurnError
  # Expected
end

# ============================================================================
# INVALID INPUTS - STYLE TOKEN
# ============================================================================

puts
puts "invalid inputs - style token:"

run_test("raises for digit as style") do
  StyleTurn.parse("1/c")
  raise "should have raised"
rescue StyleTurnError
  # Expected
end

run_test("raises for multi-char style") do
  StyleTurn.parse("CC/c")
  raise "should have raised"
rescue StyleTurnError
  # Expected
end

run_test("raises for empty active style") do
  StyleTurn.parse("/c")
  raise "should have raised"
rescue StyleTurnError
  # Expected
end

run_test("raises for empty inactive style") do
  StyleTurn.parse("C/")
  raise "should have raised"
rescue StyleTurnError
  # Expected
end

run_test("raises for special character as style") do
  StyleTurn.parse("+/c")
  raise "should have raised"
rescue StyleTurnError
  # Expected
end

# ============================================================================
# INVALID INPUTS - SAME CASE
# ============================================================================

puts
puts "invalid inputs - same case:"

run_test("raises for both uppercase") do
  StyleTurn.parse("C/C")
  raise "should have raised"
rescue StyleTurnError
  # Expected
end

run_test("raises for both lowercase") do
  StyleTurn.parse("c/c")
  raise "should have raised"
rescue StyleTurnError
  # Expected
end

run_test("raises for different letters both uppercase") do
  StyleTurn.parse("C/S")
  raise "should have raised"
rescue StyleTurnError
  # Expected
end

run_test("raises for different letters both lowercase") do
  StyleTurn.parse("c/s")
  raise "should have raised"
rescue StyleTurnError
  # Expected
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
puts "All Parser::StyleTurn tests passed!"
puts
