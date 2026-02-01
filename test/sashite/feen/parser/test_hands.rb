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
# VALID PARSING - EMPTY HANDS
# ============================================================================

puts "Valid parsing - empty hands:"

run_test("parses both hands empty") do
  result = Hands.parse("/")
  raise "expected :first key" unless result.key?(:first)
  raise "expected :second key" unless result.key?(:second)
  raise "expected empty first" unless result[:first] == []
  raise "expected empty second" unless result[:second] == []
end

run_test("parses first hand empty, second has pieces") do
  result = Hands.parse("/p")
  raise "expected empty first" unless result[:first] == []
  raise "expected 1 item in second" unless result[:second].size == 1
end

run_test("parses first hand has pieces, second empty") do
  result = Hands.parse("P/")
  raise "expected 1 item in first" unless result[:first].size == 1
  raise "expected empty second" unless result[:second] == []
end

# ============================================================================
# VALID PARSING - SINGLE ITEMS
# ============================================================================

puts
puts "Valid parsing - single items:"

run_test("parses single piece in first hand") do
  result = Hands.parse("P/")
  raise "expected count 1" unless result[:first][0][:count] == 1
  raise "expected P" unless result[:first][0][:piece].to_s == "P"
end

run_test("parses single piece in second hand") do
  result = Hands.parse("/p")
  raise "expected count 1" unless result[:second][0][:count] == 1
  raise "expected p" unless result[:second][0][:piece].to_s == "p"
end

run_test("parses pieces in both hands") do
  result = Hands.parse("P/p")
  raise "expected 1 item in first" unless result[:first].size == 1
  raise "expected 1 item in second" unless result[:second].size == 1
end

run_test("parses piece with count") do
  result = Hands.parse("3P/2p")
  raise "expected count 3" unless result[:first][0][:count] == 3
  raise "expected count 2" unless result[:second][0][:count] == 2
end

# ============================================================================
# VALID PARSING - MULTIPLE ITEMS
# ============================================================================

puts
puts "Valid parsing - multiple items:"

run_test("parses multiple pieces in first hand") do
  result = Hands.parse("BNR/")
  raise "expected 3 items" unless result[:first].size == 3
end

run_test("parses multiple pieces in second hand") do
  result = Hands.parse("/bnr")
  raise "expected 3 items" unless result[:second].size == 3
end

run_test("parses complex hands") do
  result = Hands.parse("3B2NP/2qpr")
  raise "expected 3 items in first" unless result[:first].size == 3
  raise "expected 3 items in second" unless result[:second].size == 3
end

# ============================================================================
# VALID PARSING - EPIN MODIFIERS
# ============================================================================

puts
puts "Valid parsing - EPIN modifiers:"

run_test("parses enhanced pieces") do
  result = Hands.parse("+P/+p")
  raise "expected +P" unless result[:first][0][:piece].to_s == "+P"
  raise "expected +p" unless result[:second][0][:piece].to_s == "+p"
end

run_test("parses terminal pieces") do
  result = Hands.parse("K^/k^")
  raise "expected K^" unless result[:first][0][:piece].to_s == "K^"
  raise "expected k^" unless result[:second][0][:piece].to_s == "k^"
end

run_test("parses derived pieces") do
  result = Hands.parse("P'/p'")
  raise "expected P'" unless result[:first][0][:piece].to_s == "P'"
  raise "expected p'" unless result[:second][0][:piece].to_s == "p'"
end

run_test("parses fully modified pieces") do
  result = Hands.parse("+K^'/+k^'")
  raise "expected +K^'" unless result[:first][0][:piece].to_s == "+K^'"
  raise "expected +k^'" unless result[:second][0][:piece].to_s == "+k^'"
end

# ============================================================================
# VALID PARSING - PIECE SIDE INDEPENDENCE
# ============================================================================

puts
puts "Valid parsing - piece side independence:"

run_test("first hand can contain lowercase pieces") do
  # Lowercase pieces (second player's pieces) in first player's hand
  result = Hands.parse("Pp/")
  raise "expected 2 items" unless result[:first].size == 2
  raise "expected P" unless result[:first][0][:piece].to_s == "P"
  raise "expected p" unless result[:first][1][:piece].to_s == "p"
end

