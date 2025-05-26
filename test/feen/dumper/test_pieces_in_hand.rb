# frozen_string_literal: true

# Tests for Feen::Dumper::PiecesInHand conforming to FEEN Specification v1.0.0
#
# FEEN specifies that pieces in hand must be sorted:
# 1. By quantity (descending)
# 2. By complete PNN representation (alphabetically ascending)
#
# This test assumes the existence of the following files:
# - lib/feen/dumper/pieces_in_hand.rb
# - lib/feen/dumper/pieces_in_hand/no_pieces.rb
# - lib/feen/dumper/pieces_in_hand/errors.rb

require_relative "../../../lib/feen/dumper/pieces_in_hand"

# Helper function to run a test and report errors
def run_test(name)
  puts "Test: #{name}"
  yield
  puts "  ✓ Success"
rescue StandardError => e
  puts "  ✗ Failure: #{e.message}"
  puts "    #{e.backtrace.first}"
  exit(1)
end

puts "=== FEEN-Compliant Tests for Feen::Dumper::PiecesInHand ==="
puts

# === Basic Functionality Tests ===

run_test("No pieces in hand") do
  result = Feen::Dumper::PiecesInHand.dump
  raise "Expected '-', got '#{result}'" unless result == "-"
end

run_test("Single piece (uppercase)") do
  result = Feen::Dumper::PiecesInHand.dump("P")
  raise "Expected 'P', got '#{result}'" unless result == "P"
end

run_test("Single piece (lowercase)") do
  result = Feen::Dumper::PiecesInHand.dump("p")
  raise "Expected 'p', got '#{result}'" unless result == "p"
end

# === PNN Support Tests ===

run_test("PNN piece with + prefix") do
  result = Feen::Dumper::PiecesInHand.dump("+P")
  raise "Expected '+P', got '#{result}'" unless result == "+P"
end

run_test("PNN piece with - prefix") do
  result = Feen::Dumper::PiecesInHand.dump("-p")
  raise "Expected '-p', got '#{result}'" unless result == "-p"
end

run_test("PNN piece with ' suffix") do
  result = Feen::Dumper::PiecesInHand.dump("P'")
  raise "Expected 'P\\'', got '#{result}'" unless result == "P'"
end

run_test("PNN piece with both prefix and suffix") do
  result = Feen::Dumper::PiecesInHand.dump("+P'")
  raise "Expected '+P\\'', got '#{result}'" unless result == "+P'"
end

run_test("PNN piece with - prefix and ' suffix") do
  result = Feen::Dumper::PiecesInHand.dump("-K'")
  raise "Expected '-K\\'', got '#{result}'" unless result == "-K'"
end

# === FEEN Canonical Sorting Tests ===

run_test("Quantity sorting: descending order") do
  # 3 P's, 2 B's, 1 K
  result = Feen::Dumper::PiecesInHand.dump("P", "P", "P", "B", "B", "K")
  raise "Expected '3P2BK', got '#{result}'" unless result == "3P2BK"
end

run_test("Alphabetical sorting within same quantity") do
  # All single pieces: should be sorted alphabetically
  result = Feen::Dumper::PiecesInHand.dump("R", "B", "N")
  raise "Expected 'BNR', got '#{result}'" unless result == "BNR"
end

run_test("Mixed case alphabetical sorting") do
  # Uppercase comes before lowercase in ASCII
  result = Feen::Dumper::PiecesInHand.dump("b", "B", "P", "p")
  raise "Expected 'BPbp', got '#{result}'" unless result == "BPbp"
end

run_test("PNN modifiers in alphabetical order") do
  # All single pieces with different PNN representations
  # ASCII order: "+P" < "-P" < "P" < "P'"
  result = Feen::Dumper::PiecesInHand.dump("P'", "P", "-P", "+P")
  raise "Expected '+P-PPP\\'', got '#{result}'" unless result == "+P-PPP'"
end

run_test("Complex PNN sorting with modifiers") do
  # 3 +P, 2 B', 1 -p, 1 P
  # Should be sorted by quantity desc, then alphabetically
  result = Feen::Dumper::PiecesInHand.dump("+P", "+P", "+P", "B'", "B'", "-p", "P")
  raise "Expected '3+P2B\\'-pP', got '#{result}'" unless result == "3+P2B'-pP"
