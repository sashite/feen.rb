#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/parser/style_turn"

puts
puts "=== Parser::StyleTurn Tests ==="
puts

# ============================================================================
# VALID SAME-STYLE GAMES
# ============================================================================

puts "Valid same-style games:"

run_test("parses C/c (Chess, first to move)") do
  result = Sashite::Feen::Parser::StyleTurn.parse("C/c")
  raise "wrong active abbr" unless result[:active].abbr == :C
  raise "wrong inactive abbr" unless result[:inactive].abbr == :C
  raise "wrong active side" unless result[:active].side == :first
  raise "wrong inactive side" unless result[:inactive].side == :second
end

run_test("parses c/C (Chess, second to move)") do
  result = Sashite::Feen::Parser::StyleTurn.parse("c/C")
  raise "wrong active abbr" unless result[:active].abbr == :C
  raise "wrong inactive abbr" unless result[:inactive].abbr == :C
  raise "wrong active side" unless result[:active].side == :second
  raise "wrong inactive side" unless result[:inactive].side == :first
end

run_test("parses S/s (Shogi, first to move)") do
  result = Sashite::Feen::Parser::StyleTurn.parse("S/s")
  raise "wrong active abbr" unless result[:active].abbr == :S
  raise "wrong inactive abbr" unless result[:inactive].abbr == :S
  raise "wrong active side" unless result[:active].side == :first
end

run_test("parses s/S (Shogi, second to move)") do
  result = Sashite::Feen::Parser::StyleTurn.parse("s/S")
  raise "wrong active side" unless result[:active].side == :second
  raise "wrong inactive side" unless result[:inactive].side == :first
end

run_test("parses X/x (Xiangqi, first to move)") do
  result = Sashite::Feen::Parser::StyleTurn.parse("X/x")
  raise "wrong active abbr" unless result[:active].abbr == :X
end

run_test("parses G/g (Go, first to move)") do
  result = Sashite::Feen::Parser::StyleTurn.parse("G/g")
  raise "wrong active abbr" unless result[:active].abbr == :G
end

# ============================================================================
# VALID CROSS-STYLE GAMES
# ============================================================================

puts
puts "Valid cross-style games:"

run_test("parses C/s (Chess vs Shogi, first to move)") do
  result = Sashite::Feen::Parser::StyleTurn.parse("C/s")
  raise "wrong active abbr" unless result[:active].abbr == :C
  raise "wrong inactive abbr" unless result[:inactive].abbr == :S
  raise "wrong active side" unless result[:active].side == :first
  raise "wrong inactive side" unless result[:inactive].side == :second
end

run_test("parses s/C (Shogi vs Chess, second to move)") do
  result = Sashite::Feen::Parser::StyleTurn.parse("s/C")
  raise "wrong active abbr" unless result[:active].abbr == :S
  raise "wrong inactive abbr" unless result[:inactive].abbr == :C
  raise "wrong active side" unless result[:active].side == :second
  raise "wrong inactive side" unless result[:inactive].side == :first
end

run_test("parses S/c (Shogi vs Chess, first to move)") do
  result = Sashite::Feen::Parser::StyleTurn.parse("S/c")
  raise "wrong active abbr" unless result[:active].abbr == :S
  raise "wrong inactive abbr" unless result[:inactive].abbr == :C
end

run_test("parses X/g (Xiangqi vs Go)") do
  result = Sashite::Feen::Parser::StyleTurn.parse("X/g")
  raise "wrong active abbr" unless result[:active].abbr == :X
  raise "wrong inactive abbr" unless result[:inactive].abbr == :G
end

run_test("parses A/z (arbitrary styles)") do
  result = Sashite::Feen::Parser::StyleTurn.parse("A/z")
  raise "wrong active abbr" unless result[:active].abbr == :A
  raise "wrong inactive abbr" unless result[:inactive].abbr == :Z
end

# ============================================================================
# ALL LETTERS
# ============================================================================

puts
puts "All letters:"

run_test("accepts all uppercase letters as active") do
  ("A".."Z").each do |letter|
    result = Sashite::Feen::Parser::StyleTurn.parse("#{letter}/a")
    raise "failed for #{letter}" unless result[:active].side == :first
  end
end

run_test("accepts all lowercase letters as active") do
  ("a".."z").each do |letter|
    result = Sashite::Feen::Parser::StyleTurn.parse("#{letter}/A")
    raise "failed for #{letter}" unless result[:active].side == :second
  end
end

# ============================================================================
# DELIMITER VALIDATION
# ============================================================================

puts
puts "Delimiter validation:"

run_test("rejects missing delimiter") do
  Sashite::Feen::Parser::StyleTurn.parse("Cc")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid style-turn delimiter"
end

