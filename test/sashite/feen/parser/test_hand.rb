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
# SAFE_PARSE - VALID INPUTS
# ============================================================================

puts "safe_parse - valid inputs:"

Test("empty string returns empty array") do
  raise unless Hand.safe_parse("") == []
end

Test("single pieces with all EPIN decorations") do
  raise unless Hand.safe_parse("P")    == ["P"]
  raise unless Hand.safe_parse("p")    == ["p"]
  raise unless Hand.safe_parse("K^")   == ["K^"]
  raise unless Hand.safe_parse("+P")   == ["+P"]
  raise unless Hand.safe_parse("-R")   == ["-R"]
  raise unless Hand.safe_parse("K'")   == ["K'"]
  raise unless Hand.safe_parse("+K^'") == ["+K^'"]
end

Test("multiple distinct pieces") do
  raise unless Hand.safe_parse("BP")  == ["B", "P"]
  raise unless Hand.safe_parse("BNP") == ["B", "N", "P"]
  raise unless Hand.safe_parse("Pp")  == ["P", "p"]
end

Test("explicit counts expand pieces") do
  raise unless Hand.safe_parse("2P")  == ["P", "P"]
  raise unless Hand.safe_parse("3P")  == ["P", "P", "P"]
  raise unless Hand.safe_parse("10P").size == 10
  raise unless Hand.safe_parse("2+P^'") == ["+P^'", "+P^'"]
end

Test("mixed counts and singles") do
  raise unless Hand.safe_parse("2NP")    == ["N", "N", "P"]
  raise unless Hand.safe_parse("3B2PNR") == ["B", "B", "B", "P", "P", "N", "R"]
  raise unless Hand.safe_parse("2np")    == ["n", "n", "p"]
end

# ============================================================================
# SAFE_PARSE - CANONICAL ORDER (VALID)
# ============================================================================

puts
puts "safe_parse - canonical order:"

Test("descending multiplicity") do
  raise unless Hand.safe_parse("3B2P").size == 5
end

Test("alphabetical at same count") do
  raise unless Hand.safe_parse("AB") == ["A", "B"]
end

Test("uppercase before lowercase for same letter") do
  raise unless Hand.safe_parse("Pp") == ["P", "p"]
end

Test("state modifier order: diminished < enhanced < normal") do
  raise unless Hand.safe_parse("-P+PP") == ["-P", "+P", "P"]
end

Test("terminal absent before present") do
  raise unless Hand.safe_parse("PP^") == ["P", "P^"]
end

Test("derivation absent before present") do
  raise unless Hand.safe_parse("PP'") == ["P", "P'"]
end

# ============================================================================
# SAFE_PARSE - INVALID INPUTS (returns nil)
# ============================================================================

puts
puts "safe_parse - invalid inputs:"

Test("invalid counts return nil") do
  raise if Hand.safe_parse("0P")   # count 0
  raise if Hand.safe_parse("1P")   # count 1 (must be implicit)
  raise if Hand.safe_parse("02P")  # leading zeros
  raise if Hand.safe_parse("010P") # leading zeros
end

Test("invalid tokens return nil") do
  raise if Hand.safe_parse("2")  # digit-only, no piece
  raise if Hand.safe_parse("@")  # invalid character
end

Test("non-aggregated duplicates return nil") do
  raise if Hand.safe_parse("PP")
  raise if Hand.safe_parse("K^K^")
  raise if Hand.safe_parse("P'P'")
  raise if Hand.safe_parse("+K^'+K^'")
  raise if Hand.safe_parse("+P+P")
end

Test("non-canonical order returns nil") do
  raise if Hand.safe_parse("P^P")  # terminal present before absent
  raise if Hand.safe_parse("P'P")  # derivation present before absent
  raise if Hand.safe_parse("2P3B") # ascending count
  raise if Hand.safe_parse("PB")   # wrong letter order
  raise if Hand.safe_parse("pP")   # lowercase before uppercase
end

# ============================================================================
# PARSE - VALID INPUTS
# ============================================================================

puts
puts "parse - valid inputs:"

Test("returns expanded Array of Strings") do
  result = Hand.parse("2BP")
  raise unless result.is_a?(Array)
  raise unless result.all? { |item| item.is_a?(String) }
  raise unless result == ["B", "B", "P"]
end

Test("empty hand returns empty Array") do
  result = Hand.parse("")
  raise unless result.is_a?(Array)
  raise unless result.empty?
end

# ============================================================================
# PARSE - INVALID INPUTS (raises HandsError)
# ============================================================================

puts
puts "parse - invalid inputs:"

Test("raises for invalid counts") do
  ["0P", "1P", "02P", "010P"].each do |input|
    begin; Hand.parse(input); raise "should raise for #{input}"
    rescue HandsError; end
  end
end

Test("raises for invalid tokens") do
  ["2", "@"].each do |input|
    begin; Hand.parse(input); raise "should raise for #{input}"
    rescue HandsError; end
  end
end

Test("raises for non-aggregated duplicates") do
  ["PP", "K^K^", "+P+P"].each do |input|
    begin; Hand.parse(input); raise "should raise for #{input}"
    rescue HandsError; end
  end
end

Test("raises for non-canonical order") do
  ["P^P", "2P3B", "PB", "pP"].each do |input|
    begin; Hand.parse(input); raise "should raise for #{input}"
    rescue HandsError; end
  end
end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

Test("module is frozen") do
  raise unless Hand.frozen?
end

puts
puts "All Parser::Hand tests passed!"
puts