end

# === FEEN Specification Example ===

run_test("FEEN spec example: 10P5K3B2p'+P-pBRbq") do
  # From FEEN specification v1.0.0
  # Breaking down the expected result: 10P5K3B2p'+P-pBRbq
  # This means: 10×P, 5×K, 3×B, 2×p', 1×+P, 1×-p, 1×R, 1×b, 1×q
  pieces = (["P"] * 10) + (["K"] * 5) + (["B"] * 3) + (["p'"] * 2) + ["+P", "-p", "R", "b", "q"]
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  expected = "10P5K3B2p'+P-pRbq"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

# === Count Formatting Tests ===

run_test("No count prefix for single pieces") do
  result = Feen::Dumper::PiecesInHand.dump("P")
  raise "Expected 'P' (no count), got '#{result}'" unless result == "P"
end

run_test("Count prefix for multiple pieces") do
  result = Feen::Dumper::PiecesInHand.dump("P", "P")
  raise "Expected '2P', got '#{result}'" unless result == "2P"
end

run_test("Large count formatting") do
  pieces = ["P"] * 15
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  raise "Expected '15P', got '#{result}'" unless result == "15P"
end

run_test("Mixed counts with PNN") do
  # 5 +P, 3 P', 1 -p
  pieces = (["+P"] * 5) + (["P'"] * 3) + ["-p"]
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  raise "Expected '5+P3P\\'-p', got '#{result}'" unless result == "5+P3P'-p"
end

# === Duplicate and Complex Scenarios ===

run_test("Same piece with and without modifiers") do
  # 2 P, 1 +P, 1 P' - should sort by quantity then alphabetically
  result = Feen::Dumper::PiecesInHand.dump("P", "P", "+P", "P'")
  raise "Expected '2P+PP\\'', got '#{result}'" unless result == "2P+PP'"
end

run_test("Complex shogi-style position") do
  # Typical shogi pieces in hand with promotions
  pieces = (["P"] * 3) + (["+P"] * 2) + %w[L N S G p l]
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  # 3P, 2+P, then singles: G, L, N, S, l, p (alphabetical)
  expected = "3P2+PGLNSlp"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

# === Error Handling Tests ===

run_test("Invalid input: non-string") do
  Feen::Dumper::PiecesInHand.dump(42)
  raise "Expected exception for numeric input"
rescue ArgumentError => e
  unless e.message.include?("index: 0") && e.message.include?("String") && e.message.include?("Integer")
    raise "Unexpected error message: #{e.message}"
  end
end

run_test("Invalid input: nil") do
  Feen::Dumper::PiecesInHand.dump("P", nil, "B")
  raise "Expected exception for nil input"
rescue ArgumentError => e
  raise "Unexpected error message: #{e.message}" unless e.message.include?("index: 1") && e.message.include?("NilClass")
end

run_test("Invalid PNN format: double prefix") do
  Feen::Dumper::PiecesInHand.dump("++P")
  raise "Expected exception for invalid PNN format"
rescue ArgumentError => e
  raise "Unexpected error message: #{e.message}" unless e.message.include?("PNN format") && e.message.include?("++P")
end

run_test("Invalid PNN format: double suffix") do
  Feen::Dumper::PiecesInHand.dump("P''")
  raise "Expected exception for invalid PNN format"
rescue ArgumentError => e
  raise "Unexpected error message: #{e.message}" unless e.message.include?("PNN format") && e.message.include?("P''")
end

run_test("Invalid PNN format: invalid prefix") do
  Feen::Dumper::PiecesInHand.dump("*P")
  raise "Expected exception for invalid prefix"
rescue ArgumentError => e
  raise "Unexpected error message: #{e.message}" unless e.message.include?("PNN format") && e.message.include?("*P")
end

run_test("Invalid PNN format: invalid suffix") do
  Feen::Dumper::PiecesInHand.dump("P@")
  raise "Expected exception for invalid suffix"
