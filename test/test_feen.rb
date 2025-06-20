# frozen_string_literal: true

# Tests for Feen module conforming to FEEN Specification v1.0.0
#
# Feen module provides the main public API for FEEN operations:
# - dump: converts position components to FEEN string
# - parse: converts FEEN string to position components
# - safe_parse: like parse but returns nil instead of raising exceptions
# - valid?: validates if a string is a valid and canonical FEEN string
#
# This test assumes the existence of the following files:
# - lib/feen.rb

require_relative "../lib/feen"

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
puts "Tests for Feen module"
puts

# Main API delegation tests
run_test("dump delegates to Dumper") do
  piece_placement = [["r", "k", "r"], ["", "P", ""]]
  result = Feen.dump(
    piece_placement: piece_placement,
    pieces_in_hand:  ["P"],
    style_turn:      %w[CHESS chess]
  )

  expected = "rkr/1P1 P/ CHESS/chess"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

run_test("parse delegates to Parser") do
  feen_string = "rkr/1P1 P/ CHESS/chess"
  result = Feen.parse(feen_string)

  expected_piece_placement = [["r", "k", "r"], ["", "P", ""]]

  raise "Wrong piece_placement" unless result[:piece_placement] == expected_piece_placement
  raise "Wrong pieces_in_hand" unless result[:pieces_in_hand] == ["P"]
  raise "Wrong style_turn" unless result[:style_turn] == %w[CHESS chess]
end

run_test("safe_parse delegates to Parser") do
  # Valid string
  result = Feen.safe_parse("K / TEST/test")
  raise "Should return hash for valid input" unless result.is_a?(Hash)

  # Invalid string
  result = Feen.safe_parse("invalid")
  raise "Should return nil for invalid input" unless result.nil?
end

# Round-trip consistency
run_test("Round-trip consistency (chess)") do
  original = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / CHESS/chess"
  parsed = Feen.parse(original)
  dumped = Feen.dump(**parsed)

  raise "Round-trip failed: '#{original}' != '#{dumped}'" unless original == dumped
end

run_test("Round-trip consistency (shogi with pieces in hand)") do
  original = "lnsgkg1nl/1r7/ppp1ppppp/3p5/9/2P6/PP1PPPPPP/1B5R1/LNSGKGSNL 5P2G2L/2g2sln SHOGI/shogi"
  parsed = Feen.parse(original)
  dumped = Feen.dump(**parsed)

  raise "Round-trip failed: '#{original}' != '#{dumped}'" unless original == dumped
end

run_test("Round-trip consistency (3D board)") do
  original = "rn/pp//RN/PP / FOO/bar"
  parsed = Feen.parse(original)
  dumped = Feen.dump(**parsed)

  raise "Round-trip failed: '#{original}' != '#{dumped}'" unless original == dumped
end

# Pieces in hand with modifiers
run_test("Round-trip consistency with modifiers in pieces in hand") do
  original = "8/8/8/8/8/8/8/8 9P5B3-P3+P'2+B2SK-P'RS'/bp FOO/bar"
  parsed = Feen.parse(original)
  dumped = Feen.dump(**parsed)

  raise "Round-trip failed: '#{original}' != '#{dumped}'" unless original == dumped
end

# Validation method
run_test("valid? returns true for canonical FEEN") do
  canonical_feen = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / SHOGI/shogi"
  raise "Should be valid" unless Feen.valid?(canonical_feen)
end

run_test("valid? returns false for invalid syntax") do
  invalid_feen = "invalid feen string"
  raise "Should be invalid" if Feen.valid?(invalid_feen)
end

run_test("valid? returns false for non-canonical pieces in hand") do
  # Valid syntax but wrong ordering in pieces in hand
  non_canonical = "8/8/8/8/8/8/8/8 P3K/ FOO/bar"
  raise "Should be non-canonical" if Feen.valid?(non_canonical)
end

run_test("valid? returns true for modifiers in pieces in hand") do
  # Modifiers ARE allowed in pieces in hand
  valid_with_modifiers = "8/8/8/8/8/8/8/8 42+B'41+A41+A'/42-b' FOO/bar"
  raise "Should be valid with modifiers in hand" unless Feen.valid?(valid_with_modifiers)
end

run_test("valid? returns false for same casing in style turn") do
  invalid_casing = "8/8/8/8/8/8/8/8 / CHESS/SHOGI"
  raise "Should be invalid due to same casing" if Feen.valid?(invalid_casing)
end

run_test("valid? validates through round-trip") do
  # This should be valid and canonical
  valid_input = "k/K 2BP/np TEST/test"

  # First check that it parses and dumps correctly
  parsed = Feen.parse(valid_input)
  dumped = Feen.dump(**parsed)

  # Then check that valid? agrees
  raise "Should be valid (round-trip works)" unless Feen.valid?(valid_input)
  raise "Round-trip should be consistent" unless valid_input == dumped
