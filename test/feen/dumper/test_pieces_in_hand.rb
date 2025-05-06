# frozen_string_literal: true

require_relative "../../../lib/feen/piece"
require_relative "../../../lib/feen/dumper/pieces_in_hand"

# Test with no pieces in hand
raise unless Feen::Dumper::PiecesInHand.dump == "-"

# Test with a single piece
raise unless Feen::Dumper::PiecesInHand.dump(Feen::Piece.new("P")) == "P"
raise unless Feen::Dumper::PiecesInHand.dump(Feen::Piece.new("p")) == "p"

# Test with multiple pieces (should be sorted in ASCII lexicographic order)
raise unless Feen::Dumper::PiecesInHand.dump(Feen::Piece.new("P"), Feen::Piece.new("p")) == "Pp"
raise unless Feen::Dumper::PiecesInHand.dump(Feen::Piece.new("p"), Feen::Piece.new("P")) == "Pp"
raise unless Feen::Dumper::PiecesInHand.dump(Feen::Piece.new("B"), Feen::Piece.new("P"), Feen::Piece.new("p")) == "BPp"
raise unless Feen::Dumper::PiecesInHand.dump(Feen::Piece.new("p"), Feen::Piece.new("P"), Feen::Piece.new("B")) == "BPp"
raise unless Feen::Dumper::PiecesInHand.dump(
  Feen::Piece.new("P"), Feen::Piece.new("B"), Feen::Piece.new("N"),
  Feen::Piece.new("R"), Feen::Piece.new("Q"), Feen::Piece.new("K")
) == "BKNPQR"
raise unless Feen::Dumper::PiecesInHand.dump(
  Feen::Piece.new("q"), Feen::Piece.new("r"), Feen::Piece.new("b"),
  Feen::Piece.new("n"), Feen::Piece.new("k"), Feen::Piece.new("p")
) == "bknpqr"

# Test with mixed uppercase and lowercase pieces
raise unless Feen::Dumper::PiecesInHand.dump(
  Feen::Piece.new("P"), Feen::Piece.new("p"), Feen::Piece.new("B"), Feen::Piece.new("b")
) == "BPbp"
raise unless Feen::Dumper::PiecesInHand.dump(
  Feen::Piece.new("b"), Feen::Piece.new("B"), Feen::Piece.new("p"), Feen::Piece.new("P")
) == "BPbp"
raise unless Feen::Dumper::PiecesInHand.dump(
  Feen::Piece.new("r"), Feen::Piece.new("B"), Feen::Piece.new("n"),
  Feen::Piece.new("P"), Feen::Piece.new("Q"), Feen::Piece.new("k")
) == "BPQknr"

# Test with duplicate pieces
raise unless Feen::Dumper::PiecesInHand.dump(
  Feen::Piece.new("P"), Feen::Piece.new("P"), Feen::Piece.new("P")
) == "PPP"
raise unless Feen::Dumper::PiecesInHand.dump(
  Feen::Piece.new("P"), Feen::Piece.new("p"), Feen::Piece.new("P"), Feen::Piece.new("p")
) == "PPpp"

# Test invalid input types
begin
  Feen::Dumper::PiecesInHand.dump(42)
  raise "Expected error for numeric input"
rescue ArgumentError => e
  raise unless e.message.include?("must be instances of Feen::Piece")
end

begin
  Feen::Dumper::PiecesInHand.dump(Feen::Piece.new("P"), nil, Feen::Piece.new("B"))
  raise "Expected error for nil input"
rescue ArgumentError => e
  raise unless e.message.include?("must be instances of Feen::Piece")
end

begin
  Feen::Dumper::PiecesInHand.dump("P")
  raise "Expected error for string input"
rescue ArgumentError => e
  raise unless e.message.include?("must be instances of Feen::Piece")
end

# Test with pieces having prefixes or suffixes
# Note: We could add validation for this if needed in the implementation
# For now, we assume the implementation handles this internally

puts "✅ All PiecesInHand dump tests passed."
