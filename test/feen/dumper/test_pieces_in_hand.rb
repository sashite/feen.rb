# frozen_string_literal: true

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

# Tests for invocation with no arguments (no pieces in hand)
run_test("No pieces in hand") do
  result = Feen::Dumper::PiecesInHand.dump
  raise "Expected '-', got '#{result}'" unless result == "-"
end

# Tests with a single piece
run_test("Single piece (uppercase)") do
  result = Feen::Dumper::PiecesInHand.dump("P")
  raise "Expected 'P', got '#{result}'" unless result == "P"
end

run_test("Single piece (lowercase)") do
  result = Feen::Dumper::PiecesInHand.dump("p")
  raise "Expected 'p', got '#{result}'" unless result == "p"
end

# Tests with multiple pieces (ASCII lexicographic sorting)
run_test("Multiple uppercase and lowercase pieces (already sorted)") do
  result = Feen::Dumper::PiecesInHand.dump("P", "p")
  raise "Expected 'Pp', got '#{result}'" unless result == "Pp"
end

run_test("Multiple uppercase and lowercase pieces (reversed order)") do
  result = Feen::Dumper::PiecesInHand.dump("p", "P")
  raise "Expected 'Pp', got '#{result}'" unless result == "Pp"
end

run_test("Multiple different pieces (mixed order)") do
  result = Feen::Dumper::PiecesInHand.dump("B", "P", "p")
  raise "Expected 'BPp', got '#{result}'" unless result == "BPp"
end

run_test("Multiple different pieces (arbitrary order)") do
  result = Feen::Dumper::PiecesInHand.dump("p", "P", "B")
  raise "Expected 'BPp', got '#{result}'" unless result == "BPp"
end

run_test("All uppercase pieces (arbitrary order)") do
  result = Feen::Dumper::PiecesInHand.dump("P", "B", "N", "R", "Q", "K")
  raise "Expected 'BKNPQR', got '#{result}'" unless result == "BKNPQR"
end

run_test("All lowercase pieces (arbitrary order)") do
  result = Feen::Dumper::PiecesInHand.dump("q", "r", "b", "n", "k", "p")
  raise "Expected 'bknpqr', got '#{result}'" unless result == "bknpqr"
end

# Tests with mixed piece sets
run_test("Mix of uppercase and lowercase pieces") do
  result = Feen::Dumper::PiecesInHand.dump("P", "p", "B", "b")
  raise "Expected 'BPbp', got '#{result}'" unless result == "BPbp"
end

run_test("Mix of uppercase and lowercase pieces (alternative order)") do
  result = Feen::Dumper::PiecesInHand.dump("b", "B", "p", "P")
  raise "Expected 'BPbp', got '#{result}'" unless result == "BPbp"
end

run_test("Mix of uppercase and lowercase pieces (random order)") do
  result = Feen::Dumper::PiecesInHand.dump("r", "B", "n", "P", "Q", "k")
  raise "Expected 'BPQknr', got '#{result}'" unless result == "BPQknr"
end

# Tests with duplicate pieces
run_test("Duplicate pieces (uppercase)") do
  result = Feen::Dumper::PiecesInHand.dump("P", "P", "P")
  raise "Expected 'PPP', got '#{result}'" unless result == "PPP"
end

run_test("Duplicate pieces (uppercase and lowercase)") do
  result = Feen::Dumper::PiecesInHand.dump("P", "p", "P", "p")
  raise "Expected 'PPpp', got '#{result}'" unless result == "PPpp"
end

# Tests for error handling - invalid input types
run_test("Invalid input: number") do
  begin
    Feen::Dumper::PiecesInHand.dump(42)
    raise "Expected exception for numeric input"
  rescue ArgumentError => e
    expected = "Piece at index: 0 must be a String, got type: Integer"
    unless e.message == expected
      raise "Unexpected error message: got '#{e.message}', expected '#{expected}'"
    end
  end
end

run_test("Invalid input: nil") do
  begin
    Feen::Dumper::PiecesInHand.dump("P", nil, "B")
    raise "Expected exception for nil input"
  rescue ArgumentError => e
    unless e.message.include?("index: 1") && e.message.include?("type: NilClass")
      raise "Unexpected error message: #{e.message}"
    end
  end
end

run_test("Invalid input: array") do
  begin
    Feen::Dumper::PiecesInHand.dump([])
    raise "Expected exception for array input"
  rescue ArgumentError => e
    unless e.message.include?("index: 0") && e.message.include?("type: Array")
      raise "Unexpected error message: #{e.message}"
    end
  end
end

# Tests for error handling - invalid piece characters
run_test("Invalid character: multi-character string") do
  begin
    Feen::Dumper::PiecesInHand.dump("PP")
    raise "Expected exception for multi-character string"
  rescue ArgumentError => e
    unless e.message.include?("index: 0") && e.message.include?("'PP'")
      raise "Unexpected error message: #{e.message}"
    end
  end
end

run_test("Invalid character: digit") do
  begin
    Feen::Dumper::PiecesInHand.dump("p", "1", "K")
    raise "Expected exception for numeric character"
  rescue ArgumentError => e
    unless e.message.include?("index: 1") && e.message.include?("'1'")
      raise "Unexpected error message: #{e.message}"
    end
  end
end

run_test("Invalid character: special character") do
  begin
    Feen::Dumper::PiecesInHand.dump("P", "+", "Q")
    raise "Expected exception for special character"
  rescue ArgumentError => e
    unless e.message.include?("index: 1") && e.message.include?("'+'")
      raise "Unexpected error message: #{e.message}"
    end
  end
end

run_test("Invalid character: empty string") do
  begin
    Feen::Dumper::PiecesInHand.dump("")
    raise "Expected exception for empty string"
  rescue ArgumentError => e
    unless e.message.include?("index: 0")
      raise "Unexpected error message: #{e.message}"
    end
  end
end

# Tests for complex sorting scenarios
run_test("Complex ASCII lexicographic sorting") do
  result = Feen::Dumper::PiecesInHand.dump(
    "z", "y", "x", "w", "v", "u", "A", "B", "C", "D", "E", "F"
  )
  raise "Expected 'ABCDEFuvwxyz', got '#{result}'" unless result == "ABCDEFuvwxyz"
end

run_test("All unique uppercase pieces (chess)") do
  result = Feen::Dumper::PiecesInHand.dump(
    "Q", "R", "B", "N", "K", "P"
  )
  raise "Expected 'BKNPQR', got '#{result}'" unless result == "BKNPQR"
end

run_test("All unique lowercase pieces (chess)") do
  result = Feen::Dumper::PiecesInHand.dump(
    "q", "r", "b", "n", "k", "p"
  )
  raise "Expected 'bknpqr', got '#{result}'" unless result == "bknpqr"
end

# Test with a large number of pieces (performance boundaries)
run_test("Large number of pieces (performance)") do
  pieces = []
  100.times do
    pieces << (rand > 0.5 ? ('A'..'Z').to_a.sample : ('a'..'z').to_a.sample)
  end

  result = Feen::Dumper::PiecesInHand.dump(*pieces)
  sorted_pieces = pieces.sort.join

  raise "Incorrect result for large number of pieces" unless result == sorted_pieces
end

puts "\n✅ All tests for PiecesInHand.dump have passed!"
