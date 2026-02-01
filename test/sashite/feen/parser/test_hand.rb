#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/parser/hand"

puts
puts "=== Parser::Hand Tests ==="
puts

Hand = Sashite::Feen::Parser::Hand
HandsError = Sashite::Feen::HandsError

# ============================================================================
# VALID PARSING - EMPTY HAND
# ============================================================================

puts "Valid parsing - empty hand:"

run_test("parses empty string") do
  result = Hand.parse("")
  raise "expected empty array" unless result == []
end

# ============================================================================
# VALID PARSING - SINGLE ITEM
# ============================================================================

puts
puts "Valid parsing - single item:"

run_test("parses single piece without count") do
  result = Hand.parse("P")
  raise "expected 1 item" unless result.size == 1
  raise "expected count 1" unless result[0][:count] == 1
  raise "expected piece P" unless result[0][:piece].to_s == "P"
end

run_test("parses single piece with count") do
  result = Hand.parse("3P")
  raise "expected 1 item" unless result.size == 1
  raise "expected count 3" unless result[0][:count] == 3
  raise "expected piece P" unless result[0][:piece].to_s == "P"
end

run_test("parses piece with count 2") do
  result = Hand.parse("2N")
  raise "expected count 2" unless result[0][:count] == 2
end

run_test("parses large count") do
  result = Hand.parse("99P")
  raise "expected count 99" unless result[0][:count] == 99
end

# ============================================================================
# VALID PARSING - MULTIPLE ITEMS
# ============================================================================

puts
puts "Valid parsing - multiple items:"

run_test("parses multiple pieces without counts") do
  # Alphabetical order: N < P < R
  result = Hand.parse("NPR")
  raise "expected 3 items" unless result.size == 3
  raise "expected N first" unless result[0][:piece].to_s == "N"
  raise "expected P second" unless result[1][:piece].to_s == "P"
  raise "expected R third" unless result[2][:piece].to_s == "R"
end

run_test("parses mixed counts and no counts") do
  # Count desc first: 3B, then alphabetical: N, R
  result = Hand.parse("3BNR")
  raise "expected 3 items" unless result.size == 3
  raise "expected count 3 for B" unless result[0][:count] == 3
  raise "expected count 1 for N" unless result[1][:count] == 1
  raise "expected count 1 for R" unless result[2][:count] == 1
end

run_test("parses canonical order by count descending") do
  # 3B, then 2N (count desc), then P (count 1)
  result = Hand.parse("3B2NP")
  raise "expected 3 items" unless result.size == 3
  raise "expected count 3 first" unless result[0][:count] == 3
  raise "expected count 2 second" unless result[1][:count] == 2
  raise "expected count 1 third" unless result[2][:count] == 1
end

# ============================================================================
# VALID PARSING - EPIN MODIFIERS
# ============================================================================

puts
puts "Valid parsing - EPIN modifiers:"

run_test("parses enhanced piece (+)") do
  result = Hand.parse("+P")
  raise "expected +P" unless result[0][:piece].to_s == "+P"
end

run_test("parses diminished piece (-)") do
  result = Hand.parse("-P")
  raise "expected -P" unless result[0][:piece].to_s == "-P"
end

run_test("parses terminal piece (^)") do
  result = Hand.parse("K^")
  raise "expected K^" unless result[0][:piece].to_s == "K^"
end

run_test("parses derived piece (')") do
  result = Hand.parse("K'")
  raise "expected K'" unless result[0][:piece].to_s == "K'"
end

run_test("parses fully modified piece") do
  result = Hand.parse("+K^'")
  raise "expected +K^'" unless result[0][:piece].to_s == "+K^'"
end

run_test("parses count with modified piece") do
  result = Hand.parse("2+P")
  raise "expected count 2" unless result[0][:count] == 2
  raise "expected +P" unless result[0][:piece].to_s == "+P"
end

# ============================================================================
# VALID PARSING - CANONICAL ORDER
# ============================================================================

puts
puts "Valid parsing - canonical order:"

