# frozen_string_literal: true

# Tests for Feen::Parser::PiecesInHand conforming to FEEN Specification v1.0.0
#
# FEEN specifies that pieces in hand must be parsed from format:
# - Format: "UPPERCASE_PIECES/LOWERCASE_PIECES" with mandatory "/" separator
# - Pieces MUST be in base form only (no modifiers like +, -, ' allowed)
# - Uses count notation for quantities > 1 (e.g., "3P" means 3 P pieces)
# - Within each section, pieces are sorted by quantity (descending) then alphabetically
# - Returns expanded array of piece identifiers sorted alphabetically
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

# Multiple different pieces
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

# Complex canonical format parsing
run_test("Parse canonical format with counts") do
  result = Feen::Parser::PiecesInHand.parse("3P2B/p")
  expected = %w[B B P P P p]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Parse complex canonical format") do
  result = Feen::Parser::PiecesInHand.parse("5P2BR/")
  expected = %w[B B P P P P P R]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Parse mixed quantities and types") do
  result = Feen::Parser::PiecesInHand.parse("5P3Q2BNR/4p2g")
  expected = %w[B B N P P P P P Q Q Q R g g p p p p]
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

# Shogi-style examples
run_test("Shogi pieces in hand") do
  result = Feen::Parser::PiecesInHand.parse("5P2G2L/pr")
  expected = %w[G G L L P P P P P p r]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Complex Shogi hand") do
  result = Feen::Parser::PiecesInHand.parse("2B2P/2g2sln")
  expected = %w[B B P P g g l n s s]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# All letters test
run_test("All uppercase letters") do
  result = Feen::Parser::PiecesInHand.parse("ABCDEFGHIJKLMNOPQRSTUVWXYZ/")
  expected = ("A".."Z").to_a
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("All lowercase letters") do
  result = Feen::Parser::PiecesInHand.parse("/abcdefghijklmnopqrstuvwxyz")
  expected = ("a".."z").to_a
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

# Mixed counts and single pieces
run_test("Mixed counts and single pieces") do
  result = Feen::Parser::PiecesInHand.parse("3PBRN/2pr")
  expected = %w[B N P P P R p p r]
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

# Error cases - invalid format
run_test("Raises error for invalid characters") do
  Feen::Parser::PiecesInHand.parse("P@/p")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid pieces in hand format")
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

# Error cases - modifiers (forbidden in pieces in hand)
run_test("Raises error for enhanced modifier (+)") do
  Feen::Parser::PiecesInHand.parse("+P/p")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.eql?('Pieces in hand cannot contain modifiers: "+P"')
end

run_test("Raises error for diminished modifier (-)") do
  Feen::Parser::PiecesInHand.parse("P/-r")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.eql?('Pieces in hand cannot contain modifiers: "-r"')
end

run_test("Raises error for intermediate state (')") do
  Feen::Parser::PiecesInHand.parse("K'/p")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.eql?('Pieces in hand cannot contain modifiers: "K\'"')
end

run_test("Raises error for multiple modifiers") do
  Feen::Parser::PiecesInHand.parse("+P'/p")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.eql?('Pieces in hand cannot contain modifiers: "+P\'"')
end

run_test("Raises error for modifiers with counts") do
  Feen::Parser::PiecesInHand.parse("3+P/p")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.eql?('Pieces in hand cannot contain modifiers: "3+P"')
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
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid pieces in hand format")
end

run_test("Raises error for count with leading zero") do
  Feen::Parser::PiecesInHand.parse("01P/p")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid pieces in hand format")
end

run_test("Raises error for count with leading zeros") do
  Feen::Parser::PiecesInHand.parse("002P/p")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid pieces in hand format")
end

# Error cases - wrong case in section
run_test("Raises error for lowercase piece in uppercase section") do
  Feen::Parser::PiecesInHand.parse("Pp/")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid pieces in hand format")
end

run_test("Raises error for uppercase piece in lowercase section") do
  Feen::Parser::PiecesInHand.parse("/pP")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid pieces in hand format: /pP")
end

run_test("Raises error for mixed case with counts") do
  Feen::Parser::PiecesInHand.parse("3Pp/")
  raise "Expected ArgumentError"
rescue ArgumentError => e
  raise "Wrong error message: #{e.message}" unless e.message.include?("Invalid pieces in hand format: 3Pp/")
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

# Alphabetical sorting verification
run_test("Result is alphabetically sorted") do
  result = Feen::Parser::PiecesInHand.parse("ZYX/cba")
  expected = %w[X Y Z a b c]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

run_test("Complex sorting with mixed counts") do
  result = Feen::Parser::PiecesInHand.parse("5Z3Y2X/4c3b2a")
  expected = %w[X X Y Y Y Z Z Z Z Z a a b b b c c c c]
  raise "Expected #{expected.inspect}, got #{result.inspect}" unless result == expected
end

puts
puts "All tests passed! ✓"
