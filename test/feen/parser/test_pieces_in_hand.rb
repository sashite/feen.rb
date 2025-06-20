# frozen_string_literal: true

# Tests for Feen::Parser::PiecesInHand conforming to FEEN Specification v1.0.0
#
# FEEN specifies that pieces in hand must be parsed from format:
# - Format: "UPPERCASE_PIECES/LOWERCASE_PIECES" with mandatory "/" separator
# - Pieces MAY include PNN modifiers (prefixes +, - and suffix ') per FEEN v1.0.0
# - Uses count notation for quantities > 1 (e.g., "3P" means 3 P pieces)
# - Returns expanded array of piece identifiers in canonical order (not sorted alphabetically)
# - Preserves the exact order from the FEEN string to maintain canonicity
#
# This test assumes the existence of the following files:
# - lib/feen/parser/pieces_in_hand.rb

require_relative "../../../lib/feen/parser/pieces_in_hand"

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
puts "Tests for Feen::Parser::PiecesInHand"
puts

# Basic cases
run_test("No pieces in hand") do
  result = Feen::Parser::PiecesInHand.parse("/")
  expected = []
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Single piece (uppercase)") do
  result = Feen::Parser::PiecesInHand.parse("P/")
  expected = ["P"]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Single piece (lowercase)") do
  result = Feen::Parser::PiecesInHand.parse("/p")
  expected = ["p"]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Mixed case single pieces") do
  result = Feen::Parser::PiecesInHand.parse("P/p")
  expected = %w[P p]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Multiple pieces with counts
run_test("Multiple pieces same type (uppercase)") do
  result = Feen::Parser::PiecesInHand.parse("3P/")
  expected = %w[P P P]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Multiple pieces same type (lowercase)") do
  result = Feen::Parser::PiecesInHand.parse("/5p")
  expected = %w[p p p p p]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Two pieces same type") do
  result = Feen::Parser::PiecesInHand.parse("2B/")
  expected = %w[B B]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Multiple different pieces (preserving canonical order)
run_test("Multiple different pieces (uppercase only)") do
  result = Feen::Parser::PiecesInHand.parse("BPR/")
  expected = %w[B P R]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Multiple different pieces (lowercase only)") do
  result = Feen::Parser::PiecesInHand.parse("/bpr")
  expected = %w[b p r]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Multiple different pieces (mixed case)") do
  result = Feen::Parser::PiecesInHand.parse("BR/pr")
  expected = %w[B R p r]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Canonical format parsing
run_test("Parse canonical format with counts") do
  result = Feen::Parser::PiecesInHand.parse("3P2B/p")
  expected = %w[P P P B B p]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Parse complex canonical format") do
  result = Feen::Parser::PiecesInHand.parse("5P2BR/")
  expected = %w[P P P P P B B R]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Parse mixed quantities and types") do
  result = Feen::Parser::PiecesInHand.parse("5P3Q2BNR/4p2g")
  expected = %w[P P P P P Q Q Q B B N R p p p p g g]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Pieces with modifiers (FEEN v1.0.0 conformance)
