# frozen_string_literal: true

require_relative "../../../lib/feen/parser/pieces_in_hand"

# Access to the module being tested
PiecesInHand = Feen::Parser::PiecesInHand

# Test suite begins
puts "🧪 Testing PiecesInHand.parse"

# 1. Test with no pieces in hand
raise unless PiecesInHand.parse("-") == []

# 2. Tests with simple pieces
raise unless PiecesInHand.parse("P") == ["P"]
raise unless PiecesInHand.parse("p") == ["p"]
raise unless PiecesInHand.parse("ABC") == %w[A B C]

# 3. Tests with multiple pieces (with numeric prefixes)
raise unless PiecesInHand.parse("2P") == %w[P P]
raise unless PiecesInHand.parse("3P") == %w[P P P]
raise unless PiecesInHand.parse("2P2Q") == %w[P P Q Q]
raise unless PiecesInHand.parse("10P") == %w[P P P P P P P P P P]

# 4. Tests with mix of uppercase and lowercase pieces
raise unless PiecesInHand.parse("ABpq") == %w[A B p q]
raise unless PiecesInHand.parse("A2B2pq") == %w[A B B p p q]

# 5. Tests to verify lexicographic ASCII sorting
raise unless PiecesInHand.parse("ABCabc") == %w[A B C a b c]
raise unless PiecesInHand.parse("BCZad") == %w[B C Z a d]
raise unless PiecesInHand.parse("Ba") == %w[B a]

# 6. More complex tests
raise unless PiecesInHand.parse("A3BC2p3q4r") == %w[A B B B C p p q q q r r r r]
raise unless PiecesInHand.parse("2AB3CD2abc") == %w[A A B C C C D a a b c]

# 7. Tests for input validation errors
begin
  PiecesInHand.parse(123)
  raise "Expected ArgumentError for non-string input"
rescue ArgumentError
  # Test passed
end

begin
  PiecesInHand.parse("")
  raise "Expected ArgumentError for empty string"
rescue ArgumentError
  # Test passed
end

# 8. Tests for format errors
begin
  PiecesInHand.parse("1P") # Prefix "1" is forbidden
  raise "Expected ArgumentError for invalid prefix '1'"
rescue ArgumentError
  # Test passed
end

begin
  PiecesInHand.parse("0P") # Prefix "0" is forbidden
  raise "Expected ArgumentError for invalid prefix '0'"
rescue ArgumentError
  # Test passed
end

begin
  PiecesInHand.parse("P+") # Invalid characters
  raise "Expected ArgumentError for invalid character '+'"
rescue ArgumentError
  # Test passed
end

begin
  PiecesInHand.parse("P1") # Digit after letter is invalid
  raise "Expected ArgumentError for digit after letter"
rescue ArgumentError
  # Test passed
end

# 9. Tests for lexicographic order validation
begin
  PiecesInHand.parse("BA") # B should come after A
  raise "Expected ArgumentError for incorrect order 'BA'"
rescue ArgumentError
  # Test passed
end

begin
  PiecesInHand.parse("ba") # b should come after a
  raise "Expected ArgumentError for incorrect order 'ba'"
rescue ArgumentError
  # Test passed
end

begin
  PiecesInHand.parse("aB") # "a" should come after "B" in ASCII order
  raise "Expected ArgumentError for incorrect order 'aB'"
rescue ArgumentError
  # Test passed
end

begin
  PiecesInHand.parse("BaC") # Incorrect: 'a' should come after 'C' in ASCII sorting
  raise "Expected ArgumentError for incorrect order 'BaC'"
rescue ArgumentError
  # Test passed
end

# 10. Tests for edge cases
raise unless PiecesInHand.parse("2Z") == %w[Z Z]
raise unless PiecesInHand.parse("2z") == %w[z z]

# 11. Tests for numerous pieces
many_ps = Array.new(99, "P")
raise unless PiecesInHand.parse("99P") == many_ps

puts "✅ All PiecesInHand parse tests passed."
