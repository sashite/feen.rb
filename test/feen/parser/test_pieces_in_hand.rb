# frozen_string_literal: true

require_relative "../../../lib/feen/parser/pieces_in_hand"

# File: test/feen/parser/test_pieces_in_hand.rb

puts "Running Feen::Parser::PiecesInHand tests..."

# --- Tests for valid cases ---

# Test 1: No pieces in hand (dash)
result = Feen::Parser::PiecesInHand.parse("-")
expected = []
raise "Test 1 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 1 passed: No pieces in hand"

# Test 2: Single piece without modifier
result = Feen::Parser::PiecesInHand.parse("P")
expected = ["P"]
raise "Test 2 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 2 passed: Single piece"

# Test 3: Multiple pieces in canonical order
result = Feen::Parser::PiecesInHand.parse("BNP")
expected = %w[B N P]
raise "Test 3 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 3 passed: Multiple pieces in order"

# Test 4: Pieces with counts
result = Feen::Parser::PiecesInHand.parse("3P2B")
expected = %w[P P P B B]
raise "Test 4 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 4 passed: Pieces with counts"

# Test 5: Piece with + prefix
result = Feen::Parser::PiecesInHand.parse("+P")
expected = ["+P"]
raise "Test 5 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 5 passed: Piece with + prefix"

# Test 6: Piece with - prefix
result = Feen::Parser::PiecesInHand.parse("-p")
expected = ["-p"]
raise "Test 6 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 6 passed: Piece with - prefix"

# Test 7: Piece with ' suffix
result = Feen::Parser::PiecesInHand.parse("P'")
expected = ["P'"]
raise "Test 7 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 7 passed: Piece with ' suffix"

# Test 8: Piece with both prefix and suffix
result = Feen::Parser::PiecesInHand.parse("+P'")
expected = ["+P'"]
raise "Test 8 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 8 passed: Piece with prefix and suffix"

# Test 9: Complex example with modifiers and counts (canonical order: by quantity desc, then alphabetical)
# Alphabetical order: "+P" < "-p" < "B'" < "P"
# Quantities: 3, 2, 1, 1 -> canonical: "3+P2B'-pP"
result = Feen::Parser::PiecesInHand.parse("3+P2B'-pP")
expected = ["+P", "+P", "+P", "B'", "B'", "-p", "P"]
raise "Test 9 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 9 passed: Complex with modifiers and counts"

# Test 10: Canonical ordering example from FEEN spec
result = Feen::Parser::PiecesInHand.parse("10P5K3B2p'+P-pBRbq")
expected = ["P", "P", "P", "P", "P", "P", "P", "P", "P", "P",
            "K", "K", "K", "K", "K",
            "B", "B", "B",
            "p'", "p'",
            "+P", "-p", "B", "R", "b", "q"]
raise "Test 10 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 10 passed: Canonical ordering from spec"

# Test 11: Large counts
result = Feen::Parser::PiecesInHand.parse("100P")
expected_size = 100
raise "Test 11 failed: Expected array size #{expected_size}, got #{result.size}" unless result.size == expected_size
raise "Test 11 failed: Not all elements are 'P'" unless result.all? { |p| p == "P" }

puts "✓ Test 11 passed: Large counts"

# Test 12: Mixed case with modifiers
result = Feen::Parser::PiecesInHand.parse("2+P2-p")
expected = ["+P", "+P", "-p", "-p"]
raise "Test 12 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 12 passed: Mixed case with modifiers"

# Test 13: All modifier combinations in canonical order
result = Feen::Parser::PiecesInHand.parse("+P-PPP'")
expected = ["+P", "-P", "P", "P'"]
raise "Test 13 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 13 passed: All modifier combinations"

# Test 13b: Debug alphabetical order of modifiers
pieces = ["+P", "-P", "P'", "P"]
sorted_pieces = pieces.sort
puts "Debug: Alphabetical order of pieces: #{sorted_pieces.inspect}"

# --- Tests for error cases ---

# Test 14: Non-string input
begin
  Feen::Parser::PiecesInHand.parse(123)
  raise "Test 14 failed: Should have raised ArgumentError for non-string input"
