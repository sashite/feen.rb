# frozen_string_literal: true

require_relative "../../../lib/feen/parser/pieces_in_hand"

# File: test/feen/parser/test_pieces_in_hand.rb

puts "Running Feen::Parser::PiecesInHand tests..."

# --- Tests for valid cases ---

# Test 1: No pieces in hand (format: "/")
result = Feen::Parser::PiecesInHand.parse("/")
expected = []
raise "Test 1 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 1 passed: No pieces in hand"

# Test 2: Single uppercase piece
result = Feen::Parser::PiecesInHand.parse("P/")
expected = ["P"]
raise "Test 2 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 2 passed: Single uppercase piece"

# Test 2b: Single lowercase piece
result = Feen::Parser::PiecesInHand.parse("/p")
expected = ["p"]
raise "Test 2b failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 2b passed: Single lowercase piece"

# Test 3: Multiple uppercase pieces in canonical order
result = Feen::Parser::PiecesInHand.parse("BNP/")
expected = %w[B N P]
raise "Test 3 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 3 passed: Multiple uppercase pieces in order"

# Test 3b: Multiple lowercase pieces in canonical order
result = Feen::Parser::PiecesInHand.parse("/bnp")
expected = %w[b n p]
raise "Test 3b failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 3b passed: Multiple lowercase pieces in order"

# Test 4: Pieces with counts (uppercase)
result = Feen::Parser::PiecesInHand.parse("3P2B/")
expected = %w[B B P P P]
raise "Test 4 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 4 passed: Uppercase pieces with counts"

# Test 4b: Pieces with counts (lowercase)
result = Feen::Parser::PiecesInHand.parse("/3p2b")
expected = %w[b b p p p]
raise "Test 4b failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 4b passed: Lowercase pieces with counts"

# Test 5: Piece with + prefix (uppercase)
result = Feen::Parser::PiecesInHand.parse("+P/")
expected = ["+P"]
raise "Test 5 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 5 passed: Uppercase piece with + prefix"

# Test 6: Piece with - prefix (lowercase)
result = Feen::Parser::PiecesInHand.parse("/-p")
expected = ["-p"]
raise "Test 6 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 6 passed: Lowercase piece with - prefix"

# Test 7: Piece with ' suffix (uppercase)
result = Feen::Parser::PiecesInHand.parse("P'/")
expected = ["P'"]
raise "Test 7 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 7 passed: Uppercase piece with ' suffix"

# Test 8: Piece with both prefix and suffix (uppercase)
result = Feen::Parser::PiecesInHand.parse("+P'/")
expected = ["+P'"]
raise "Test 8 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 8 passed: Piece with prefix and suffix"

# Test 9: Mixed case with modifiers and counts
result = Feen::Parser::PiecesInHand.parse("3+P2B'/2p'-p")
expected = ["+P", "+P", "+P", "-p", "B'", "B'", "p'", "p'"]
raise "Test 9 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 9 passed: Mixed case with modifiers and counts"

# Test 10: Canonical ordering example adapted for case separation
result = Feen::Parser::PiecesInHand.parse("10P5K4B+PR/2p'-pbq")
expected = ["+P",
            "-p",
            "B", "B", "B", "B",
            "K", "K", "K", "K", "K",
            "P", "P", "P", "P", "P", "P", "P", "P", "P", "P",
            "R",
            "b",
            "p'", "p'",
            "q"]
raise "Test 10 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 10 passed: Canonical ordering with case separation"

# Test 11: Large counts (uppercase)
result = Feen::Parser::PiecesInHand.parse("100P/")
expected_size = 100
raise "Test 11 failed: Expected array size #{expected_size}, got #{result.size}" unless result.size == expected_size
raise "Test 11 failed: Not all elements are 'P'" unless result.all? { |p| p == "P" }

puts "✓ Test 11 passed: Large counts"

# Test 12: Mixed case with modifiers (both sections)
result = Feen::Parser::PiecesInHand.parse("2+P/2-p")
expected = ["+P", "+P", "-p", "-p"]
raise "Test 12 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 12 passed: Mixed case with modifiers"

# Test 13: All modifier combinations in canonical order (uppercase)
result = Feen::Parser::PiecesInHand.parse("+P-PPP'/")
expected = ["+P", "-P", "P", "P'"]
raise "Test 13 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 13 passed: All modifier combinations"

# Test 13b: Debug alphabetical order of modifiers
pieces = ["+P", "-P", "P'", "P"]
sorted_pieces = pieces.sort
puts "Debug: Alphabetical order of pieces: #{sorted_pieces.inspect}"

# Test 14: Complex mixed case scenario
result = Feen::Parser::PiecesInHand.parse("3P+PB'K/2p+pb'k")
expected = ["+P", "+p", "B'", "K", "P", "P", "P", "b'", "k", "p", "p"]
raise "Test 14 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 14 passed: Complex mixed case scenario"