end

# Error handling consistency
run_test("All methods handle same error cases consistently") do
  invalid_inputs = [
    "too few fields",
    "too many fields here",
    "K invalid@format TEST/test",
    "K / INVALID@STYLES"
  ]

  invalid_inputs.each do |invalid_input|
    # parse should raise an error
    parse_raised = false
    begin
      Feen.parse(invalid_input)
    rescue ArgumentError
      parse_raised = true
    end
    raise "parse should raise error for: #{invalid_input}" unless parse_raised

    # safe_parse should return nil
    safe_result = Feen.safe_parse(invalid_input)
    raise "safe_parse should return nil for: #{invalid_input}" unless safe_result.nil?

    # valid? should return false
    raise "valid? should return false for: #{invalid_input}" if Feen.valid?(invalid_input)
  end
end

# Example from README
run_test("README example works correctly") do
  piece_placement = [
    ["r", "n", "b", "q", "k", "b", "n", "r"],
    ["p", "p", "p", "p", "p", "p", "p", "p"],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["", "", "", "", "", "", "", ""],
    ["P", "P", "P", "P", "P", "P", "P", "P"],
    ["R", "N", "B", "Q", "K", "B", "N", "R"]
  ]

  # Test dump
  result = Feen.dump(
    piece_placement: piece_placement,
    pieces_in_hand:  [],
    style_turn:      %w[CHESS chess]
  )
  expected = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / CHESS/chess"
  raise "README dump example failed" unless result == expected

  # Test parse
  parsed = Feen.parse(expected)
  raise "README parse example failed (piece_placement)" unless parsed[:piece_placement] == piece_placement
  raise "README parse example failed (pieces_in_hand)" unless parsed[:pieces_in_hand] == []
  raise "README parse example failed (style_turn)" unless parsed[:style_turn] == %w[CHESS chess]
end

# Keyword arguments requirement
run_test("dump requires keyword arguments") do
  # Should fail - positional arguments not allowed
  Feen.dump([["K"]], [], %w[TEST test])
  raise "Should require keyword arguments"
rescue ArgumentError => e
  # Should get an error about wrong number of arguments or missing keywords
  unless e.message.include?("wrong number of arguments") || e.message.include?("missing keyword")
    raise "Wrong error type"
  end
end

# Edge cases
run_test("Handles minimal valid FEEN") do
  minimal = "K / A/b"

  # Should parse
  result = Feen.parse(minimal)
  raise "Should parse minimal FEEN" unless result.is_a?(Hash)

  # Should be valid
  raise "Minimal FEEN should be valid" unless Feen.valid?(minimal)

  # Should round-trip
  dumped = Feen.dump(**result)
  raise "Minimal FEEN should round-trip" unless minimal == dumped
end

run_test("Handles complex promoted pieces") do
  complex = "lnsgk3l/5g3/p1ppB2pp/9/8B/2P6/P2PPPPPP/3K3R1/5rSNL 5P2G2L/2g2sln SHOGI/shogi"

  # Should parse (has promoted pieces on board: +B, +r, +S)
  result = Feen.parse(complex)
  raise "Should parse complex FEEN with promoted pieces" unless result.is_a?(Hash)

  # Should be valid
  raise "Complex FEEN should be valid" unless Feen.valid?(complex)

  # Should round-trip
  dumped = Feen.dump(**result)
  raise "Complex FEEN should round-trip" unless complex == dumped
end

# Style identifiers with numbers
run_test("Handles style identifiers with numbers") do
  chess960_feen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / CHESS960/makruk"

  # Should parse
  result = Feen.parse(chess960_feen)
  raise "Should parse FEEN with numeric style identifiers" unless result.is_a?(Hash)

  # Should be valid
  raise "FEEN with numeric style identifiers should be valid" unless Feen.valid?(chess960_feen)

  # Should round-trip
  dumped = Feen.dump(**result)
  raise "FEEN with numeric style identifiers should round-trip" unless chess960_feen == dumped

  # Check style_turn content
  raise "Wrong style_turn parsing" unless result[:style_turn] == %w[CHESS960 makruk]
end

# Cross-style games
run_test("Handles cross-style games correctly") do
  cross_style = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR P/s CHESS/makruk"

  # Should parse
  result = Feen.parse(cross_style)
  raise "Should parse cross-style FEEN" unless result.is_a?(Hash)

  # Should be valid
  raise "Cross-style FEEN should be valid" unless Feen.valid?(cross_style)

  # Should round-trip
  dumped = Feen.dump(**result)
  raise "Cross-style FEEN should round-trip" unless cross_style == dumped

  # Verify different style names
  styles = result[:style_turn]
  raise "Should have different style names" unless styles[0].downcase != styles[1].downcase
end

puts
puts "All tests passed! ✓"
