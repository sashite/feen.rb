# frozen_string_literal: true

# Tests for Feen::Dumper::PiecesInHand conforming to FEEN Specification v1.0.0
#
# FEEN specifies that pieces in hand must be formatted as:
# - Groups by case: uppercase first, then lowercase, separated by "/"
# - Within each group, sorts by quantity (descending), then alphabetically (ascending)
# - Uses count notation for quantities > 1 (e.g., "3P" instead of "PPP")
#
# This test assumes the existence of the following files:
# - lib/feen/dumper/pieces_in_hand.rb
# - lib/feen/dumper/pieces_in_hand/errors.rb

require_relative "../../../lib/feen/dumper/pieces_in_hand"

# Helper function to run a test and report errors
def run_test(name)
  puts "Test: #{name}"
  yield
  puts "  ✓ Success"
  $test_count = ($test_count || 0) + 1
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
  raise "Expected '/', got '#{result}'" unless result == "/"
end

run_test("Single piece (uppercase)") do
  result = Feen::Dumper::PiecesInHand.dump("P")
  raise "Expected 'P/', got '#{result}'" unless result == "P/"
end

run_test("Single piece (lowercase)") do
  result = Feen::Dumper::PiecesInHand.dump("p")
  raise "Expected '/p', got '#{result}'" unless result == "/p"
end

run_test("Mixed case single pieces") do
  result = Feen::Dumper::PiecesInHand.dump("P", "p")
  raise "Expected 'P/p', got '#{result}'" unless result == "P/p"
end

# === PNN Support Tests ===

run_test("PNN piece with + prefix (uppercase)") do
  result = Feen::Dumper::PiecesInHand.dump("+P")
  raise "Expected '+P/', got '#{result}'" unless result == "+P/"
end

run_test("PNN piece with - prefix (lowercase)") do
  result = Feen::Dumper::PiecesInHand.dump("-p")
  raise "Expected '/-p', got '#{result}'" unless result == "/-p"
end

run_test("PNN piece with ' suffix") do
  result = Feen::Dumper::PiecesInHand.dump("P'")
  raise "Expected 'P\\'/', got '#{result}'" unless result == "P'/"
end

run_test("PNN piece with both prefix and suffix") do
  result = Feen::Dumper::PiecesInHand.dump("+P'")
  raise "Expected '+P\\'/', got '#{result}'" unless result == "+P'/"
end

run_test("PNN piece with - prefix and ' suffix (lowercase)") do
  result = Feen::Dumper::PiecesInHand.dump("-k'")
  raise "Expected '/-k\\'', got '#{result}'" unless result == "/-k'"
end

# === Case Separation Tests ===

run_test("Uppercase pieces only") do
  result = Feen::Dumper::PiecesInHand.dump("P", "P", "P", "B", "B", "K")
  raise "Expected '3P2BK/', got '#{result}'" unless result == "3P2BK/"
end

run_test("Lowercase pieces only") do
  result = Feen::Dumper::PiecesInHand.dump("p", "p", "b", "k")
  raise "Expected '/2pbk', got '#{result}'" unless result == "/2pbk"
end

run_test("Mixed case with quantity sorting") do
  # 3 P's (uppercase), 2 B's (uppercase), 5 p's (lowercase), 1 k (lowercase)
  result = Feen::Dumper::PiecesInHand.dump("P", "P", "P", "B", "B", "p", "p", "p", "p", "p", "k")
  raise "Expected '3P2B/5pk', got '#{result}'" unless result == "3P2B/5pk"
end

# === FEEN Canonical Sorting Tests ===

run_test("Quantity sorting within uppercase group") do
  # 3 P's, 2 B's, 1 K (all uppercase)
  result = Feen::Dumper::PiecesInHand.dump("P", "P", "P", "B", "B", "K")
  raise "Expected '3P2BK/', got '#{result}'" unless result == "3P2BK/"
end

run_test("Alphabetical sorting within same quantity (uppercase)") do
  # All single pieces (uppercase): should be sorted alphabetically
  result = Feen::Dumper::PiecesInHand.dump("R", "B", "N")
  raise "Expected 'BNR/', got '#{result}'" unless result == "BNR/"
end

run_test("Alphabetical sorting within same quantity (lowercase)") do
  # All single pieces (lowercase): should be sorted alphabetically
  result = Feen::Dumper::PiecesInHand.dump("r", "b", "n")
  raise "Expected '/bnr', got '#{result}'" unless result == "/bnr"
end

run_test("PNN modifiers in alphabetical order (uppercase)") do
  # All single pieces with different PNN representations
  # ASCII order: "+P" < "-P" < "P" < "P'"
  result = Feen::Dumper::PiecesInHand.dump("P'", "P", "-P", "+P")
  raise "Expected '+P-PPP\\'/', got '#{result}'" unless result == "+P-PPP'/"
end

run_test("PNN modifiers in alphabetical order (lowercase)") do
  # ASCII order: "+p" < "-p" < "p" < "p'"
  result = Feen::Dumper::PiecesInHand.dump("p'", "p", "-p", "+p")
  raise "Expected '/+p-ppp\\'', got '#{result}'" unless result == "/+p-ppp'"
