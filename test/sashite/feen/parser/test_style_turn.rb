#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/parser/style_turn"

puts
puts "=== Parser::StyleTurn Tests ==="
puts

StyleTurn = Sashite::Feen::Parser::StyleTurn
StyleTurnError = Sashite::Feen::StyleTurnError

# ============================================================================
# VALID PARSING - FIRST PLAYER TO MOVE
# ============================================================================

puts "Valid parsing - first player to move:"

run_test("parses first to move with same style") do
  result = StyleTurn.parse("C/c")
  raise "expected :active key" unless result.key?(:active)
  raise "expected :inactive key" unless result.key?(:inactive)
  raise "expected first player active" unless result[:active].side == :first
  raise "expected second player inactive" unless result[:inactive].side == :second
end

run_test("parses first to move with different styles") do
  result = StyleTurn.parse("C/s")
  raise "expected C active" unless result[:active].abbr == :C
  raise "expected S inactive" unless result[:inactive].abbr == :S
  raise "expected first player active" unless result[:active].side == :first
  raise "expected second player inactive" unless result[:inactive].side == :second
end

run_test("parses various style letters") do
  %w[A/a Z/z S/s X/x G/g].each do |input|
    result = StyleTurn.parse(input)
    raise "expected first active for #{input}" unless result[:active].side == :first
  end
end

# ============================================================================
# VALID PARSING - SECOND PLAYER TO MOVE
# ============================================================================

puts
puts "Valid parsing - second player to move:"

run_test("parses second to move with same style") do
  result = StyleTurn.parse("c/C")
  raise "expected second player active" unless result[:active].side == :second
  raise "expected first player inactive" unless result[:inactive].side == :first
end

run_test("parses second to move with different styles") do
  result = StyleTurn.parse("s/C")
  raise "expected s active" unless result[:active].abbr == :S
  raise "expected C inactive" unless result[:inactive].abbr == :C
  raise "expected second player active" unless result[:active].side == :second
end

run_test("parses various style letters second to move") do
  %w[a/A z/Z s/S x/X g/G].each do |input|
    result = StyleTurn.parse(input)
    raise "expected second active for #{input}" unless result[:active].side == :second
  end
end

# ============================================================================
# VALID PARSING - CROSS-STYLE GAMES
# ============================================================================

puts
puts "Valid parsing - cross-style games:"

run_test("parses Chess vs Shogi (first to move)") do
  result = StyleTurn.parse("C/s")
  raise "expected C" unless result[:active].abbr == :C
  raise "expected S" unless result[:inactive].abbr == :S
end

run_test("parses Chess vs Shogi (second to move)") do
  result = StyleTurn.parse("s/C")
  raise "expected S active" unless result[:active].abbr == :S
  raise "expected C inactive" unless result[:inactive].abbr == :C
end

run_test("parses Xiangqi vs Go") do
  result = StyleTurn.parse("X/g")
  raise "expected X" unless result[:active].abbr == :X
  raise "expected G" unless result[:inactive].abbr == :G
end

run_test("parses all letter combinations work") do
  # Different letters, opposite case
  result = StyleTurn.parse("A/z")
  raise "expected A" unless result[:active].abbr == :A
  raise "expected Z" unless result[:inactive].abbr == :Z
end

# ============================================================================
# RESULT STRUCTURE
# ============================================================================

puts
puts "Result structure:"

run_test("returns Hash") do
  result = StyleTurn.parse("C/c")
  raise "expected Hash" unless ::Hash === result
end

run_test("has :active and :inactive keys") do
  result = StyleTurn.parse("C/c")
  raise "expected :active" unless result.key?(:active)
  raise "expected :inactive" unless result.key?(:inactive)
end

run_test("active has abbr method") do
  result = StyleTurn.parse("C/c")
  raise "expected abbr" unless result[:active].respond_to?(:abbr)
  raise "expected C" unless result[:active].abbr == :C
end

run_test("active has side method") do
  result = StyleTurn.parse("C/c")
  raise "expected side" unless result[:active].respond_to?(:side)
end

run_test("identifiers respond to to_s") do
  result = StyleTurn.parse("C/c")
  raise "expected C" unless result[:active].to_s == "C"
  raise "expected c" unless result[:inactive].to_s == "c"
end

# ============================================================================
# INVALID PARSING - DELIMITER ERRORS
# ============================================================================

puts
puts "Invalid parsing - delimiter errors:"

run_test("raises for missing delimiter") do
  StyleTurn.parse("Cc")
  raise "should have raised"
rescue StyleTurnError => e
  raise "wrong message" unless e.message == StyleTurnError::INVALID_DELIMITER
end

run_test("raises for empty string") do
  StyleTurn.parse("")
  raise "should have raised"
