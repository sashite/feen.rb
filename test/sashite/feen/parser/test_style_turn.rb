#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/parser/style_turn"

puts
puts "=== Parser::StyleTurn Tests ==="
puts

ST = Sashite::Feen::Parser::StyleTurn
STE = Sashite::Feen::StyleTurnError

# ============================================================================
# SAFE_PARSE - FIRST PLAYER TO MOVE (uppercase active)
# ============================================================================

puts "safe_parse - first player to move:"

Test("uppercase/lowercase pairs") do
  [["C", "c"], ["S", "s"], ["X", "x"], ["A", "z"]].each do |upper, lower|
    r = ST.safe_parse("#{upper}/#{lower}")
    raise "#{upper}/#{lower}" unless r[:styles][:first] == upper
    raise "#{upper}/#{lower}" unless r[:styles][:second] == lower
    raise "#{upper}/#{lower}" unless r[:turn] == :first
  end
end

# ============================================================================
# SAFE_PARSE - SECOND PLAYER TO MOVE (lowercase active)
# ============================================================================

puts
puts "safe_parse - second player to move:"

Test("lowercase/uppercase pairs") do
  [["C", "c"], ["S", "s"], ["X", "x"], ["A", "z"]].each do |upper, lower|
    r = ST.safe_parse("#{lower}/#{upper}")
    raise "#{lower}/#{upper}" unless r[:styles][:first] == upper
    raise "#{lower}/#{upper}" unless r[:styles][:second] == lower
    raise "#{lower}/#{upper}" unless r[:turn] == :second
  end
end

# ============================================================================
# SAFE_PARSE - CROSS-STYLE
# ============================================================================

puts
puts "safe_parse - cross-style:"

Test("different letters, opposite case") do
  r = ST.safe_parse("C/s")
  raise unless r[:styles][:first] == "C"
  raise unless r[:styles][:second] == "s"
  raise unless r[:turn] == :first

  r = ST.safe_parse("s/C")
  raise unless r[:styles][:first] == "C"
  raise unless r[:styles][:second] == "s"
  raise unless r[:turn] == :second
end

# ============================================================================
# SAFE_PARSE - RETURN STRUCTURE
# ============================================================================

puts
puts "safe_parse - return structure:"

Test("returns Hash with :styles and :turn") do
  r = ST.safe_parse("C/c")
  raise unless r.is_a?(Hash)
  raise unless r[:styles].is_a?(Hash)
  raise unless r[:styles][:first].is_a?(String)
  raise unless r[:styles][:second].is_a?(String)
  raise unless r[:turn] == :first || r[:turn] == :second
end

# ============================================================================
# SAFE_PARSE - INVALID INPUTS (returns nil)
# ============================================================================

puts
puts "safe_parse - invalid inputs:"

Test("same case returns nil") do
  raise if ST.safe_parse("C/C")
  raise if ST.safe_parse("c/c")
end

Test("wrong structure returns nil") do
  raise if ST.safe_parse("")
  raise if ST.safe_parse("C")
  raise if ST.safe_parse("/")
  raise if ST.safe_parse("C/c/x")
end

Test("non-letter tokens return nil") do
  raise if ST.safe_parse("1/c")
  raise if ST.safe_parse("C/1")
  raise if ST.safe_parse("+/c")
end

Test("multi-char tokens return nil") do
  raise if ST.safe_parse("CC/c")
  raise if ST.safe_parse("C/cc")
end

# ============================================================================
# PARSE - ERROR MESSAGES
# ============================================================================

puts
puts "parse - error messages:"

Test("INVALID_DELIMITER for missing or multiple delimiters") do
  ["Cc", "C/c/x"].each do |input|
    begin; ST.parse(input); raise "should raise for #{input.inspect}"
    rescue STE => e; raise unless e.message == STE::INVALID_DELIMITER
    end
  end
end

Test("INVALID_STYLE_TOKEN for non-SIN tokens") do
  ["1/c", "CC/c", "C/1", "/c", "C/"].each do |input|
    begin; ST.parse(input); raise "should raise for #{input.inspect}"
    rescue STE => e; raise unless e.message == STE::INVALID_STYLE_TOKEN
    end
  end
end

Test("SAME_CASE for same-case letters") do
  ["C/C", "c/c"].each do |input|
    begin; ST.parse(input); raise "should raise for #{input.inspect}"
    rescue STE => e; raise unless e.message == STE::SAME_CASE
    end
  end
end

# ============================================================================
# MODULE PROPERTIES
# ============================================================================

puts
puts "module properties:"

Test("module is frozen") do
  raise unless ST.frozen?
end

puts
puts "All Parser::StyleTurn tests passed!"
puts