end

run_test("Complex PNN sorting with modifiers and mixed case") do
  # 3 +P (uppercase), 2 B' (uppercase), 1 -p (lowercase), 1 P (uppercase)
  result = Feen::Dumper::PiecesInHand.dump("+P", "+P", "+P", "B'", "B'", "-p", "P")
  raise "Expected '3+P2B\\'P/-p', got '#{result}'" unless result == "3+P2B'P/-p"
end

# === FEEN Specification Example Adapted ===

run_test("FEEN spec example adapted for case separation") do
  # Adapting the FEEN specification example to case separation
  # Original: 10P5K3B2p'+P-pBRbq
  # With case separation: uppercase pieces / lowercase pieces
  pieces = (["P"] * 10) + (["K"] * 5) + (["B"] * 3) + (["p'"] * 2) + ["+P", "-p", "B", "R", "b", "q"]
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  # Uppercase: 10P, 5K, 4B (3 regular B + 1 from singles), 1+P, 1R
  # Lowercase: 2p', 1-p, 1b, 1q
  expected = "10P5K4B+PR/2p'-pbq"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

# === Count Formatting Tests ===

run_test("No count prefix for single pieces") do
  result = Feen::Dumper::PiecesInHand.dump("P")
  raise "Expected 'P/' (no count), got '#{result}'" unless result == "P/"
end

run_test("Count prefix for multiple pieces") do
  result = Feen::Dumper::PiecesInHand.dump("P", "P")
  raise "Expected '2P/', got '#{result}'" unless result == "2P/"
end

run_test("Large count formatting") do
  pieces = ["P"] * 15
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  raise "Expected '15P/', got '#{result}'" unless result == "15P/"
end

run_test("Mixed counts with PNN and case separation") do
  # 5 +P (uppercase), 3 P' (uppercase), 1 -p (lowercase)
  pieces = (["+P"] * 5) + (["P'"] * 3) + ["-p"]
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  raise "Expected '5+P3P\\'/-p', got '#{result}'" unless result == "5+P3P'/-p"
end

# === Duplicate and Complex Scenarios ===

run_test("Same piece with and without modifiers (case separated)") do
  # 2 P, 1 +P, 1 P' (all uppercase) - should sort by quantity then alphabetically
  result = Feen::Dumper::PiecesInHand.dump("P", "P", "+P", "P'")
  raise "Expected '2P+PP\\'/', got '#{result}'" unless result == "2P+PP'/"
end

run_test("Complex shogi-style position with case separation") do
  # Typical shogi pieces in hand with promotions
  pieces = (["P"] * 3) + (["+P"] * 2) + %w[L N S G p l]
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  # Uppercase: 3P, 2+P, then singles: G, L, N, S (alphabetical)
  # Lowercase: l, p (alphabetical)
  expected = "3P2+PGLNS/lp"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

# === Cross-case Alphabetical Behavior ===

run_test("Mixed case with same letter different cases") do
  # Same letter in both cases
  result = Feen::Dumper::PiecesInHand.dump("P", "p", "P", "p")
  raise "Expected '2P/2p', got '#{result}'" unless result == "2P/2p"
end

run_test("Complex mixed case scenario") do
  # Mix of uppercase and lowercase with various modifiers
  pieces = %w[P P P p p +P +p B' b' K k]
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  # Uppercase: 3P, 1+P, 1B', 1K → 3P+PB'K
  # Lowercase: 2p, 1+p, 1b', 1k → 2p+pb'k
  expected = "3P+PB'K/2p+pb'k"
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
  raise "Unexpected error message: #{e.message}" unless e.message.include?("format") && e.message.include?("++P")
end

run_test("Invalid PNN format: double suffix") do
  Feen::Dumper::PiecesInHand.dump("P''")
  raise "Expected exception for invalid PNN format"
rescue ArgumentError => e
  raise "Unexpected error message: #{e.message}" unless e.message.include?("format") && e.message.include?("P''")
end

run_test("Invalid PNN format: invalid prefix") do
  Feen::Dumper::PiecesInHand.dump("*P")
  raise "Expected exception for invalid prefix"
rescue ArgumentError => e
  raise "Unexpected error message: #{e.message}" unless e.message.include?("format") && e.message.include?("*P")
end

run_test("Invalid PNN format: invalid suffix") do
  Feen::Dumper::PiecesInHand.dump("P@")
  raise "Expected exception for invalid suffix"
rescue ArgumentError => e
  raise "Unexpected error message: #{e.message}" unless e.message.include?("format") && e.message.include?("P@")
end

run_test("Invalid PNN format: empty string") do
  Feen::Dumper::PiecesInHand.dump("")
  raise "Expected exception for empty string"
rescue ArgumentError => e
  raise "Unexpected error message: #{e.message}" unless e.message.include?("format")
end

run_test("Invalid PNN format: multiple characters") do
  Feen::Dumper::PiecesInHand.dump("PP")
  raise "Expected exception for multiple characters"