run_test("canonical order: count descending") do
  # 3P before 2N before R (counts: 3, 2, 1)
  result = Hand.parse("3P2NR")
  raise "expected 3 items" unless result.size == 3
  raise "wrong order" unless result[0][:count] == 3
  raise "wrong order" unless result[1][:count] == 2
  raise "wrong order" unless result[2][:count] == 1
end

run_test("canonical order: alphabetical when same count") do
  # A before B before C (alphabetical)
  result = Hand.parse("ABC")
  raise "expected A first" unless result[0][:piece].to_s == "A"
  raise "expected B second" unless result[1][:piece].to_s == "B"
  raise "expected C third" unless result[2][:piece].to_s == "C"
end

run_test("canonical order: uppercase before lowercase") do
  # P before p (same letter, uppercase first)
  result = Hand.parse("Pp")
  raise "expected P first" unless result[0][:piece].to_s == "P"
  raise "expected p second" unless result[1][:piece].to_s == "p"
end

run_test("canonical order: state modifier - before + before none") do
  # -P before +P before P
  result = Hand.parse("-P+PP")
  raise "expected -P first" unless result[0][:piece].to_s == "-P"
  raise "expected +P second" unless result[1][:piece].to_s == "+P"
  raise "expected P third" unless result[2][:piece].to_s == "P"
end

run_test("canonical order: terminal absent before present") do
  # P before P^
  result = Hand.parse("PP^")
  raise "expected P first" unless result[0][:piece].to_s == "P"
  raise "expected P^ second" unless result[1][:piece].to_s == "P^"
end

run_test("canonical order: derived absent before present") do
  # P before P'
  result = Hand.parse("PP'")
  raise "expected P first" unless result[0][:piece].to_s == "P"
  raise "expected P' second" unless result[1][:piece].to_s == "P'"
end

run_test("canonical order: complex example") do
  # 3B (count 3), 2N (count 2), then P, R (count 1, alphabetical)
  result = Hand.parse("3B2NPR")
  raise "expected B with 3" unless result[0][:piece].to_s == "B" && result[0][:count] == 3
  raise "expected N with 2" unless result[1][:piece].to_s == "N" && result[1][:count] == 2
  raise "expected P with 1" unless result[2][:piece].to_s == "P" && result[2][:count] == 1
  raise "expected R with 1" unless result[3][:piece].to_s == "R" && result[3][:count] == 1
end

# ============================================================================
# RESULT STRUCTURE
# ============================================================================

puts
puts "Result structure:"

run_test("returns Array") do
  result = Hand.parse("P")
  raise "expected Array" unless ::Array === result
end

run_test("items are Hashes with :piece and :count") do
  result = Hand.parse("2P")
  item = result[0]
  raise "expected Hash" unless ::Hash === item
  raise "expected :piece key" unless item.key?(:piece)
  raise "expected :count key" unless item.key?(:count)
end

run_test("count is Integer") do
  result = Hand.parse("2P")
  raise "expected Integer" unless ::Integer === result[0][:count]
end

run_test("piece responds to :to_s") do
  result = Hand.parse("P")
  raise "expected to respond to :to_s" unless result[0][:piece].respond_to?(:to_s)
end

# ============================================================================
# INVALID PARSING - COUNT ERRORS
# ============================================================================

puts
puts "Invalid parsing - count errors:"

run_test("raises for count of 0") do
  Hand.parse("0P")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::INVALID_COUNT
end

run_test("raises for count of 1 (must be implicit)") do
  Hand.parse("1P")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::INVALID_COUNT
end

run_test("raises for leading zero in count") do
  Hand.parse("02P")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::INVALID_COUNT
end

run_test("raises for leading zeros in larger count") do
  Hand.parse("007P")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::INVALID_COUNT
end

# ============================================================================
# INVALID PARSING - PIECE TOKEN ERRORS
# ============================================================================

puts
puts "Invalid parsing - piece token errors:"

run_test("raises for invalid character") do
  Hand.parse("P@")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::INVALID_PIECE_TOKEN
end

run_test("raises for digit without letter") do
  Hand.parse("2")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::INVALID_PIECE_TOKEN
end

run_test("raises for incomplete modifier") do
  Hand.parse("+")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::INVALID_PIECE_TOKEN
end

