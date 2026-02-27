#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/parser/hands"

puts
puts "=== Parser::Hands Tests ==="
puts

Hands = Sashite::Feen::Parser::Hands
HandsError = Sashite::Feen::HandsError

# ============================================================================
# VALID INPUTS - EMPTY HANDS
# ============================================================================

puts "valid inputs - empty hands:"

run_test("parses empty hands") do
  result = Hands.parse("/")
  raise "wrong first" unless result[:first] == []
  raise "wrong second" unless result[:second] == []
end

# ============================================================================
# VALID INPUTS - FIRST HAND ONLY
# ============================================================================

puts
puts "valid inputs - first hand only:"

run_test("parses single piece in first hand") do
  result = Hands.parse("P/")
  raise "wrong first" unless result[:first] == ["P"]
  raise "wrong second" unless result[:second] == []
end

run_test("parses multiple pieces in first hand") do
  result = Hands.parse("2PN/")
  raise "wrong first" unless result[:first] == ["P", "P", "N"]
  raise "wrong second" unless result[:second] == []
end

# ============================================================================
# VALID INPUTS - SECOND HAND ONLY
# ============================================================================

puts
puts "valid inputs - second hand only:"

run_test("parses single piece in second hand") do
  result = Hands.parse("/p")
  raise "wrong first" unless result[:first] == []
  raise "wrong second" unless result[:second] == ["p"]
end

run_test("parses multiple pieces in second hand") do
  result = Hands.parse("/2pn")
  raise "wrong first" unless result[:first] == []
  raise "wrong second" unless result[:second] == ["p", "p", "n"]
end

# ============================================================================
# VALID INPUTS - BOTH HANDS
# ============================================================================

puts
puts "valid inputs - both hands:"

run_test("parses pieces in both hands") do
  result = Hands.parse("2PN/p")
  raise "wrong first" unless result[:first] == ["P", "P", "N"]
  raise "wrong second" unless result[:second] == ["p"]
end

run_test("parses complex hands") do
  result = Hands.parse("3B2PNR/2qp")
  raise "wrong first size" unless result[:first].size == 7
  raise "wrong second size" unless result[:second].size == 3
end

run_test("parses hands with decorated pieces") do
  result = Hands.parse("+P/+p")
  raise "wrong first" unless result[:first] == ["+P"]
  raise "wrong second" unless result[:second] == ["+p"]
end

# ============================================================================
# RETURN STRUCTURE
# ============================================================================

puts
puts "return structure:"

run_test("returns a Hash") do
  result = Hands.parse("/")
  raise "expected Hash" unless result.is_a?(Hash)
end

run_test("has :first key") do
  result = Hands.parse("/")
  raise "missing :first" unless result.key?(:first)
end

run_test("has :second key") do
  result = Hands.parse("/")
  raise "missing :second" unless result.key?(:second)
end

run_test(":first is an Array of Strings") do
  result = Hands.parse("2PB/")
  raise "expected Array" unless result[:first].is_a?(Array)
  raise "expected all Strings" unless result[:first].all? { |p| p.is_a?(String) }
end

run_test(":second is an Array of Strings") do
  result = Hands.parse("/2pb")
  raise "expected Array" unless result[:second].is_a?(Array)
  raise "expected all Strings" unless result[:second].all? { |p| p.is_a?(String) }
end

# ============================================================================
# INVALID INPUTS - DELIMITER
# ============================================================================

puts
puts "invalid inputs - delimiter:"

run_test("raises for missing delimiter") do
  Hands.parse("P")
  raise "should have raised"
rescue HandsError
  # Expected
end

run_test("raises for multiple delimiters") do
  Hands.parse("P/N/p")
  raise "should have raised"
rescue HandsError
  # Expected
end

run_test("raises for empty string") do
  Hands.parse("")
  raise "should have raised"
rescue HandsError
  # Expected
end

# ============================================================================
# INVALID INPUTS - HAND CONTENT
# ============================================================================

puts
puts "invalid inputs - hand content:"

run_test("raises for invalid piece in first hand") do
  Hands.parse("@/")
  raise "should have raised"
rescue HandsError
  # Expected
end

run_test("raises for invalid piece in second hand") do
  Hands.parse("/@")
  raise "should have raised"
rescue HandsError
  # Expected
end

run_test("raises for non-aggregated pieces in first hand") do
  Hands.parse("PP/")
  raise "should have raised"
rescue HandsError
  # Expected
end

run_test("raises for non-canonical order in first hand") do
  Hands.parse("BA/")
  raise "should have raised"
rescue HandsError
  # Expected
end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

run_test("module is frozen") do
  raise "expected frozen" unless Hands.frozen?
end

puts
puts "All Parser::Hands tests passed!"
puts