rescue ArgumentError => e
  expected_message = "Pieces in hand must be a string, got Integer"
  unless e.message == expected_message
    raise "Test 14 failed: Wrong error message. Expected '#{expected_message}', got '#{e.message}'"
  end

  puts "✓ Test 14 passed: Non-string input error"
end

# Test 15: Empty string
begin
  Feen::Parser::PiecesInHand.parse("")
  raise "Test 15 failed: Should have raised ArgumentError for empty string"
rescue ArgumentError => e
  expected_message = "Pieces in hand string cannot be empty"
  unless e.message == expected_message
    raise "Test 15 failed: Wrong error message. Expected '#{expected_message}', got '#{e.message}'"
  end

  puts "✓ Test 15 passed: Empty string error"
end

# Test 16: Invalid pieces in hand format (double prefix)
begin
  Feen::Parser::PiecesInHand.parse("++P")
  raise "Test 16 failed: Should have raised ArgumentError for invalid PNN format"
rescue ArgumentError => e
  unless e.message.include?("Invalid pieces in hand format: ++P")
    raise "Test 16 failed: Wrong error type or message: #{e.message}"
  end

  puts "✓ Test 16 passed: Invalid PNN format error"
end

# Test 17: Invalid count (0)
begin
  Feen::Parser::PiecesInHand.parse("0P")
  raise "Test 17 failed: Should have raised ArgumentError for count 0"
rescue ArgumentError => e
  unless e.message.include?("Invalid pieces in hand format: 0")
    raise "Test 17 failed: Wrong error message: #{e.message}"
  end

  puts "✓ Test 17 passed: Invalid count 0 error"
end

# Test 18: Invalid count (1)
begin
  Feen::Parser::PiecesInHand.parse("1P")
  raise "Test 18 failed: Should have raised ArgumentError for count 1"
rescue ArgumentError => e
  unless e.message.include?("Invalid pieces in hand format: 1")
    raise "Test 18 failed: Wrong error message: #{e.message}"
  end

  puts "✓ Test 18 passed: Invalid count 1 error"
end

# Test 19: Invalid overall format (special characters)
begin
  Feen::Parser::PiecesInHand.parse("P@Q")
  raise "Test 19 failed: Should have raised ArgumentError for invalid format"
rescue ArgumentError => e
  unless e.message.include?("Invalid pieces in hand format: P@Q")
    raise "Test 19 failed: Wrong error message: #{e.message}"
  end

  puts "✓ Test 19 passed: Invalid format error"
end

# Test 20: Non-canonical order (quantity not descending)
begin
  Feen::Parser::PiecesInHand.parse("2P5K")
  raise "Test 20 failed: Should have raised ArgumentError for non-canonical order"
rescue ArgumentError => e
  unless e.message.include?("canonical order") && e.message.include?("2P5K") && e.message.include?("5K2P")
    raise "Test 20 failed: Wrong error message: #{e.message}"
  end

  puts "✓ Test 20 passed: Non-canonical quantity order error"
end

# Test 21: Non-canonical order (alphabetical within same quantity)
begin
  Feen::Parser::PiecesInHand.parse("PB")
  raise "Test 21 failed: Should have raised ArgumentError for non-canonical alphabetical order"
rescue ArgumentError => e
  unless e.message.include?("canonical order") && e.message.include?("PB") && e.message.include?("BP")
    raise "Test 21 failed: Wrong error message: #{e.message}"
  end

  puts "✓ Test 21 passed: Non-canonical alphabetical order error"
end

# Test 22: Modifiers in wrong alphabetical order
begin
  Feen::Parser::PiecesInHand.parse("P+P")
  raise "Test 22 failed: Should have raised ArgumentError for wrong modifier order"
rescue ArgumentError => e
  unless e.message.include?("canonical order") && e.message.include?("P+P") && e.message.include?("+PP")
    raise "Test 22 failed: Wrong error message: #{e.message}"
  end

  puts "✓ Test 22 passed: Wrong modifier alphabetical order error"
end

puts "\n🎉 All tests passed! (22/22)"
puts "Feen::Parser::PiecesInHand implementation is working correctly."
