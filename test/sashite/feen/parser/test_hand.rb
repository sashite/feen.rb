#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/parser/hand"

puts
puts "=== Parser::Hand Tests ==="
puts

Hand = Sashite::Feen::Parser::Hand
HandsError = Sashite::Feen::HandsError unless defined?(HandsError)

# ============================================================================
# EMPTY HAND
# ============================================================================

puts "empty hand:"

Test("parses empty string to empty array") do
  result = Hand.parse("")
  raise "expected empty array" unless result == []
end

# ============================================================================
# SINGLE PIECE (IMPLICIT COUNT = 1)
# ============================================================================

puts
puts "single piece:"

Test("parses simple uppercase piece") do
  result = Hand.parse("P")
  raise "expected [\"P\"]" unless result == ["P"]
end

Test("parses simple lowercase piece") do
  result = Hand.parse("p")
  raise "expected [\"p\"]" unless result == ["p"]
end

Test("parses piece with terminal marker") do
  result = Hand.parse("K^")
  raise "expected [\"K^\"]" unless result == ["K^"]
end

Test("parses piece with state modifier +") do
  result = Hand.parse("+P")
  raise "expected [\"+P\"]" unless result == ["+P"]
end

Test("parses piece with state modifier -") do
  result = Hand.parse("-R")
  raise "expected [\"-R\"]" unless result == ["-R"]
end

Test("parses piece with derivation marker") do
  result = Hand.parse("K'")
  raise "expected [\"K'\"]" unless result == ["K'"]
end

Test("parses fully decorated piece") do
  result = Hand.parse("+K^'")
  raise "expected [\"+K^'\"]" unless result == ["+K^'"]
end

# ============================================================================
# MULTIPLE DISTINCT PIECES (IMPLICIT COUNT)
# ============================================================================

puts
puts "multiple distinct pieces:"

Test("parses two distinct pieces") do
  result = Hand.parse("BP")
  raise "expected [\"B\", \"P\"]" unless result == ["B", "P"]
end

Test("parses three distinct pieces") do
  result = Hand.parse("BNP")
  raise "expected [\"B\", \"N\", \"P\"]" unless result == ["B", "N", "P"]
end

Test("parses mixed case pieces") do
  result = Hand.parse("Pp")
  raise "expected [\"P\", \"p\"]" unless result == ["P", "p"]
end

# ============================================================================
# EXPLICIT COUNTS
# ============================================================================

puts
puts "explicit counts:"

Test("parses count of 2") do
  result = Hand.parse("2P")
  raise "expected [\"P\", \"P\"]" unless result == ["P", "P"]
end

Test("parses count of 3") do
  result = Hand.parse("3P")
  raise "expected 3 Ps" unless result == ["P", "P", "P"]
end

Test("parses large count") do
  result = Hand.parse("10P")
  raise "expected 10 Ps" unless result.size == 10
  raise "all should be P" unless result.all? { |p| p == "P" }
end

Test("parses count with decorated piece") do
  result = Hand.parse("2+P^'")
  raise "expected 2 items" unless result.size == 2
  raise "wrong piece" unless result.all? { |p| p == "+P^'" }
end

# ============================================================================
# MIXED COUNTS AND SINGLES
# ============================================================================

puts
puts "mixed counts and singles:"

Test("parses 2N followed by single P") do
  result = Hand.parse("2NP")
  raise "expected [\"N\", \"N\", \"P\"]" unless result == ["N", "N", "P"]
end

Test("parses complex hand") do
  result = Hand.parse("3B2PNR")
  raise "expected 7 pieces" unless result.size == 7
  raise "wrong Bs" unless result[0..2] == ["B", "B", "B"]
  raise "wrong Ps" unless result[3..4] == ["P", "P"]
  raise "wrong N" unless result[5] == "N"
  raise "wrong R" unless result[6] == "R"
end

Test("parses hand with lowercase pieces") do
  result = Hand.parse("2np")
  raise "expected [\"n\", \"n\", \"p\"]" unless result == ["n", "n", "p"]
end

# ============================================================================
# RETURN STRUCTURE
# ============================================================================

puts
puts "return structure:"

Test("returns an Array") do
  result = Hand.parse("P")
  raise "expected Array" unless result.is_a?(Array)
end

Test("array contains Strings") do
  result = Hand.parse("2BP")
  raise "expected all Strings" unless result.all? { |item| item.is_a?(String) }
