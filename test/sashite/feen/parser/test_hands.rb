#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/parser/hands"

puts
puts "=== Parser::Hands Tests ==="
puts

# ============================================================================
# EMPTY HANDS
# ============================================================================

puts "Empty hands:"

run_test("parses empty hands '/'") do
  result = Sashite::Feen::Parser::Hands.parse("/")
  raise "first not empty" unless result[:first].empty?
  raise "second not empty" unless result[:second].empty?
end

run_test("parses empty first hand '/p'") do
  result = Sashite::Feen::Parser::Hands.parse("/p")
  raise "first not empty" unless result[:first].empty?
  raise "second should have items" if result[:second].empty?
end

run_test("parses empty second hand 'P/'") do
  result = Sashite::Feen::Parser::Hands.parse("P/")
  raise "first should have items" if result[:first].empty?
  raise "second not empty" unless result[:second].empty?
end

# ============================================================================
# SINGLE PIECE (IMPLICIT COUNT)
# ============================================================================

puts
puts "Single piece (implicit count):"

run_test("parses single uppercase piece") do
  result = Sashite::Feen::Parser::Hands.parse("P/")
  raise "wrong count" unless result[:first].size == 1
  raise "wrong piece count" unless result[:first][0][:count] == 1
end

run_test("parses single lowercase piece") do
  result = Sashite::Feen::Parser::Hands.parse("/p")
  raise "wrong count" unless result[:second].size == 1
  raise "wrong piece count" unless result[:second][0][:count] == 1
end

run_test("piece is Epin::Identifier") do
  result = Sashite::Feen::Parser::Hands.parse("P/")
  raise "wrong type" unless result[:first][0][:piece].is_a?(Sashite::Epin::Identifier)
end

# ============================================================================
# EXPLICIT COUNT
# ============================================================================

puts
puts "Explicit count:"

run_test("parses count of 2") do
  result = Sashite::Feen::Parser::Hands.parse("2P/")
  raise "wrong count" unless result[:first][0][:count] == 2
end

run_test("parses count of 9") do
  result = Sashite::Feen::Parser::Hands.parse("9P/")
  raise "wrong count" unless result[:first][0][:count] == 9
end

run_test("parses count of 10") do
  result = Sashite::Feen::Parser::Hands.parse("10P/")
  raise "wrong count" unless result[:first][0][:count] == 10
end

run_test("parses count of 99") do
  result = Sashite::Feen::Parser::Hands.parse("99P/")
  raise "wrong count" unless result[:first][0][:count] == 99
end

run_test("parses count of 100") do
  result = Sashite::Feen::Parser::Hands.parse("100P/")
  raise "wrong count" unless result[:first][0][:count] == 100
end