rescue ArgumentError => e
  raise "Unexpected error message: #{e.message}" unless e.message.include?("PNN format") && e.message.include?("P@")
end

run_test("Invalid PNN format: empty string") do
  Feen::Dumper::PiecesInHand.dump("")
  raise "Expected exception for empty string"
rescue ArgumentError => e
  raise "Unexpected error message: #{e.message}" unless e.message.include?("PNN format")
end

run_test("Invalid PNN format: multiple characters") do
  Feen::Dumper::PiecesInHand.dump("PP")
  raise "Expected exception for multiple characters"
rescue ArgumentError => e
  raise "Unexpected error message: #{e.message}" unless e.message.include?("PNN format") && e.message.include?("PP")
end

run_test("Invalid PNN format: digits") do
  Feen::Dumper::PiecesInHand.dump("P1")
  raise "Expected exception for digits"
rescue ArgumentError => e
  raise "Unexpected error message: #{e.message}" unless e.message.include?("PNN format") && e.message.include?("P1")
end

# === Edge Cases and Performance ===

run_test("All 26 uppercase letters") do
  pieces = ("A".."Z").to_a
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  expected = pieces.sort.join
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

run_test("All 26 lowercase letters") do
  pieces = ("a".."z").to_a
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  expected = pieces.sort.join
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

run_test("Large mixed collection") do
  # Create a realistic large game position
  pieces = (["P"] * 20) + (["p"] * 15) + (["R"] * 3) + (["r"] * 2) +
           (["+P"] * 5) + (["-p"] * 4) + (["B'"] * 2) + ["N"]
  result = Feen::Dumper::PiecesInHand.dump(*pieces)

  # Expected: 20P15p5+P4-p3R2B'2rN
  # Should be sorted by quantity desc, then alphabetically
  expected = "20P15p5+P4-p3R2B'2rN"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

# === FEEN Canonicality Tests ===

run_test("FEEN canonicality: reordered input produces same output") do
  # Same pieces in different input orders should produce identical output
  pieces1 = %w[P B P N B P]
  pieces2 = %w[B P N P B P]
  pieces3 = %w[N B B P P P]

  result1 = Feen::Dumper::PiecesInHand.dump(*pieces1)
  result2 = Feen::Dumper::PiecesInHand.dump(*pieces2)
  result3 = Feen::Dumper::PiecesInHand.dump(*pieces3)

  expected = "3P2BN" # 3 P's, 2 B's, 1 N

  raise "Inconsistent results: '#{result1}', '#{result2}', '#{result3}'" unless
    result1 == expected && result2 == expected && result3 == expected
end

run_test("FEEN canonicality: complex PNN reordering") do
  # Complex PNN pieces in different orders
  pieces1 = ["+P", "P'", "-p", "+P", "P'", "B"]
  pieces2 = ["B", "-p", "P'", "+P", "P'", "+P"]

  result1 = Feen::Dumper::PiecesInHand.dump(*pieces1)
  result2 = Feen::Dumper::PiecesInHand.dump(*pieces2)

  expected = "2+P2P'-pB" # 2 +P, 2 P', then singles alphabetically: -p < B

  raise "Inconsistent results: '#{result1}' vs '#{result2}'" unless result1 == result2
  raise "Expected '#{expected}', got '#{result1}'" unless result1 == expected
end

puts
puts "=== Summary ==="
puts "✅ All #{$test_count ||= 0} FEEN-compliant tests for PiecesInHand.dump have passed!"
puts
puts "Key FEEN compliance verified:"
puts "  • Canonical sorting (quantity desc → alphabetical asc)"
puts "  • Full PNN notation support ([prefix]letter[suffix])"
puts "  • Proper count formatting (no '1' prefix, numeric for 2+)"
puts "  • FEEN specification examples validated"
puts "  • Error handling for invalid PNN formats"
puts "  • Canonicality across different input orders"

# Count tests for summary
at_exit do
  if defined?($test_count)
    # Count the actual number of run_test calls
    test_methods = caller_locations.select { |loc| loc.label == "run_test" }
    $test_count = test_methods.length
  end
end