end

Test("empty hand returns empty Array") do
  result = Hand.parse("")
  raise "expected Array" unless result.is_a?(Array)
  raise "expected empty" unless result.empty?
end

# ============================================================================
# INVALID INPUTS - COUNT
# ============================================================================

puts
puts "invalid inputs - count:"

Test("raises for count of 0") do
  Hand.parse("0P")
  raise "should have raised"
rescue HandsError
  # Expected
end

Test("raises for count of 1") do
  Hand.parse("1P")
  raise "should have raised"
rescue HandsError
  # Expected
end

Test("raises for leading zeros") do
  Hand.parse("02P")
  raise "should have raised"
rescue HandsError
  # Expected
end

Test("raises for leading zeros on larger count") do
  Hand.parse("010P")
  raise "should have raised"
rescue HandsError
  # Expected
end

# ============================================================================
# INVALID INPUTS - PIECE TOKEN
# ============================================================================

puts
puts "invalid inputs - piece token:"

Test("raises for digit-only token") do
  Hand.parse("2")
  raise "should have raised"
rescue HandsError
  # Expected
end

Test("raises for invalid character") do
  Hand.parse("@")
  raise "should have raised"
rescue HandsError
  # Expected
end

# ============================================================================
# INVALID INPUTS - AGGREGATION
# ============================================================================

puts
puts "invalid inputs - aggregation:"

Test("raises for non-aggregated pieces with terminal marker") do
  Hand.parse("K^K^")
  raise "should have raised"
rescue HandsError
  # Expected
end

Test("raises for non-aggregated pieces with derivation marker") do
  Hand.parse("P'P'")
  raise "should have raised"
rescue HandsError
  # Expected
end

Test("raises for non-aggregated fully decorated pieces") do
  Hand.parse("+K^'+K^'")
  raise "should have raised"
rescue HandsError
  # Expected
end

Test("raises for duplicate pieces not aggregated") do
  Hand.parse("PP")
  raise "should have raised"
rescue HandsError
  # Expected
end

Test("raises for duplicate decorated pieces not aggregated") do
  Hand.parse("+P+P")
  raise "should have raised"
rescue HandsError
  # Expected
end

# ============================================================================
# INVALID INPUTS - CANONICAL ORDER
# ============================================================================

puts
puts "invalid inputs - canonical order:"

Test("raises when terminal present comes before absent") do
  Hand.parse("P^P")
  raise "should have raised"
rescue HandsError
  # Expected
end

Test("raises when derivation present comes before absent") do
  Hand.parse("P'P")
  raise "should have raised"
rescue HandsError
  # Expected
end

Test("raises when lower count comes before higher count") do
  Hand.parse("2P3B")
  raise "should have raised"
rescue HandsError
  # Expected
end

Test("raises when letter order is wrong") do
  Hand.parse("PB")
  raise "should have raised"
rescue HandsError
  # Expected
end

Test("raises when lowercase comes before uppercase for same letter") do
  Hand.parse("pP")
  raise "should have raised"
rescue HandsError
  # Expected
end

# ============================================================================
# CANONICAL ORDER - VALID EXAMPLES
# ============================================================================

puts
puts "canonical order - valid examples:"

Test("accepts descending multiplicity") do
  result = Hand.parse("3B2P")
  raise "expected 5 pieces" unless result.size == 5
end

Test("accepts alphabetical order at same count") do
  result = Hand.parse("AB")
  raise "expected [\"A\", \"B\"]" unless result == ["A", "B"]
end

Test("accepts uppercase before lowercase for same letter") do
  result = Hand.parse("Pp")
  raise "expected [\"P\", \"p\"]" unless result == ["P", "p"]
end

Test("accepts diminished before enhanced before normal") do
  result = Hand.parse("-P+PP")
  raise "expected 3 pieces" unless result.size == 3
  raise "wrong order" unless result == ["-P", "+P", "P"]
end

Test("accepts absent terminal before present terminal") do
  result = Hand.parse("PP^")
  raise "expected [\"P\", \"P^\"]" unless result == ["P", "P^"]
end

Test("accepts absent derivation before present derivation") do
  result = Hand.parse("PP'")
  raise "expected [\"P\", \"P'\"]" unless result == ["P", "P'"]
end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

Test("module is frozen") do
  raise "expected frozen" unless Hand.frozen?
end

puts
puts "All Parser::Hand tests passed!"
puts