run_test("second hand can contain uppercase pieces") do
  # Uppercase pieces (first player's pieces) in second player's hand
  result = Hands.parse("/Pp")
  raise "expected 2 items" unless result[:second].size == 2
  raise "expected P" unless result[:second][0][:piece].to_s == "P"
  raise "expected p" unless result[:second][1][:piece].to_s == "p"
end

# ============================================================================
# RESULT STRUCTURE
# ============================================================================

puts
puts "Result structure:"

run_test("returns Hash") do
  result = Hands.parse("/")
  raise "expected Hash" unless ::Hash === result
end

run_test("has :first and :second keys") do
  result = Hands.parse("/")
  raise "expected :first" unless result.key?(:first)
  raise "expected :second" unless result.key?(:second)
end

run_test("values are Arrays") do
  result = Hands.parse("P/p")
  raise "first should be Array" unless ::Array === result[:first]
  raise "second should be Array" unless ::Array === result[:second]
end

run_test("items have :piece and :count keys") do
  result = Hands.parse("P/")
  item = result[:first][0]
  raise "expected :piece" unless item.key?(:piece)
  raise "expected :count" unless item.key?(:count)
end

# ============================================================================
# INVALID PARSING - DELIMITER ERRORS
# ============================================================================

puts
puts "Invalid parsing - delimiter errors:"

run_test("raises for missing delimiter") do
  Hands.parse("P")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::INVALID_DELIMITER
end

run_test("raises for empty string") do
  Hands.parse("")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::INVALID_DELIMITER
end

run_test("raises for multiple delimiters") do
  Hands.parse("P/N/R")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::INVALID_DELIMITER
end

run_test("raises for only delimiters") do
  Hands.parse("//")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::INVALID_DELIMITER
end

# ============================================================================
# INVALID PARSING - DELEGATED ERRORS
# ============================================================================

puts
puts "Invalid parsing - delegated errors (from Hand parser):"

run_test("raises for invalid count in first hand") do
  Hands.parse("0P/")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::INVALID_COUNT
end

run_test("raises for invalid count in second hand") do
  Hands.parse("/1p")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::INVALID_COUNT
end

run_test("raises for duplicate pieces in first hand") do
  Hands.parse("PP/")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::NOT_AGGREGATED
end

run_test("raises for non-canonical order in first hand") do
  Hands.parse("BA/")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::NOT_CANONICAL
end

run_test("raises for invalid piece token in second hand") do
  Hands.parse("/p@")
  raise "should have raised"
rescue HandsError => e
  raise "wrong message" unless e.message == HandsError::INVALID_PIECE_TOKEN
end

# ============================================================================
# ERROR TYPE
# ============================================================================

puts
puts "Error type:"

run_test("error is HandsError") do
  Hands.parse("invalid")
  raise "should have raised"
rescue HandsError
  # Expected
end

run_test("error is also ArgumentError") do
  Hands.parse("invalid")
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
  raise "expected frozen" unless Hands.frozen?
end

run_test("parse is the only public method") do
  public_methods = Hands.methods(false) - Object.methods
  raise "expected only :parse, got #{public_methods}" unless public_methods == [:parse]
end

# ============================================================================
# REAL-WORLD EXAMPLES
# ============================================================================

puts
puts "Real-world examples:"

run_test("parses Shogi-style hands") do
  # First player captured several pieces, second player has fewer
  result = Hands.parse("4P2LGS/2pg")
  raise "expected 4 items in first" unless result[:first].size == 4
  raise "expected 2 items in second" unless result[:second].size == 2
end

run_test("parses Chess-style empty hands") do
  # Chess doesn't use hands, but empty is valid
  result = Hands.parse("/")
  raise "expected empty first" unless result[:first].empty?
  raise "expected empty second" unless result[:second].empty?
end

run_test("parses Crazyhouse-style hands") do
  # Captured pieces change side, so first hand has uppercase
  result = Hands.parse("2BNP/2bnp")
  raise "expected 3 items in first" unless result[:first].size == 3
  raise "expected 3 items in second" unless result[:second].size == 3
end

run_test("parses asymmetric hands") do
  # One player has many captures, other has none
  result = Hands.parse("5P3N2BR/")
  raise "expected 4 items in first" unless result[:first].size == 4
  raise "expected empty second" unless result[:second].empty?
end

puts
puts "All Parser::Hands tests passed!"
puts
