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
  raise unless e.message.include?("must be a String")
end

begin
  Feen::Dumper::PiecesInHand.dump("P", nil, "B")
  raise "Expected error for nil input"
rescue ArgumentError => e
  raise unless e.message.include?("must be a String")
end

begin
  Feen::Dumper::PiecesInHand.dump(%w[P B])
  raise "Expected error for array input"
rescue ArgumentError => e
  raise unless e.message.include?("must be a String")
end

# Test invalid piece characters
begin
  Feen::Dumper::PiecesInHand.dump("P", "1")
  raise "Expected error for numeric character"
rescue ArgumentError => e
  raise unless e.message.include?("must be a single alphabetic character")
end

begin
  Feen::Dumper::PiecesInHand.dump("P", "!")
  raise "Expected error for special character"
rescue ArgumentError => e
  raise unless e.message.include?("must be a single alphabetic character")
end

begin
  Feen::Dumper::PiecesInHand.dump("P", "Pp")
  raise "Expected error for multi-character string"
rescue ArgumentError => e
  raise unless e.message.include?("must be a single alphabetic character")
end

begin
  Feen::Dumper::PiecesInHand.dump("P", "")
  raise "Expected error for empty string"
rescue ArgumentError => e
  raise unless e.message.include?("must be a single alphabetic character")
end

puts "✅ All PiecesInHand dump tests passed."
