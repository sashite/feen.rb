# frozen_string_literal: true

require_relative "../../../lib/feen/dumper/pieces_in_hand"

# Test with no pieces in hand
raise unless Feen::Dumper::PiecesInHand.dump == "-"

# Test with a single piece
raise unless Feen::Dumper::PiecesInHand.dump("P") == "P"
raise unless Feen::Dumper::PiecesInHand.dump("p") == "p"

# Test with multiple pieces (should be sorted in ASCII lexicographic order)
raise unless Feen::Dumper::PiecesInHand.dump("P", "p") == "Pp"
raise unless Feen::Dumper::PiecesInHand.dump("p", "P") == "Pp"
raise unless Feen::Dumper::PiecesInHand.dump("B", "P", "p") == "BPp"
raise unless Feen::Dumper::PiecesInHand.dump("p", "P", "B") == "BPp"
raise unless Feen::Dumper::PiecesInHand.dump("P", "B", "N", "R", "Q", "K") == "BKNPQR"
raise unless Feen::Dumper::PiecesInHand.dump("q", "r", "b", "n", "k", "p") == "bknpqr"

# Test with mixed uppercase and lowercase pieces
raise unless Feen::Dumper::PiecesInHand.dump("P", "p", "B", "b") == "BPbp"
raise unless Feen::Dumper::PiecesInHand.dump("b", "B", "p", "P") == "BPbp"
raise unless Feen::Dumper::PiecesInHand.dump("r", "B", "n", "P", "Q", "k") == "BPQknr"

# Test with duplicate pieces
raise unless Feen::Dumper::PiecesInHand.dump("P", "P", "P") == "PPP"
raise unless Feen::Dumper::PiecesInHand.dump("P", "p", "P", "p") == "PPpp"

# Test invalid input types
begin
  Feen::Dumper::PiecesInHand.dump(42)
  raise "Expected error for numeric input"
rescue ArgumentError => e
  raise unless e.message.include?("Piece at index 0 must be a String, got Integer")
end

begin
  Feen::Dumper::PiecesInHand.dump("P", nil, "B")
  raise "Expected error for nil input"
rescue ArgumentError => e
  raise unless e.message.include?("Piece at index 1 must be a String, got NilClass")
end

begin
  Feen::Dumper::PiecesInHand.dump([])
  raise "Expected error for array input"
rescue ArgumentError => e
  raise unless e.message.include?("Piece at index 0 must be a String, got Array")
end

# Test invalid piece characters
begin
  Feen::Dumper::PiecesInHand.dump("PP")
  raise "Expected error for multiple character string"
rescue ArgumentError => e
  raise unless e.message.include?("Piece at index 0 has an invalid format: 'PP'")
end

begin
  Feen::Dumper::PiecesInHand.dump("p", "1", "K")
  raise "Expected error for numeric character"
rescue ArgumentError => e
  raise unless e.message.include?("Piece at index 1 has an invalid format: '1'")
end

begin
  Feen::Dumper::PiecesInHand.dump("P", "+", "Q")
  raise "Expected error for special character"
rescue ArgumentError => e
  raise unless e.message.include?("Piece at index 1 has an invalid format: '+'")
end

# Test empty string input
begin
  Feen::Dumper::PiecesInHand.dump("")
  raise "Expected error for empty string"
rescue ArgumentError => e
  raise unless e.message.include?("Piece at index 0 has an invalid format: ''")
end

# Test complex sorting scenarios
# Ensure ASCII lexicographic order: A-Z followed by a-z
raise unless Feen::Dumper::PiecesInHand.dump(
  "z", "y", "x", "w", "v", "u", "A", "B", "C", "D", "E", "F"
) == "ABCDEFuvwxyz"

# Test with all unique uppercase pieces
raise unless Feen::Dumper::PiecesInHand.dump(
  "Q", "R", "B", "N", "K", "P"
) == "BKNPQR"

# Test with all unique lowercase pieces
raise unless Feen::Dumper::PiecesInHand.dump(
  "q", "r", "b", "n", "k", "p"
) == "bknpqr"

puts "✅ All PiecesInHand dump tests passed."