rescue ArgumentError => e
  raise "Unexpected error message: #{e.message}" unless e.message.include?("format") && e.message.include?("PP")
end

run_test("Invalid PNN format: digits") do
  Feen::Dumper::PiecesInHand.dump("P1")
  raise "Expected exception for digits"
rescue ArgumentError => e
  raise "Unexpected error message: #{e.message}" unless e.message.include?("format") && e.message.include?("P1")
end

# === Edge Cases and Performance ===

run_test("All 26 uppercase letters") do
  pieces = ("A".."Z").to_a
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  expected = pieces.sort.join + "/"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

run_test("All 26 lowercase letters") do
  pieces = ("a".."z").to_a
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  expected = "/" + pieces.sort.join
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

run_test("All letters mixed case") do
  pieces = ("A".."Z").to_a + ("a".."z").to_a
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  expected = ("A".."Z").to_a.sort.join + "/" + ("a".."z").to_a.sort.join
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

run_test("Large mixed collection with case separation") do
  # Create a realistic large game position
  pieces = (["P"] * 20) + (["p"] * 15) + (["R"] * 3) + (["r"] * 2) +
           (["+P"] * 5) + (["-p"] * 4) + (["B'"] * 2) + ["N"]
  result = Feen::Dumper::PiecesInHand.dump(*pieces)

  # Expected with case separation:
  # Uppercase: 25P (20 regular + 5 +P), 3R, 2B', 1N → but wait, +P is different from P
  # Let me recalculate:
  # Uppercase: 20P, 5+P, 3R, 2B', 1N
  # Lowercase: 15p, 4-p, 2r
  expected = "20P5+P3R2B'N/15p4-p2r"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

# === FEEN Canonicality Tests ===

run_test("FEEN canonicality: reordered input produces same output") do
  # Same pieces in different input orders should produce identical output
  pieces1 = %w[P B P N B P p p b]
  pieces2 = %w[B P N P B P b p p]
  pieces3 = %w[N B B P P P p b p]

  result1 = Feen::Dumper::PiecesInHand.dump(*pieces1)
  result2 = Feen::Dumper::PiecesInHand.dump(*pieces2)
  result3 = Feen::Dumper::PiecesInHand.dump(*pieces3)

  expected = "3P2BN/2pb" # Uppercase: 3 P's, 2 B's, 1 N; Lowercase: 2 p's, 1 b

  raise "Inconsistent results: '#{result1}', '#{result2}', '#{result3}'" unless
    result1 == expected && result2 == expected && result3 == expected
end

run_test("FEEN canonicality: complex PNN reordering with case separation") do
  # Complex PNN pieces in different orders
  pieces1 = ["+P", "P'", "-p", "+P", "P'", "B", "b"]
  pieces2 = ["B", "-p", "P'", "+P", "P'", "+P", "b"]

  result1 = Feen::Dumper::PiecesInHand.dump(*pieces1)
  result2 = Feen::Dumper::PiecesInHand.dump(*pieces2)

  # Uppercase: 2+P, 2P', 1B → 2+P2P'B
  # Lowercase: 1-p, 1b → -pb (alphabetical order: -p < b)
  expected = "2+P2P'B/-pb"

  raise "Inconsistent results: '#{result1}' vs '#{result2}'" unless result1 == result2
  raise "Expected '#{expected}', got '#{result1}'" unless result1 == expected
end

# === Special FEEN Format Cases ===

run_test("Only uppercase pieces (empty lowercase section)") do
  result = Feen::Dumper::PiecesInHand.dump("P", "B", "N")
  raise "Expected 'BNP/', got '#{result}'" unless result == "BNP/"
end

run_test("Only lowercase pieces (empty uppercase section)") do
  result = Feen::Dumper::PiecesInHand.dump("p", "b", "n")
  raise "Expected '/bnp', got '#{result}'" unless result == "/bnp"
end

run_test("Real-world chess example") do
  # After some captures in chess
  pieces = %w[p p q Q N]
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  # Uppercase: NQ (alphabetical), Lowercase: 2pq
  expected = "NQ/2pq"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

run_test("Real-world shogi example") do
  # Typical shogi mid-game pieces in hand
  pieces = %w[P P P +P p p l L S s G]
  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  # Uppercase: 3P, 1+P, 1G, 1L, 1S → 3P+PGLS
  # Lowercase: 2p, 1l, 1s → 2pls
  expected = "3P+PGLS/2pls"
  raise "Expected '#{expected}', got '#{result}'" unless result == expected
end

puts
puts "=== Summary ==="
puts "✅ All #{$test_count} FEEN-compliant tests for PiecesInHand.dump have passed!"
puts
puts "Key FEEN compliance verified:"
puts "  • Case separation (UPPERCASE/lowercase format)"
puts "  • Canonical sorting within each case group (quantity desc → alphabetical asc)"
puts "  • Full PNN notation support ([prefix]letter[suffix])"
puts "  • Proper count formatting (no '1' prefix, numeric for 2+)"
puts "  • FEEN specification format compliance"
puts "  • Error handling for invalid PNN formats"
puts "  • Canonicality across different input orders"