run_test("raises for modifier followed by digit") do
  Hand.parse("+2")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::INVALID_PIECE_TOKEN
end

# ============================================================================
# INVALID PARSING - AGGREGATION ERRORS
# ============================================================================

puts
puts "Invalid parsing - aggregation errors:"

run_test("raises for duplicate pieces") do
  Hand.parse("PP")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::NOT_AGGREGATED
end

run_test("raises for duplicate pieces with counts") do
  Hand.parse("2P3P")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::NOT_AGGREGATED
end

run_test("raises for duplicate modified pieces") do
  Hand.parse("+P+P")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::NOT_AGGREGATED
end

run_test("allows different pieces with same letter") do
  # P and p are different pieces
  result = Hand.parse("Pp")
  raise "expected 2 items" unless result.size == 2
end

run_test("allows same letter with different modifiers") do
  # P and +P are different pieces
  result = Hand.parse("P+P")
  raise "should have raised - wrong canonical order"
rescue HandsError => e
  # This will fail canonical order, not aggregation
  raise "wrong message" unless e.message == HandsError::NOT_CANONICAL
end

# ============================================================================
# INVALID PARSING - CANONICAL ORDER ERRORS
# ============================================================================

puts
puts "Invalid parsing - canonical order errors:"

run_test("raises for ascending count order") do
  Hand.parse("2P3N")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::NOT_CANONICAL
end

run_test("raises for wrong alphabetical order") do
  Hand.parse("BA")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::NOT_CANONICAL
end

run_test("raises for lowercase before uppercase") do
  Hand.parse("pP")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::NOT_CANONICAL
end

run_test("raises for wrong state modifier order") do
  # Should be -P before +P
  Hand.parse("+P-P")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::NOT_CANONICAL
end

run_test("raises for terminal before non-terminal") do
  Hand.parse("P^P")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::NOT_CANONICAL
end

run_test("raises for derived before non-derived") do
  Hand.parse("P'P")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::NOT_CANONICAL
end

# ============================================================================
# ERROR TYPE
# ============================================================================

puts
puts "Error type:"

run_test("error is HandsError") do
  Hand.parse("0P")
  raise "should have raised"
rescue HandsError
  # Expected
end

run_test("error is also ArgumentError") do
  Hand.parse("0P")
  raise "should have raised"
rescue ArgumentError
  # Expected
end

# ============================================================================
# MODULE STRUCTURE
# ============================================================================

puts
puts "Module structure:"

run_test("module is frozen") do
  raise "expected frozen" unless Hand.frozen?
end

run_test("parse is the only public method") do
  public_methods = Hand.methods(false) - Object.methods
  raise "expected only :parse, got #{public_methods}" unless public_methods == [:parse]
end

# ============================================================================
# REAL-WORLD EXAMPLES
# ============================================================================

puts
puts "Real-world examples:"

run_test("parses Shogi-style hand") do
  # Typical Shogi hand: multiple pawns, other pieces
  # Count desc: 4P, 2L, then alphabetical: G, S
  result = Hand.parse("4P2LGS")
  raise "expected 4 items" unless result.size == 4
  raise "expected P with 4" unless result[0][:piece].to_s == "P" && result[0][:count] == 4
  raise "expected L with 2" unless result[1][:piece].to_s == "L" && result[1][:count] == 2
end

run_test("parses hand with both players' pieces") do
  # After capture in variants where pieces retain side
  # Count desc: 2P, then alphabetical: N, p
  result = Hand.parse("2PNp")
  raise "expected 3 items" unless result.size == 3
end

run_test("parses complex canonical hand") do
  # Count desc: 3B, then 2N, 2n, then alphabetical at count 1: P, p, R
  result = Hand.parse("3B2N2nPpR")
  raise "expected 6 items" unless result.size == 6
  raise "B with 3" unless result[0][:piece].to_s == "B" && result[0][:count] == 3
  raise "N with 2" unless result[1][:piece].to_s == "N" && result[1][:count] == 2
  raise "n with 2" unless result[2][:piece].to_s == "n" && result[2][:count] == 2
end

puts
puts "All Parser::Hand tests passed!"
puts
