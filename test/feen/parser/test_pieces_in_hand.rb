# frozen_string_literal: true

require_relative "../../../lib/feen/parser/pieces_in_hand"

# Test empty hand
raise unless Feen::Parser::PiecesInHand.parse("-") == []

# Test valid single piece
raise unless Feen::Parser::PiecesInHand.parse("P") == ["P"]

# Test multiple valid pieces in correct order
raise unless Feen::Parser::PiecesInHand.parse("BNP") == %w[B N P]

# Test lowercase and uppercase mixed in correct ASCII order
raise unless Feen::Parser::PiecesInHand.parse("BNPab") == %w[B N P a b]

# Test repeated pieces
raise unless Feen::Parser::PiecesInHand.parse("NNN") == %w[N N N]

# Test valid edge case: longest valid string
valid_longest = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
raise unless Feen::Parser::PiecesInHand.parse(valid_longest).join == valid_longest

# Test invalid input: not a string
begin
  Feen::Parser::PiecesInHand.parse(nil)
  raise "Expected error for nil input"
rescue ArgumentError => e
  raise unless e.message.include?("must be a string")
end

begin
  Feen::Parser::PiecesInHand.parse(123)
  raise "Expected error for numeric input"
rescue ArgumentError => e
  raise unless e.message.include?("must be a string")
end

# Test invalid input: empty string
begin
  Feen::Parser::PiecesInHand.parse("")
  raise "Expected error for empty string"
rescue ArgumentError => e
  raise unless e.message.include?("cannot be empty")
end

# Test invalid format: contains non-letters
begin
  Feen::Parser::PiecesInHand.parse("P1Q")
  raise "Expected error for non-letter character"
rescue ArgumentError => e
  raise unless e.message.include?("Invalid pieces in hand format")
end

begin
  Feen::Parser::PiecesInHand.parse("+P")
  raise "Expected error for modifier prefix"
rescue ArgumentError => e
  raise unless e.message.include?("Invalid pieces in hand format")
end

begin
  Feen::Parser::PiecesInHand.parse("P=")
  raise "Expected error for modifier suffix"
rescue ArgumentError => e
  raise unless e.message.include?("Invalid pieces in hand format")
end

# Test invalid order - these check for sorting errors
begin
  Feen::Parser::PiecesInHand.parse("ba")
  raise "Expected error for non-ASCII-sorted input"
rescue ArgumentError => e
  raise unless e.message.include?("must be in ASCII lexicographic order")
end

begin
  Feen::Parser::PiecesInHand.parse("ZAB")
  raise "Expected error for non-ASCII-sorted input"
rescue ArgumentError => e
  raise unless e.message.include?("must be in ASCII lexicographic order")
end

# Test mixed case in wrong order
begin
  Feen::Parser::PiecesInHand.parse("aB")
  raise "Expected error for lowercase before uppercase"
rescue ArgumentError => e
  raise unless e.message.include?("must be in ASCII lexicographic order")
end

# Test repeated pieces not grouped together
begin
  Feen::Parser::PiecesInHand.parse("PQPR")
  raise "Expected error for non-grouped repeated pieces"
rescue ArgumentError => e
  raise unless e.message.include?("must be in ASCII lexicographic order")
end

# Test valid grouped repeated pieces
raise unless Feen::Parser::PiecesInHand.parse("PPPR") == %w[P P P R]

# Test valid complex case with multiple repeated pieces
raise unless Feen::Parser::PiecesInHand.parse("BBNNNPPPRRbbnnnppprr") == %w[B B N N N P P P R R b b n n n p p p r r]

puts "✅ All PiecesInHand parse tests passed."