run_test("rejects multiple delimiters") do
  Sashite::Feen::Parser::StyleTurn.parse("C/c/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid style-turn delimiter"
end

run_test("rejects empty string") do
  Sashite::Feen::Parser::StyleTurn.parse("")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid style-turn delimiter"
end

run_test("rejects only delimiter") do
  Sashite::Feen::Parser::StyleTurn.parse("/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid style token"
end

run_test("rejects three delimiters") do
  Sashite::Feen::Parser::StyleTurn.parse("C/c/x")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid style-turn delimiter"
end

# ============================================================================
# INVALID STYLE TOKEN
# ============================================================================

puts
puts "Invalid style token:"

run_test("rejects empty active style") do
  Sashite::Feen::Parser::StyleTurn.parse("/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid style token"
end

run_test("rejects empty inactive style") do
  Sashite::Feen::Parser::StyleTurn.parse("C/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid style token"
end

run_test("rejects digit as active style") do
  Sashite::Feen::Parser::StyleTurn.parse("1/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid style token"
end

run_test("rejects digit as inactive style") do
  Sashite::Feen::Parser::StyleTurn.parse("C/1")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid style token"
end

run_test("rejects multiple letters as active style") do
  Sashite::Feen::Parser::StyleTurn.parse("CC/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid style token"
end

run_test("rejects multiple letters as inactive style") do
  Sashite::Feen::Parser::StyleTurn.parse("C/cc")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid style token"
end

run_test("rejects special character as active style") do
  Sashite::Feen::Parser::StyleTurn.parse("@/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid style token"
end

run_test("rejects special character as inactive style") do
  Sashite::Feen::Parser::StyleTurn.parse("C/@")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid style token"
end

run_test("rejects space in token") do
  Sashite::Feen::Parser::StyleTurn.parse("C /c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "invalid style token"
end

# ============================================================================
# SAME CASE VALIDATION
# ============================================================================

puts
puts "Same case validation:"

run_test("rejects both uppercase (C/C)") do
  Sashite::Feen::Parser::StyleTurn.parse("C/C")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "style tokens must have opposite case"
end

run_test("rejects both lowercase (c/c)") do
  Sashite::Feen::Parser::StyleTurn.parse("c/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "style tokens must have opposite case"
end

run_test("rejects both uppercase different letters (C/S)") do
  Sashite::Feen::Parser::StyleTurn.parse("C/S")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "style tokens must have opposite case"
end

run_test("rejects both lowercase different letters (c/s)") do
  Sashite::Feen::Parser::StyleTurn.parse("c/s")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "style tokens must have opposite case"
end

run_test("rejects A/A") do
  Sashite::Feen::Parser::StyleTurn.parse("A/A")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "style tokens must have opposite case"
end

run_test("rejects z/z") do
  Sashite::Feen::Parser::StyleTurn.parse("z/z")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == "style tokens must have opposite case"
end

# ============================================================================
# RETURN STRUCTURE
# ============================================================================

puts
puts "Return structure:"

run_test("returns hash with :active key") do
  result = Sashite::Feen::Parser::StyleTurn.parse("C/c")
  raise "missing :active" unless result.key?(:active)
end

run_test("returns hash with :inactive key") do
  result = Sashite::Feen::Parser::StyleTurn.parse("C/c")
  raise "missing :inactive" unless result.key?(:inactive)
end

run_test(":active is Sin::Identifier") do
  result = Sashite::Feen::Parser::StyleTurn.parse("C/c")
  raise "wrong type" unless result[:active].is_a?(Sashite::Sin::Identifier)
end

run_test(":inactive is Sin::Identifier") do
  result = Sashite::Feen::Parser::StyleTurn.parse("C/c")
  raise "wrong type" unless result[:inactive].is_a?(Sashite::Sin::Identifier)
end

run_test("Sin::Identifier responds to abbr") do
  result = Sashite::Feen::Parser::StyleTurn.parse("C/c")
  raise "should respond to abbr" unless result[:active].respond_to?(:abbr)
end

run_test("Sin::Identifier responds to side") do
  result = Sashite::Feen::Parser::StyleTurn.parse("C/c")
  raise "should respond to side" unless result[:active].respond_to?(:side)
end

# ============================================================================
# ERROR CLASS
# ============================================================================

puts
puts "Error class:"

run_test("raises Sashite::Feen::Errors::Argument for delimiter error") do
  Sashite::Feen::Parser::StyleTurn.parse("")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument
  # Expected
end

run_test("raises Sashite::Feen::Errors::Argument for invalid token") do
  Sashite::Feen::Parser::StyleTurn.parse("1/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument
  # Expected
end

run_test("raises Sashite::Feen::Errors::Argument for same case") do
  Sashite::Feen::Parser::StyleTurn.parse("C/C")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument
  # Expected
end

run_test("error is rescuable as ArgumentError") do
  Sashite::Feen::Parser::StyleTurn.parse("")
  raise "should have raised"
rescue ArgumentError
  # Expected
end

puts
puts "All Parser::StyleTurn tests passed!"
puts
