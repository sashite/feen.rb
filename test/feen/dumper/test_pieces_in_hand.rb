# frozen_string_literal: true

# Tests for Feen::Dumper::PiecesInHand conforming to FEEN Specification v1.0.0
#
# FEEN specifies that pieces in hand must be formatted as:
# - Groups by case: uppercase first, then lowercase, separated by "/"
# - Within each group, sorts by canonical algorithm:
#   1. By quantity (descending)
#   2. By base letter (ascending)
#   3. By prefix (-, +, none)
#   4. By suffix (none, ')
# - Uses count notation for quantities > 1 (e.g., "3P" instead of "PPP")
# - MAY include PNN modifiers (prefixes +, - and suffix ')
# - Case separation enforced (uppercase/lowercase pieces)
#
# This test assumes the existence of the following files:
# - lib/feen/dumper/pieces_in_hand.rb

require_relative "../../../lib/feen/dumper/pieces_in_hand"

# Helper function to run a test and report errors
def run_test(name)
  print "  #{name}... "
  yield
  puts "✓ Success"
rescue StandardError => e
  warn "✗ Failure: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end

puts
puts "Tests for Feen::Dumper::PiecesInHand"
puts

# Basic cases
run_test("No pieces in hand") do
  result = Feen::Dumper::PiecesInHand.dump
  raise "Expected '/', got '#{result}'" unless result == "/"
end

run_test("Single piece (uppercase)") do
  result = Feen::Dumper::PiecesInHand.dump("P")
  raise "Expected 'P/', got '#{result}'" unless result == "P/"
end

run_test("Single piece (lowercase)") do
  result = Feen::Dumper::PiecesInHand.dump("p")
  raise "Expected '/p', got '#{result}'" unless result == "/p"
end

run_test("Mixed case single pieces") do
  result = Feen::Dumper::PiecesInHand.dump("P", "p")
  raise "Expected 'P/p', got '#{result}'" unless result == "P/p"
end

# Multiple pieces of same type
run_test("Multiple pieces same type (uppercase)") do
  result = Feen::Dumper::PiecesInHand.dump("P", "P", "P")
  raise "Expected '3P/', got '#{result}'" unless result == "3P/"
end

run_test("Multiple pieces same type (lowercase)") do
  result = Feen::Dumper::PiecesInHand.dump("p", "p", "p", "p", "p")
  raise "Expected '/5p', got '#{result}'" unless result == "/5p"
end

run_test("Two pieces same type") do
  result = Feen::Dumper::PiecesInHand.dump("B", "B")
  raise "Expected '2B/', got '#{result}'" unless result == "2B/"
end

# Multiple different pieces - canonical sorting
run_test("Multiple different pieces (uppercase only)") do
  result = Feen::Dumper::PiecesInHand.dump("R", "P", "B")
  raise "Expected 'BPR/', got '#{result}'" unless result == "BPR/"
end

run_test("Multiple different pieces (lowercase only)") do
  result = Feen::Dumper::PiecesInHand.dump("r", "p", "b")
  raise "Expected '/bpr', got '#{result}'" unless result == "/bpr"
end

run_test("Multiple different pieces (mixed case)") do
  result = Feen::Dumper::PiecesInHand.dump("R", "p", "B", "r")
  raise "Expected 'BR/pr', got '#{result}'" unless result == "BR/pr"
end

# Pieces with modifiers
run_test("Single piece with enhanced modifier (+)") do
  result = Feen::Dumper::PiecesInHand.dump("+P")
  raise "Expected '+P/', got '#{result}'" unless result == "+P/"
end

run_test("Single piece with diminished modifier (-)") do
  result = Feen::Dumper::PiecesInHand.dump("-R")
  raise "Expected '-R/', got '#{result}'" unless result == "-R/"
end

run_test("Single piece with intermediate state (')") do
  result = Feen::Dumper::PiecesInHand.dump("K'")
  raise "Expected 'K'/', got '#{result}'" unless result == "K'/"
end

run_test("Single piece with multiple modifiers") do
  result = Feen::Dumper::PiecesInHand.dump("+P'")
  raise "Expected '+P'/', got '#{result}'" unless result == "+P'/"
end

run_test("Multiple pieces with modifiers") do
  result = Feen::Dumper::PiecesInHand.dump("+P", "+P", "-R", "K'")
  raise "Expected '2+P-RK'/', got '#{result}'" unless result == "2+PK'-R/"
end

# Canonical sorting with modifiers
run_test("Canonical sorting: quantity, then base letter") do
  result = Feen::Dumper::PiecesInHand.dump("P", "P", "P", "+B", "+B", "R")
  raise "Expected '3P2+BR/', got '#{result}'" unless result == "3P2+BR/"