run_test("Parse pieces with enhanced modifier (+)") do
  result = Feen::Parser::PiecesInHand.parse("2+P/p")
  expected = %w[+P +P p]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Parse pieces with diminished modifier (-)") do
  result = Feen::Parser::PiecesInHand.parse("P/-r")
  expected = %w[P -r]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Parse pieces with intermediate state (')") do
  result = Feen::Parser::PiecesInHand.parse("K'/p")
  expected = %w[K' p]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Parse pieces with multiple modifiers") do
  result = Feen::Parser::PiecesInHand.parse("2+P'/p")
  expected = %w[+P' +P' p]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Parse complex canonical format with modifiers") do
  result = Feen::Parser::PiecesInHand.parse("2+B5BK3-P-P'3+P'9PR2SS'/bp")
  expected = ["+B", "+B", "B", "B", "B", "B", "B", "K", "-P", "-P", "-P", "-P'", "+P'", "+P'", "+P'", "P", "P", "P",
              "P", "P", "P", "P", "P", "P", "R", "S", "S", "S'", "b", "p"]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Large quantities
run_test("Large quantities") do
  result = Feen::Parser::PiecesInHand.parse("10P/15p")
  expected = Array.new(10, "P") + Array.new(15, "p")
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Very large quantities") do
  result = Feen::Parser::PiecesInHand.parse("123K/456k")
  expected = Array.new(123, "K") + Array.new(456, "k")
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Shogi-style examples with modifiers
run_test("Shogi pieces in hand") do
  result = Feen::Parser::PiecesInHand.parse("5P2G2L/pr")
  expected = %w[P P P P P G G L L p r]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Complex Shogi hand with modifiers") do
  result = Feen::Parser::PiecesInHand.parse("2+B2P/2g2sln")
  expected = %w[+B +B P P g g s s l n]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Mixed counts and single pieces
run_test("Mixed counts and single pieces") do
  result = Feen::Parser::PiecesInHand.parse("3PBRN/2pr")
  expected = %w[P P P B R N p p r]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Two-digit and higher counts
run_test("Two-digit counts") do
  result = Feen::Parser::PiecesInHand.parse("12P/34p")
  expected = Array.new(12, "P") + Array.new(34, "p")
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Three-digit counts") do
  result = Feen::Parser::PiecesInHand.parse("100K/999k")
  expected = Array.new(100, "K") + Array.new(999, "k")
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Error cases - invalid input types
run_test("Raises error for non-string input") do
  Feen::Parser::PiecesInHand.parse(123)
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Pieces in hand must be a string")
end

run_test("Raises error for nil input") do
  Feen::Parser::PiecesInHand.parse(nil)
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Pieces in hand must be a string")
end

run_test("Raises error for array input") do
  Feen::Parser::PiecesInHand.parse(%w[P p])
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Pieces in hand must be a string")
end

# Error cases - empty string
run_test("Raises error for empty string") do
  Feen::Parser::PiecesInHand.parse("")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Pieces in hand string cannot be empty")
end

# Error cases - missing separator
run_test("Raises error for missing separator") do
  Feen::Parser::PiecesInHand.parse("Pp")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("must contain exactly one '/' separator")
end

run_test("Raises error for multiple separators") do
  Feen::Parser::PiecesInHand.parse("P/p/B")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("must contain exactly one '/' separator")
end

run_test("Raises error for no separator") do
  Feen::Parser::PiecesInHand.parse("PPBB")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("must contain exactly one '/' separator")
end

# Error cases - invalid PNN format
run_test("Raises error for invalid characters") do
  Feen::Parser::PiecesInHand.parse("P@/p")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.eql?("Invalid pieces in hand format: P@/p")
end

run_test("Raises error for spaces") do
  Feen::Parser::PiecesInHand.parse("P P/p")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid pieces in hand format")
end

run_test("Raises error for numbers in wrong position") do
  Feen::Parser::PiecesInHand.parse("P3/p")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid pieces in hand format")
end

# Error cases - invalid counts
run_test("Raises error for count of 0") do
  Feen::Parser::PiecesInHand.parse("0P/p")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid pieces in hand format")
end

run_test("Raises error for count of 1") do
  Feen::Parser::PiecesInHand.parse("1P/p")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.eql?("Invalid pieces in hand format: 1P/p")
end

run_test("Raises error for count with leading zero") do
  Feen::Parser::PiecesInHand.parse("01P/p")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.eql?("Invalid pieces in hand format: 01P/p")
end

run_test("Raises error for count with leading zeros") do
  Feen::Parser::PiecesInHand.parse("002P/p")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.eql?("Invalid pieces in hand format: 002P/p")
end

# Error cases - wrong case in section
run_test("Raises error for lowercase piece in uppercase section") do
  Feen::Parser::PiecesInHand.parse("Pp/")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.eql?("Invalid pieces in hand format: Pp/")
end

run_test("Raises error for uppercase piece in lowercase section") do
  Feen::Parser::PiecesInHand.parse("/pP")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.eql?("Invalid pieces in hand format: /pP")
end

# Edge cases - minimal valid inputs
run_test("Minimal valid single uppercase") do
  result = Feen::Parser::PiecesInHand.parse("A/")
  expected = ["A"]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Minimal valid single lowercase") do
  result = Feen::Parser::PiecesInHand.parse("/z")
  expected = ["z"]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Minimal valid count") do
  result = Feen::Parser::PiecesInHand.parse("2A/")
  expected = %w[A A]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Order preservation verification
run_test("Preserves canonical order from FEEN string") do
  result = Feen::Parser::PiecesInHand.parse("ZYX/cba")
  expected = %w[Z Y X c b a]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Complex canonical order preservation") do
  result = Feen::Parser::PiecesInHand.parse("5Z3Y2X/4c3b2a")
  expected = %w[Z Z Z Z Z Y Y Y X X c c c c b b b a a]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

puts
puts "All tests passed! ✓"