rescue StyleTurnError => e
  raise "wrong message" unless e.message == StyleTurnError::INVALID_DELIMITER
end

run_test("raises for multiple delimiters") do
  StyleTurn.parse("C/c/s")
  raise "should have raised"
rescue StyleTurnError => e
  raise "wrong message" unless e.message == StyleTurnError::INVALID_DELIMITER
end

run_test("raises for only delimiter") do
  StyleTurn.parse("/")
  raise "should have raised"
rescue StyleTurnError => e
  raise "wrong message" unless e.message == StyleTurnError::INVALID_STYLE_TOKEN
end

# ============================================================================
# INVALID PARSING - STYLE TOKEN ERRORS
# ============================================================================

puts
puts "Invalid parsing - style token errors:"

run_test("raises for empty active style") do
  StyleTurn.parse("/c")
  raise "should have raised"
rescue StyleTurnError => e
  raise "wrong message" unless e.message == StyleTurnError::INVALID_STYLE_TOKEN
end

run_test("raises for empty inactive style") do
  StyleTurn.parse("C/")
  raise "should have raised"
rescue StyleTurnError => e
  raise "wrong message" unless e.message == StyleTurnError::INVALID_STYLE_TOKEN
end

run_test("raises for digit as style") do
  StyleTurn.parse("1/c")
  raise "should have raised"
rescue StyleTurnError => e
  raise "wrong message" unless e.message == StyleTurnError::INVALID_STYLE_TOKEN
end

run_test("raises for multiple letters as style") do
  StyleTurn.parse("CC/c")
  raise "should have raised"
rescue StyleTurnError => e
  raise "wrong message" unless e.message == StyleTurnError::INVALID_STYLE_TOKEN
end

run_test("raises for special character as style") do
  StyleTurn.parse("@/c")
  raise "should have raised"
rescue StyleTurnError => e
  raise "wrong message" unless e.message == StyleTurnError::INVALID_STYLE_TOKEN
end

# ============================================================================
# INVALID PARSING - SAME CASE ERRORS
# ============================================================================

puts
puts "Invalid parsing - same case errors:"

run_test("raises for both uppercase") do
  StyleTurn.parse("C/C")
  raise "should have raised"
rescue StyleTurnError => e
  raise "wrong message" unless e.message == StyleTurnError::SAME_CASE
end

run_test("raises for both lowercase") do
  StyleTurn.parse("c/c")
  raise "should have raised"
rescue StyleTurnError => e
  raise "wrong message" unless e.message == StyleTurnError::SAME_CASE
end

run_test("raises for different letters but both uppercase") do
  StyleTurn.parse("C/S")
  raise "should have raised"
rescue StyleTurnError => e
  raise "wrong message" unless e.message == StyleTurnError::SAME_CASE
end

run_test("raises for different letters but both lowercase") do
  StyleTurn.parse("c/s")
  raise "should have raised"
rescue StyleTurnError => e
  raise "wrong message" unless e.message == StyleTurnError::SAME_CASE
end

# ============================================================================
# ERROR TYPE
# ============================================================================

puts
puts "Error type:"

run_test("error is StyleTurnError") do
  StyleTurn.parse("invalid")
  raise "should have raised"
rescue StyleTurnError
  # Expected
end

run_test("error is also ArgumentError") do
  StyleTurn.parse("invalid")
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
  raise "expected frozen" unless StyleTurn.frozen?
end

run_test("parse is the only public method") do
  public_methods = StyleTurn.methods(false) - Object.methods
  raise "expected only :parse, got #{public_methods}" unless public_methods == [:parse]
end

# ============================================================================
# REAL-WORLD EXAMPLES
# ============================================================================

puts
puts "Real-world examples:"

run_test("parses Chess game") do
  result = StyleTurn.parse("C/c")
  raise "wrong active style" unless result[:active].abbr == :C
  raise "wrong inactive style" unless result[:inactive].abbr == :C
end

run_test("parses Shogi game") do
  result = StyleTurn.parse("S/s")
  raise "wrong active style" unless result[:active].abbr == :S
end

run_test("parses Xiangqi game") do
  result = StyleTurn.parse("X/x")
  raise "wrong active style" unless result[:active].abbr == :X
end

run_test("parses Go game") do
  result = StyleTurn.parse("G/g")
  raise "wrong active style" unless result[:active].abbr == :G
end

run_test("parses hybrid Chess-Shogi game") do
  result = StyleTurn.parse("C/s")
  raise "expected Chess first" unless result[:active].abbr == :C
  raise "expected Shogi second" unless result[:inactive].abbr == :S
end

puts
puts "All Parser::StyleTurn tests passed!"
puts