end

run_test("Canonical sorting: prefix order (-, +, none)") do
  result = Feen::Dumper::PiecesInHand.dump("-P", "+P", "P")
  raise "Expected '-P+PP/', got '#{result}'" unless result == "-P+PP/"
end

run_test("Canonical sorting: suffix order (none, ')") do
  result = Feen::Dumper::PiecesInHand.dump("P'", "P")
  raise "Expected 'PP'/', got '#{result}'" unless result == "PP'/"
end

run_test("Complex canonical sorting with all modifiers") do
  pieces = ["+B", "+B", "B", "B", "B", "B", "B", "K", "-P", "-P", "-P", "-P'", "+P'", "+P'", "+P'", "P", "P", "P", "P",
            "P", "P", "P", "P", "P", "R", "S", "S", "S'", "b", "p"]
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  expected = "9P5B3-P3+P'2+B2SK-P'RS'/bp"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

# Quantity sorting (descending) then canonical order
run_test("Sort by quantity descending, then base letter") do
  result = Feen::Dumper::PiecesInHand.dump("P", "P", "P", "B", "B", "R")
  raise "Expected '3P2BR/', got '#{result}'" unless result == "3P2BR/"
end

run_test("Sort by quantity descending (mixed quantities)") do
  result = Feen::Dumper::PiecesInHand.dump("P", "B", "B", "B", "B", "B", "R", "R")
  raise "Expected '5B2RP/', got '#{result}'" unless result == "5B2RP/"
end

run_test("Complex sorting with mixed case and modifiers") do
  result = Feen::Dumper::PiecesInHand.dump("p", "+P", "P", "P", "-B", "B", "p", "p", "p", "p")
  raise "Expected '2P-B+PB/5p', got '#{result}'" unless result == "2P-BB+P/5p"
end

# Large quantities
run_test("Large quantities") do
  pieces = Array.new(10, "P") + Array.new(15, "p")
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  raise "Expected '10P/15p', got '#{result}'" unless result == "10P/15p"
end

run_test("Very large quantities") do
  pieces = Array.new(123, "K") + Array.new(456, "k")
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  raise "Expected '123K/456k', got '#{result}'" unless result == "123K/456k"
end

run_test("Large quantities with modifiers") do
  pieces = Array.new(10, "+P") + Array.new(15, "-p")
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  raise "Expected '10+P/15-p', got '#{result}'" unless result == "10+P/15-p"
end

# Shogi-style examples with modifiers
run_test("Shogi pieces in hand") do
  result = Feen::Dumper::PiecesInHand.dump("P", "P", "P", "P", "P", "G", "G", "L", "L", "p", "r")
  raise "Expected '5P2G2L/pr', got '#{result}'" unless result == "5P2G2L/pr"
end

run_test("Complex Shogi hand with promoted pieces") do
  pieces = %w[+P +P B B p +g g s s l n]
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  raise "Expected '2B2+P/2s+gglnp', got '#{result}'" unless result == "2B2+P/2s+gglnp"
end

# Error cases - invalid types
run_test("Raises error for non-string piece") do
  Feen::Dumper::PiecesInHand.dump("P", 123)
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Piece at index 1 must be a String")
end

run_test("Raises error for nil piece") do
  Feen::Dumper::PiecesInHand.dump("P", nil)
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Piece at index 1 must be a String")
end

run_test("Raises error for array as piece") do
  Feen::Dumper::PiecesInHand.dump("P", ["Q"])
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Piece at index 1 must be a String")
end

# Error cases - invalid PNN format
run_test("Raises error for empty string piece") do
  Feen::Dumper::PiecesInHand.dump("")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("must be valid PNN notation")
end

run_test("Raises error for multi-character invalid piece") do
  Feen::Dumper::PiecesInHand.dump("PP")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("must be valid PNN notation")
end

run_test("Raises error for numeric piece") do
  Feen::Dumper::PiecesInHand.dump("1")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("must be valid PNN notation")
end

run_test("Raises error for special character piece") do
  Feen::Dumper::PiecesInHand.dump("@")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("must be valid PNN notation")
end

run_test("Raises error for invalid modifier combination") do
  Feen::Dumper::PiecesInHand.dump("++P")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("must be valid PNN notation")
end

# Error cases - wrong index reporting
run_test("Reports correct index for invalid piece") do
  Feen::Dumper::PiecesInHand.dump("P", "Q", "@R", "B")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Piece at index 2")
  raise "Wrong error message: #{e.message}" unless e.message.include?("'@R'")
end

run_test("Reports correct index for non-string piece") do
  Feen::Dumper::PiecesInHand.dump("P", "Q", "R", 123, "B")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Piece at index 3")
end

puts
puts "All tests passed! ✓"