run_test("rejects count of 0") do
  Sashite::Feen::Parser::Hands.parse("0P/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid hand count"
end

run_test("rejects count of 1 (must be implicit)") do
  Sashite::Feen::Parser::Hands.parse("1P/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid hand count"
end

run_test("rejects leading zero (02)") do
  Sashite::Feen::Parser::Hands.parse("02P/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid hand count"
end

run_test("rejects leading zeros (002)") do
  Sashite::Feen::Parser::Hands.parse("002P/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid hand count"
end

# ============================================================================
# MULTIPLE ITEMS
# ============================================================================

puts
puts "Multiple items:"

run_test("parses two items in first hand") do
  result = Sashite::Feen::Parser::Hands.parse("BP/")
  raise "wrong count" unless result[:first].size == 2
end

run_test("parses three items in first hand") do
  result = Sashite::Feen::Parser::Hands.parse("BNR/")
  raise "wrong count" unless result[:first].size == 3
end

run_test("parses items in both hands") do
  result = Sashite::Feen::Parser::Hands.parse("BP/nr")
  raise "wrong first count" unless result[:first].size == 2
  raise "wrong second count" unless result[:second].size == 2
end

run_test("parses mixed counts and implicit") do
  result = Sashite::Feen::Parser::Hands.parse("3B2PN/")
  raise "wrong count" unless result[:first].size == 3
  raise "wrong B count" unless result[:first][0][:count] == 3
  raise "wrong P count" unless result[:first][1][:count] == 2
  raise "wrong N count" unless result[:first][2][:count] == 1
end

# ============================================================================
# EPIN MODIFIERS
# ============================================================================

puts
puts "EPIN modifiers:"

run_test("parses enhanced piece (+)") do
  result = Sashite::Feen::Parser::Hands.parse("+P/")
  raise "wrong state" unless result[:first][0][:piece].pin.state == :enhanced
end

run_test("parses diminished piece (-)") do
  result = Sashite::Feen::Parser::Hands.parse("-P/")
  raise "wrong state" unless result[:first][0][:piece].pin.state == :diminished
end

run_test("parses terminal piece (^)") do
  result = Sashite::Feen::Parser::Hands.parse("P^/")
  raise "not terminal" unless result[:first][0][:piece].pin.terminal?
end

run_test("parses derived piece (')") do
  result = Sashite::Feen::Parser::Hands.parse("P'/")
  raise "not derived" unless result[:first][0][:piece].derived?
end

run_test("parses all modifiers combined (+P^')") do
  result = Sashite::Feen::Parser::Hands.parse("+P^'/")
  piece = result[:first][0][:piece]
  raise "wrong state" unless piece.pin.state == :enhanced
  raise "not terminal" unless piece.pin.terminal?
  raise "not derived" unless piece.derived?
end

run_test("parses count with modifiers (3+P^')") do
  result = Sashite::Feen::Parser::Hands.parse("3+P^'/")
  raise "wrong count" unless result[:first][0][:count] == 3
  piece = result[:first][0][:piece]
  raise "wrong state" unless piece.pin.state == :enhanced
end

# ============================================================================
# DELIMITER VALIDATION
# ============================================================================

puts
puts "Delimiter validation:"

run_test("rejects missing delimiter") do
  Sashite::Feen::Parser::Hands.parse("P")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid hands delimiter"
end

run_test("rejects multiple delimiters") do
  Sashite::Feen::Parser::Hands.parse("P/p/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid hands delimiter"
end

run_test("rejects empty string") do
  Sashite::Feen::Parser::Hands.parse("")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid hands delimiter"
end

# ============================================================================
# AGGREGATION VALIDATION
# ============================================================================

puts
puts "Aggregation validation:"

run_test("rejects duplicate pieces (PP should be 2P)") do
  Sashite::Feen::Parser::Hands.parse("PP/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "hand items not aggregated"
end

run_test("rejects duplicate with count (2PP should be 3P)") do
  Sashite::Feen::Parser::Hands.parse("2PP/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "hand items not aggregated"
end

run_test("rejects duplicate in second hand") do
  Sashite::Feen::Parser::Hands.parse("/pp")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "hand items not aggregated"
end

run_test("accepts same letter different case (Pp)") do
  result = Sashite::Feen::Parser::Hands.parse("Pp/")
  raise "wrong count" unless result[:first].size == 2
end

run_test("accepts same letter different modifiers") do
  result = Sashite::Feen::Parser::Hands.parse("+PP/")
  raise "wrong count" unless result[:first].size == 2
end

# ============================================================================
# CANONICAL ORDER - BY MULTIPLICITY (DESCENDING)
# ============================================================================

puts
puts "Canonical order - by multiplicity (descending):"

run_test("accepts correct order: 3P2N (3 > 2)") do
  result = Sashite::Feen::Parser::Hands.parse("3P2N/")
  raise "should parse" unless result[:first].size == 2
end

run_test("rejects wrong order: 2P3N (2 < 3)") do
  Sashite::Feen::Parser::Hands.parse("2P3N/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "hand items not in canonical order"
end

run_test("accepts correct order: 3PN (3 > 1)") do
  result = Sashite::Feen::Parser::Hands.parse("3PN/")
  raise "should parse" unless result[:first].size == 2
end

run_test("rejects wrong order: P3N (1 < 3)") do
  Sashite::Feen::Parser::Hands.parse("P3N/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "hand items not in canonical order"
end

# ============================================================================
# CANONICAL ORDER - BY BASE LETTER (ALPHABETICAL, CASE-INSENSITIVE)
# ============================================================================

puts
puts "Canonical order - by base letter (alphabetical):"

run_test("accepts correct order: AB") do
  result = Sashite::Feen::Parser::Hands.parse("AB/")
  raise "should parse" unless result[:first].size == 2
end

run_test("rejects wrong order: BA") do
  Sashite::Feen::Parser::Hands.parse("BA/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "hand items not in canonical order"
end

run_test("accepts correct order: Ab (case-insensitive)") do
  result = Sashite::Feen::Parser::Hands.parse("Ab/")
  raise "should parse" unless result[:first].size == 2
end

run_test("accepts correct order: aB (case-insensitive)") do
  result = Sashite::Feen::Parser::Hands.parse("aB/")
  raise "should parse" unless result[:first].size == 2
end

run_test("rejects wrong order: Ba (case-insensitive)") do
  Sashite::Feen::Parser::Hands.parse("Ba/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "hand items not in canonical order"
end

# ============================================================================
# CANONICAL ORDER - BY CASE (UPPERCASE BEFORE LOWERCASE)
# ============================================================================

puts
puts "Canonical order - by case (uppercase before lowercase):"

run_test("accepts correct order: Aa") do
  result = Sashite::Feen::Parser::Hands.parse("Aa/")
  raise "should parse" unless result[:first].size == 2
end

run_test("rejects wrong order: aA") do
  Sashite::Feen::Parser::Hands.parse("aA/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "hand items not in canonical order"
end

run_test("accepts correct order: Bb") do
  result = Sashite::Feen::Parser::Hands.parse("Bb/")
  raise "should parse" unless result[:first].size == 2
end

run_test("rejects wrong order: bB") do
  Sashite::Feen::Parser::Hands.parse("bB/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "hand items not in canonical order"
end

# ============================================================================
# CANONICAL ORDER - BY STATE MODIFIER (- BEFORE + BEFORE NONE)
# ============================================================================

puts
puts "Canonical order - by state modifier (- before + before none):"

run_test("accepts correct order: -A+A") do
  result = Sashite::Feen::Parser::Hands.parse("-A+A/")
  raise "should parse" unless result[:first].size == 2
end

run_test("rejects wrong order: +A-A") do
  Sashite::Feen::Parser::Hands.parse("+A-A/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "hand items not in canonical order"
end

run_test("accepts correct order: +AA") do
  result = Sashite::Feen::Parser::Hands.parse("+AA/")
  raise "should parse" unless result[:first].size == 2
end

run_test("rejects wrong order: A+A") do
  Sashite::Feen::Parser::Hands.parse("A+A/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "hand items not in canonical order"
end

run_test("accepts correct order: -AA") do
  result = Sashite::Feen::Parser::Hands.parse("-AA/")
  raise "should parse" unless result[:first].size == 2
end

run_test("rejects wrong order: A-A") do
  Sashite::Feen::Parser::Hands.parse("A-A/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "hand items not in canonical order"
end

run_test("accepts correct order: -A+AA") do
  result = Sashite::Feen::Parser::Hands.parse("-A+AA/")
  raise "should parse" unless result[:first].size == 3
end

# ============================================================================
# CANONICAL ORDER - BY TERMINAL MARKER (ABSENT BEFORE PRESENT)
# ============================================================================

puts
puts "Canonical order - by terminal marker (absent before present):"

run_test("accepts correct order: AA^") do
  result = Sashite::Feen::Parser::Hands.parse("AA^/")
  raise "should parse" unless result[:first].size == 2
end

run_test("rejects wrong order: A^A") do
  Sashite::Feen::Parser::Hands.parse("A^A/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "hand items not in canonical order"
end

# ============================================================================
# CANONICAL ORDER - BY DERIVATION MARKER (ABSENT BEFORE PRESENT)
# ============================================================================

puts
puts "Canonical order - by derivation marker (absent before present):"

run_test("accepts correct order: AA'") do
  result = Sashite::Feen::Parser::Hands.parse("AA'/")
  raise "should parse" unless result[:first].size == 2
end

run_test("rejects wrong order: A'A") do
  Sashite::Feen::Parser::Hands.parse("A'A/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "hand items not in canonical order"
end

# ============================================================================
# CANONICAL ORDER - COMBINED CRITERIA
# ============================================================================

puts
puts "Canonical order - combined criteria:"

run_test("accepts complex valid order") do
  # 3B (count 3) > 2P (count 2) > N (count 1, N before R) > R (count 1)
  result = Sashite::Feen::Parser::Hands.parse("3B2PNR/")
  raise "should parse" unless result[:first].size == 4
end

run_test("accepts order with same letter different attributes") do
  # A (normal) > A' (derived) > A^ (terminal) > A^' (terminal+derived)
  result = Sashite::Feen::Parser::Hands.parse("AA'A^A^'/")
  raise "should parse" unless result[:first].size == 4
end

run_test("rejects complex invalid order") do
  Sashite::Feen::Parser::Hands.parse("2PNR3B/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "hand items not in canonical order"
end

# ============================================================================
# INVALID PIECE TOKEN
# ============================================================================

puts
puts "Invalid piece token:"

run_test("rejects invalid character") do
  Sashite::Feen::Parser::Hands.parse("P@/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid piece token"
end

run_test("rejects standalone count") do
  Sashite::Feen::Parser::Hands.parse("2/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid piece token"
end

# ============================================================================
# RETURN STRUCTURE
# ============================================================================

puts
puts "Return structure:"

run_test("returns hash with :first key") do
  result = Sashite::Feen::Parser::Hands.parse("/")
  raise "missing :first" unless result.key?(:first)
end

run_test("returns hash with :second key") do
  result = Sashite::Feen::Parser::Hands.parse("/")
  raise "missing :second" unless result.key?(:second)
end

run_test(":first is an Array") do
  result = Sashite::Feen::Parser::Hands.parse("/")
  raise "wrong type" unless result[:first].is_a?(Array)
end

run_test(":second is an Array") do
  result = Sashite::Feen::Parser::Hands.parse("/")
  raise "wrong type" unless result[:second].is_a?(Array)
end

run_test("each item is a Hash with :piece and :count") do
  result = Sashite::Feen::Parser::Hands.parse("P/")
  item = result[:first][0]
  raise "not a Hash" unless item.is_a?(Hash)
  raise "missing :piece" unless item.key?(:piece)
  raise "missing :count" unless item.key?(:count)
end

run_test(":piece is Epin::Identifier") do
  result = Sashite::Feen::Parser::Hands.parse("P/")
  raise "wrong type" unless result[:first][0][:piece].is_a?(Sashite::Epin::Identifier)
end

run_test(":count is Integer") do
  result = Sashite::Feen::Parser::Hands.parse("P/")
  raise "wrong type" unless result[:first][0][:count].is_a?(Integer)
end

# ============================================================================
# ERROR CLASS
# ============================================================================

puts
puts "Error class:"

run_test("raises Sashite::Feen::Errors::Argument") do
  Sashite::Feen::Parser::Hands.parse("")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument
  # Expected
end

run_test("error is rescuable as ArgumentError") do
  Sashite::Feen::Parser::Hands.parse("")
  raise "should have raised"
rescue ArgumentError
  # Expected
end

puts
puts "All Parser::Hands tests passed!"
puts