# Test 15: Same letter different cases
result = Feen::Parser::PiecesInHand.parse("2P/2p")
expected = %w[P P p p]
raise "Test 15 failed: Expected #{expected.inspect}, got #{result.inspect}" unless result == expected

puts "✓ Test 15 passed: Same letter different cases"

# --- Tests for error cases ---

# Test 16: Non-string input
begin
  Feen::Parser::PiecesInHand.parse(123)
  raise "Test 16 failed: Should have raised ArgumentError for non-string input"
rescue ArgumentError => e
  expected_message = "Pieces in hand must be a string, got Integer"
  unless e.message == expected_message
    raise "Test 16 failed: Wrong error message. Expected '#{expected_message}', got '#{e.message}'"
  end

  puts "✓ Test 16 passed: Non-string input error"
end

# Test 17: Empty string
begin
  Feen::Parser::PiecesInHand.parse("")
  raise "Test 17 failed: Should have raised ArgumentError for empty string"
rescue ArgumentError => e
  expected_message = "Pieces in hand string cannot be empty"
  unless e.message == expected_message
    raise "Test 17 failed: Wrong error message. Expected '#{expected_message}', got '#{e.message}'"
  end

  puts "✓ Test 17 passed: Empty string error"
end

# Test 18: Missing separator
begin
  Feen::Parser::PiecesInHand.parse("P")
  raise "Test 18 failed: Should have raised ArgumentError for missing separator"
rescue ArgumentError => e
  unless e.message.include?("Invalid pieces in hand format: P")
    raise "Test 18 failed: Wrong error message: #{e.message}"
  end

  puts "✓ Test 18 passed: Missing separator error"
end

# Test 19: Too many separators
begin
  Feen::Parser::PiecesInHand.parse("P/p/q")
  raise "Test 19 failed: Should have raised ArgumentError for too many separators"
rescue ArgumentError => e
  unless e.message.include?("Invalid pieces in hand format: P/p/q")
    raise "Test 19 failed: Wrong error message: #{e.message}"
  end

  puts "✓ Test 19 passed: Too many separators error"
end

# Test 20: Invalid pieces in hand format (double prefix)
begin
  Feen::Parser::PiecesInHand.parse("++P/")
  raise "Test 20 failed: Should have raised ArgumentError for invalid PNN format"
rescue ArgumentError => e
  unless e.message.include?("Invalid pieces in hand format: ++P") || e.message.include?("Invalid PNN piece format")
    raise "Test 20 failed: Wrong error type or message: #{e.message}"
  end

  puts "✓ Test 20 passed: Invalid PNN format error"
end

# Test 21: Invalid count (0)
begin
  Feen::Parser::PiecesInHand.parse("0P/")
  raise "Test 21 failed: Should have raised ArgumentError for count 0"
rescue ArgumentError => e
  unless e.message.include?("Invalid pieces in hand format: 0P") || e.message.include?("Invalid count format")
    raise "Test 21 failed: Wrong error message: #{e.message}"
  end

  puts "✓ Test 21 passed: Invalid count 0 error"
end

# Test 22: Invalid count (1)
begin
  Feen::Parser::PiecesInHand.parse("1P/")
  raise "Test 22 failed: Should have raised ArgumentError for count 1"
rescue ArgumentError => e
  unless e.message.include?("Invalid pieces in hand format: 1P") || e.message.include?("Invalid count format")
    raise "Test 22 failed: Wrong error message: #{e.message}"
  end

  puts "✓ Test 22 passed: Invalid count 1 error"
end

# Test 23: Invalid overall format (special characters)
begin
  Feen::Parser::PiecesInHand.parse("P@Q/")
  raise "Test 23 failed: Should have raised ArgumentError for invalid format"
rescue ArgumentError => e
  unless e.message.include?("Invalid pieces in hand format: P@Q")
    raise "Test 23 failed: Wrong error message: #{e.message}"
  end

  puts "✓ Test 23 passed: Invalid format error"
end

# Test 24: Wrong case in section (lowercase in uppercase section)
begin
  Feen::Parser::PiecesInHand.parse("Pp/")
  raise "Test 24 failed: Should have raised ArgumentError for wrong case in section"
rescue ArgumentError => e
  unless e.message.include?("contains lowercase piece") || e.message.include?("Invalid pieces in hand format")
    raise "Test 24 failed: Wrong error message: #{e.message}"
  end

  puts "✓ Test 24 passed: Wrong case in uppercase section error"
end

# Test 25: Wrong case in section (uppercase in lowercase section)
begin
  Feen::Parser::PiecesInHand.parse("/pP")
  raise "Test 25 failed: Should have raised ArgumentError for wrong case in section"
rescue ArgumentError => e
  unless e.message.include?("contains uppercase piece") || e.message.include?("Invalid pieces in hand format")
    raise "Test 25 failed: Wrong error message: #{e.message}"
  end

  puts "✓ Test 25 passed: Wrong case in lowercase section error"
end
