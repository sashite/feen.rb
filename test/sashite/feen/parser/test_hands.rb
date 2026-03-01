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
# SAFE_PARSE - VALID INPUTS
# ============================================================================

puts "safe_parse - valid inputs:"

Test("empty hands on both sides") do
  result = Hands.safe_parse("/")
  raise unless result[:first] == []
  raise unless result[:second] == []
end

Test("first hand with pieces, second empty") do
  result = Hands.safe_parse("2PN/")
  raise unless result[:first] == ["P", "P", "N"]
  raise unless result[:second] == []
end

Test("first empty, second with pieces") do
  result = Hands.safe_parse("/2pn")
  raise unless result[:first] == []
  raise unless result[:second] == ["p", "p", "n"]
end

Test("both hands with pieces") do
  result = Hands.safe_parse("2PN/p")
  raise unless result[:first] == ["P", "P", "N"]
  raise unless result[:second] == ["p"]
end

Test("decorated pieces in hands") do
  result = Hands.safe_parse("+K^'/2-r")
  raise unless result[:first] == ["+K^'"]
  raise unless result[:second] == ["-r", "-r"]
end

Test("complex hands") do
  result = Hands.safe_parse("3B2PNR/2qp")
  raise unless result[:first].size == 7
  raise unless result[:second].size == 3
end

# ============================================================================
# SAFE_PARSE - RETURN STRUCTURE
# ============================================================================

puts
puts "safe_parse - return structure:"

Test("returns Hash with :first and :second keys") do
  result = Hands.safe_parse("/")
  raise unless result.is_a?(Hash)
  raise unless result.key?(:first)
  raise unless result.key?(:second)
end

Test("values are Arrays of Strings") do
  result = Hands.safe_parse("2BP/r")
  raise unless result[:first].is_a?(Array)
  raise unless result[:second].is_a?(Array)
  raise unless result[:first].all? { |s| s.is_a?(String) }
  raise unless result[:second].all? { |s| s.is_a?(String) }
end

# ============================================================================
# SAFE_PARSE - INVALID INPUTS (returns nil)
# ============================================================================

puts
puts "safe_parse - invalid inputs:"

Test("no delimiter returns nil") do
  raise if Hands.safe_parse("")
  raise if Hands.safe_parse("P")
  raise if Hands.safe_parse("2PN")
end

Test("multiple delimiters returns nil") do
  raise if Hands.safe_parse("P/N/R")
  raise if Hands.safe_parse("//")
  raise if Hands.safe_parse("P//")
end

Test("invalid hand content returns nil") do
  raise if Hands.safe_parse("PP/")       # non-aggregated
  raise if Hands.safe_parse("/PP")       # non-aggregated
  raise if Hands.safe_parse("0P/")       # invalid count
  raise if Hands.safe_parse("1P/")       # count 1 forbidden
  raise if Hands.safe_parse("PB/")       # wrong order
  raise if Hands.safe_parse("@/")        # invalid token
end

# ============================================================================
# PARSE - VALID INPUTS
# ============================================================================

puts
puts "parse - valid inputs:"

Test("parses valid hands") do
  result = Hands.parse("2PN/p")
  raise unless result[:first] == ["P", "P", "N"]
  raise unless result[:second] == ["p"]
end

Test("parses empty hands") do
  result = Hands.parse("/")
  raise unless result[:first] == []
  raise unless result[:second] == []
end

# ============================================================================
# PARSE - INVALID INPUTS (raises HandsError)
# ============================================================================

puts
puts "parse - invalid inputs:"

Test("raises for missing delimiter") do
  ["", "P", "2PN"].each do |input|
    begin; Hands.parse(input); raise "should raise for #{input.inspect}"
    rescue HandsError; end
  end
end

Test("raises for multiple delimiters") do
  ["P/N/R", "//", "P//"].each do |input|
    begin; Hands.parse(input); raise "should raise for #{input.inspect}"
    rescue HandsError; end
  end
end

Test("raises for invalid hand content") do
  ["PP/", "/PP", "0P/", "1P/", "PB/", "@/"].each do |input|
    begin; Hands.parse(input); raise "should raise for #{input.inspect}"
    rescue HandsError; end
  end
end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

Test("module is frozen") do
  raise unless Hands.frozen?
end

puts
puts "All Parser::Hands tests passed!"
puts
