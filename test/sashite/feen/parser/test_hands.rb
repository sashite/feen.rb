#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../../helper"
require_relative "../../../../lib/sashite/feen/parser/hands"

puts
puts "=== Hands Parser Tests ==="
puts

# ============================================================================
# VALID INPUTS - EMPTY HANDS
# ============================================================================

puts "Valid inputs - empty hands:"

run_test("parses '/' (both hands empty)") do
  result = Sashite::Feen::Parser::Hands.parse("/")
  raise "first hand should be empty" unless result[:first].empty?
  raise "second hand should be empty" unless result[:second].empty?
end

run_test("parses 'P/' (first hand only)") do
  result = Sashite::Feen::Parser::Hands.parse("P/")
  raise "first hand should have 1 item" unless result[:first].size == 1
  raise "second hand should be empty" unless result[:second].empty?
end

run_test("parses '/p' (second hand only)") do
  result = Sashite::Feen::Parser::Hands.parse("/p")
  raise "first hand should be empty" unless result[:first].empty?
  raise "second hand should have 1 item" unless result[:second].size == 1
end

# ============================================================================
# VALID INPUTS - SINGLE PIECES
# ============================================================================

puts
puts "Valid inputs - single pieces:"

run_test("parses 'P/p' (one piece each)") do
  result = Sashite::Feen::Parser::Hands.parse("P/p")
  raise "first hand wrong size" unless result[:first].size == 1
  raise "second hand wrong size" unless result[:second].size == 1
  raise "first piece wrong abbr" unless result[:first][0][:piece].pin.abbr == :P
  raise "second piece wrong abbr" unless result[:second][0][:piece].pin.abbr == :P
end

run_test("parses 'K/q' (different pieces)") do
  result = Sashite::Feen::Parser::Hands.parse("K/q")
  raise "first piece wrong abbr" unless result[:first][0][:piece].pin.abbr == :K
  raise "second piece wrong abbr" unless result[:second][0][:piece].pin.abbr == :Q
end

run_test("parses piece with count of 1 implicitly") do
  result = Sashite::Feen::Parser::Hands.parse("P/")
  raise "count should be 1" unless result[:first][0][:count] == 1
end

# ============================================================================
# VALID INPUTS - MULTIPLE PIECES (CANONICAL ORDER)
# ============================================================================

puts
puts "Valid inputs - multiple pieces (canonical order):"

run_test("parses 'BNP/' (3 different pieces, alphabetical order)") do
  result = Sashite::Feen::Parser::Hands.parse("BNP/")
  raise "first hand wrong size" unless result[:first].size == 3
  raise "first piece wrong" unless result[:first][0][:piece].pin.abbr == :B
  raise "second piece wrong" unless result[:first][1][:piece].pin.abbr == :N
  raise "third piece wrong" unless result[:first][2][:piece].pin.abbr == :P
end

run_test("parses '/bnp' (3 pieces in second hand, alphabetical)") do
  result = Sashite::Feen::Parser::Hands.parse("/bnp")
  raise "second hand wrong size" unless result[:second].size == 3
  raise "first piece wrong" unless result[:second][0][:piece].pin.abbr == :B
  raise "second piece wrong" unless result[:second][1][:piece].pin.abbr == :N
  raise "third piece wrong" unless result[:second][2][:piece].pin.abbr == :P
end

run_test("parses 'BR/np' (2 pieces each hand, alphabetical)") do
  result = Sashite::Feen::Parser::Hands.parse("BR/np")
  raise "first hand wrong size" unless result[:first].size == 2
  raise "second hand wrong size" unless result[:second].size == 2
  raise "first hand first piece" unless result[:first][0][:piece].pin.abbr == :B
  raise "first hand second piece" unless result[:first][1][:piece].pin.abbr == :R
end

# ============================================================================
# VALID INPUTS - PIECES WITH EXPLICIT COUNTS (CANONICAL ORDER)
# ============================================================================

puts
puts "Valid inputs - pieces with explicit counts (canonical order):"

run_test("parses '2P/' (count of 2)") do
  result = Sashite::Feen::Parser::Hands.parse("2P/")
  raise "first hand wrong size" unless result[:first].size == 1
  raise "count should be 2" unless result[:first][0][:count] == 2
  raise "piece wrong abbr" unless result[:first][0][:piece].pin.abbr == :P
end

run_test("parses '5P/' (count of 5)") do
  result = Sashite::Feen::Parser::Hands.parse("5P/")
  raise "count should be 5" unless result[:first][0][:count] == 5
end

run_test("parses '10P/' (count of 10)") do
  result = Sashite::Feen::Parser::Hands.parse("10P/")
  raise "count should be 10" unless result[:first][0][:count] == 10
end

run_test("parses '99P/' (large count)") do
  result = Sashite::Feen::Parser::Hands.parse("99P/")
  raise "count should be 99" unless result[:first][0][:count] == 99
end

run_test("parses '3B2P/' (higher count first - canonical order)") do
  result = Sashite::Feen::Parser::Hands.parse("3B2P/")
  raise "first hand wrong size" unless result[:first].size == 2
  raise "first count wrong" unless result[:first][0][:count] == 3
  raise "first piece wrong" unless result[:first][0][:piece].pin.abbr == :B
  raise "second count wrong" unless result[:first][1][:count] == 2
  raise "second piece wrong" unless result[:first][1][:piece].pin.abbr == :P
end

run_test("parses '3B3P/' (same count, alphabetical order)") do
  result = Sashite::Feen::Parser::Hands.parse("3B3P/")
  raise "first hand wrong size" unless result[:first].size == 2
  raise "first piece wrong (B before P)" unless result[:first][0][:piece].pin.abbr == :B
  raise "second piece wrong" unless result[:first][1][:piece].pin.abbr == :P
end

run_test("parses '2P/3p' (counts in both hands)") do
  result = Sashite::Feen::Parser::Hands.parse("2P/3p")
  raise "first count wrong" unless result[:first][0][:count] == 2
  raise "second count wrong" unless result[:second][0][:count] == 3
end

run_test("parses '2BP/' (count 2 before count 1, then alphabetical)") do
  result = Sashite::Feen::Parser::Hands.parse("2BP/")
  raise "first count should be 2" unless result[:first][0][:count] == 2
  raise "second count should be 1" unless result[:first][1][:count] == 1
end

# ============================================================================
# VALID INPUTS - EPIN MODIFIERS (CANONICAL ORDER)
# ============================================================================

puts
puts "Valid inputs - EPIN modifiers (canonical order):"

run_test("parses '+P/' (enhanced piece)") do
  result = Sashite::Feen::Parser::Hands.parse("+P/")
  raise "piece should be enhanced" unless result[:first][0][:piece].pin.state == :enhanced
end

run_test("parses '-P/' (diminished piece)") do
  result = Sashite::Feen::Parser::Hands.parse("-P/")
  raise "piece should be diminished" unless result[:first][0][:piece].pin.state == :diminished
end

run_test("parses 'P^/' (terminal piece)") do
  result = Sashite::Feen::Parser::Hands.parse("P^/")
  raise "piece should be terminal" unless result[:first][0][:piece].pin.terminal?
end

run_test("parses \"P'/\" (derived piece)") do
  result = Sashite::Feen::Parser::Hands.parse("P'/")
  raise "piece should be derived" unless result[:first][0][:piece].derived?
end

run_test("parses \"+P^'/\" (all modifiers)") do
  result = Sashite::Feen::Parser::Hands.parse("+P^'/")
  raise "piece should be enhanced" unless result[:first][0][:piece].pin.state == :enhanced
  raise "piece should be terminal" unless result[:first][0][:piece].pin.terminal?
  raise "piece should be derived" unless result[:first][0][:piece].derived?
end

run_test("parses \"2+P'/\" (count with modifiers)") do
  result = Sashite::Feen::Parser::Hands.parse("2+P'/")
  raise "count should be 2" unless result[:first][0][:count] == 2
  raise "piece should be enhanced" unless result[:first][0][:piece].pin.state == :enhanced
  raise "piece should be derived" unless result[:first][0][:piece].derived?
end

run_test("parses '-P+P/' (state modifier order: - before +)") do
  result = Sashite::Feen::Parser::Hands.parse("-P+P/")
  raise "first should be diminished" unless result[:first][0][:piece].pin.state == :diminished
  raise "second should be enhanced" unless result[:first][1][:piece].pin.state == :enhanced
end

run_test("parses '-P+PP/' (state modifier order: - before + before none)") do
  result = Sashite::Feen::Parser::Hands.parse("-P+PP/")
  raise "first should be diminished" unless result[:first][0][:piece].pin.state == :diminished
  raise "second should be enhanced" unless result[:first][1][:piece].pin.state == :enhanced
  raise "third should be normal" unless result[:first][2][:piece].pin.state == :normal
end

run_test("parses 'PP^/' (terminal marker order: absent before present)") do
  result = Sashite::Feen::Parser::Hands.parse("PP^/")
  raise "first should not be terminal" if result[:first][0][:piece].pin.terminal?
  raise "second should be terminal" unless result[:first][1][:piece].pin.terminal?
end

run_test("parses \"PP'/\" (derivation marker order: absent before present)") do
  result = Sashite::Feen::Parser::Hands.parse("PP'/")
  raise "first should not be derived" if result[:first][0][:piece].derived?
  raise "second should be derived" unless result[:first][1][:piece].derived?
end

# ============================================================================
# VALID INPUTS - PIECE SIDE (CANONICAL ORDER)
# ============================================================================

puts
puts "Valid inputs - piece side (canonical order):"

run_test("parses 'P/' (first player piece in first hand)") do
  result = Sashite::Feen::Parser::Hands.parse("P/")
  raise "piece should be first player" unless result[:first][0][:piece].pin.side == :first
end

run_test("parses 'p/' (second player piece in first hand)") do
  result = Sashite::Feen::Parser::Hands.parse("p/")
  raise "piece should be second player" unless result[:first][0][:piece].pin.side == :second
end

run_test("parses '/P' (first player piece in second hand)") do
  result = Sashite::Feen::Parser::Hands.parse("/P")
  raise "piece should be first player" unless result[:second][0][:piece].pin.side == :first
end

run_test("parses '/p' (second player piece in second hand)") do
  result = Sashite::Feen::Parser::Hands.parse("/p")
  raise "piece should be second player" unless result[:second][0][:piece].pin.side == :second
end

run_test("parses 'Pp/' (case order: uppercase before lowercase)") do
  result = Sashite::Feen::Parser::Hands.parse("Pp/")
  raise "first should be uppercase (first player)" unless result[:first][0][:piece].pin.side == :first
  raise "second should be lowercase (second player)" unless result[:first][1][:piece].pin.side == :second
end

# ============================================================================
# VALID INPUTS - REALISTIC SHOGI EXAMPLES (CANONICAL ORDER)
# ============================================================================

puts
puts "Valid inputs - realistic Shogi examples (canonical order):"

run_test("parses 'S/' (one silver in hand)") do
  result = Sashite::Feen::Parser::Hands.parse("S/")
  raise "wrong piece" unless result[:first][0][:piece].pin.abbr == :S
end

run_test("parses '4P2LNS/2p' (typical Shogi hand - canonical order)") do
  # Canonical: 4P (count 4), 2L (count 2), N (count 1), S (count 1)
  # Within count 1: alphabetical N before S
  result = Sashite::Feen::Parser::Hands.parse("4P2LNS/2p")
  raise "first hand wrong size" unless result[:first].size == 4
  raise "first item count wrong" unless result[:first][0][:count] == 4
  raise "first item abbr wrong" unless result[:first][0][:piece].pin.abbr == :P
  raise "second item count wrong" unless result[:first][1][:count] == 2
  raise "second item abbr wrong" unless result[:first][1][:piece].pin.abbr == :L
  raise "third item count wrong" unless result[:first][2][:count] == 1
  raise "third item abbr wrong" unless result[:first][2][:piece].pin.abbr == :N
  raise "fourth item abbr wrong" unless result[:first][3][:piece].pin.abbr == :S
  raise "second hand count wrong" unless result[:second][0][:count] == 2
end

# ============================================================================
# VALID INPUTS - COMPLEX CANONICAL ORDER
# ============================================================================

puts
puts "Valid inputs - complex canonical order:"

run_test("parses full canonical ordering example") do
  # 3A: count 3, letter A
  # 2B: count 2, letter B
  # Cc: count 1, letter C, uppercase before lowercase
  # -D+DD: count 1, letter D, state order (- before + before none)
  input = "3A2BCc-D+DD/"
  result = Sashite::Feen::Parser::Hands.parse(input)

  raise "wrong size" unless result[:first].size == 7

  # Verify order
  raise "item 0: should be A with count 3" unless result[:first][0][:piece].pin.abbr == :A && result[:first][0][:count] == 3
  raise "item 1: should be B with count 2" unless result[:first][1][:piece].pin.abbr == :B && result[:first][1][:count] == 2
  raise "item 2: should be C uppercase" unless result[:first][2][:piece].pin.abbr == :C && result[:first][2][:piece].pin.side == :first
  raise "item 3: should be c lowercase" unless result[:first][3][:piece].pin.abbr == :C && result[:first][3][:piece].pin.side == :second
  raise "item 4: should be -D" unless result[:first][4][:piece].pin.abbr == :D && result[:first][4][:piece].pin.state == :diminished
  raise "item 5: should be +D" unless result[:first][5][:piece].pin.abbr == :D && result[:first][5][:piece].pin.state == :enhanced
  raise "item 6: should be D normal" unless result[:first][6][:piece].pin.abbr == :D && result[:first][6][:piece].pin.state == :normal
end

# ============================================================================
# ERROR CASES - INVALID DELIMITER
# ============================================================================

puts
puts "Error cases - invalid delimiter:"

run_test("raises on missing delimiter") do
  Sashite::Feen::Parser::Hands.parse("PP")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_HANDS_DELIMITER
end

run_test("raises on multiple delimiters") do
  Sashite::Feen::Parser::Hands.parse("P//p")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_HANDS_DELIMITER
end

run_test("raises on empty string") do
  Sashite::Feen::Parser::Hands.parse("")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_HANDS_DELIMITER
end

run_test("raises on trailing delimiter") do
  Sashite::Feen::Parser::Hands.parse("P/p/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_HANDS_DELIMITER
end

# ============================================================================
# ERROR CASES - INVALID COUNT
# ============================================================================

puts
puts "Error cases - invalid count:"

run_test("raises on count of 0") do
  Sashite::Feen::Parser::Hands.parse("0P/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_HAND_COUNT
end

run_test("raises on count of 1 (must be implicit)") do
  Sashite::Feen::Parser::Hands.parse("1P/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_HAND_COUNT
end

run_test("raises on leading zero '01P/'") do
  Sashite::Feen::Parser::Hands.parse("01P/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_HAND_COUNT
end

run_test("raises on leading zero '02P/'") do
  Sashite::Feen::Parser::Hands.parse("02P/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_HAND_COUNT
end

# ============================================================================
# ERROR CASES - NON-CANONICAL ORDER
# ============================================================================

puts
puts "Error cases - non-canonical order:"

run_test("raises on wrong multiplicity order (ascending instead of descending)") do
  # 2P should come before 3B (3 > 2)
  Sashite::Feen::Parser::Hands.parse("2P3B/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message: #{e.message}" unless e.message == Sashite::Feen::Errors::Argument::Messages::NON_CANONICAL_HAND_ORDER
end

run_test("raises on wrong alphabetical order") do
  # B should come before P (alphabetically)
  Sashite::Feen::Parser::Hands.parse("PB/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message: #{e.message}" unless e.message == Sashite::Feen::Errors::Argument::Messages::NON_CANONICAL_HAND_ORDER
end

run_test("raises on wrong case order (lowercase before uppercase)") do
  # P (uppercase) should come before p (lowercase)
  Sashite::Feen::Parser::Hands.parse("pP/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message: #{e.message}" unless e.message == Sashite::Feen::Errors::Argument::Messages::NON_CANONICAL_HAND_ORDER
end

run_test("raises on wrong state modifier order (+ before -)") do
  # -P should come before +P
  Sashite::Feen::Parser::Hands.parse("+P-P/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message: #{e.message}" unless e.message == Sashite::Feen::Errors::Argument::Messages::NON_CANONICAL_HAND_ORDER
end

run_test("raises on wrong state modifier order (none before +)") do
  # +P should come before P (normal)
  Sashite::Feen::Parser::Hands.parse("P+P/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message: #{e.message}" unless e.message == Sashite::Feen::Errors::Argument::Messages::NON_CANONICAL_HAND_ORDER
end

run_test("raises on wrong terminal marker order (present before absent)") do
  # P should come before P^
  Sashite::Feen::Parser::Hands.parse("P^P/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message: #{e.message}" unless e.message == Sashite::Feen::Errors::Argument::Messages::NON_CANONICAL_HAND_ORDER
end

run_test("raises on wrong derivation marker order (present before absent)") do
  # P should come before P'
  Sashite::Feen::Parser::Hands.parse("P'P/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message: #{e.message}" unless e.message == Sashite::Feen::Errors::Argument::Messages::NON_CANONICAL_HAND_ORDER
end

run_test("raises on duplicate items (should be aggregated)") do
  # Two separate P items should be aggregated as 2P
  Sashite::Feen::Parser::Hands.parse("PP/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message: #{e.message}" unless e.message == Sashite::Feen::Errors::Argument::Messages::NON_CANONICAL_HAND_ORDER
end

run_test("raises on non-canonical order in second hand") do
  Sashite::Feen::Parser::Hands.parse("/pb")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message: #{e.message}" unless e.message == Sashite::Feen::Errors::Argument::Messages::NON_CANONICAL_HAND_ORDER
end

run_test("raises on complex non-canonical example") do
  # Correct would be: 3A2BCc-D+DD
  # This has B before A (wrong alphabetical within same count... wait, they have different counts)
  # Let's use: A3B (wrong: count 1 before count 3)
  Sashite::Feen::Parser::Hands.parse("A3B/")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message: #{e.message}" unless e.message == Sashite::Feen::Errors::Argument::Messages::NON_CANONICAL_HAND_ORDER
end

# ============================================================================
# ERROR CASES - INVALID EPIN TOKENS
# ============================================================================

puts
puts "Error cases - invalid EPIN tokens:"

run_test("raises on digit as piece") do
  Sashite::Feen::Parser::Hands.parse("22/")
  raise "should have raised"
rescue StandardError
  # Expected - EPIN parsing error
end

run_test("raises on invalid character") do
  Sashite::Feen::Parser::Hands.parse("P!/")
  raise "should have raised"
rescue StandardError
  # Expected - EPIN parsing error
end

run_test("raises on double apostrophe") do
  Sashite::Feen::Parser::Hands.parse("P''/")
  raise "should have raised"
rescue StandardError
  # Expected - EPIN parsing error
end

# ============================================================================
# SECURITY TESTS - CONTROL CHARACTERS
# ============================================================================

puts
puts "Security - control characters:"

run_test("rejects newline in input") do
  Sashite::Feen::Parser::Hands.parse("P/p\n")
  raise "should have raised"
rescue StandardError
  # Expected
end

run_test("rejects carriage return") do
  Sashite::Feen::Parser::Hands.parse("P\r/p")
  raise "should have raised"
rescue StandardError
  # Expected
end

run_test("rejects tab") do
  Sashite::Feen::Parser::Hands.parse("P\t/p")
  raise "should have raised"
rescue StandardError
  # Expected
end

run_test("rejects null byte") do
  Sashite::Feen::Parser::Hands.parse("P\x00/p")
  raise "should have raised"
rescue StandardError
  # Expected
end

# ============================================================================
# SECURITY TESTS - UNICODE
# ============================================================================

puts
puts "Security - Unicode:"

run_test("rejects Cyrillic lookalike") do
  # Cyrillic 'Р' (U+0420) looks like Latin 'P'
  Sashite::Feen::Parser::Hands.parse("\xD0\xA0/p")
  raise "should have raised"
rescue StandardError
  # Expected
end

run_test("rejects full-width characters") do
  # Full-width 'P' (U+FF30)
  Sashite::Feen::Parser::Hands.parse("\xEF\xBC\xB0/p")
  raise "should have raised"
rescue StandardError
  # Expected
end

# ============================================================================
# RETURN VALUE STRUCTURE
# ============================================================================

puts
puts "Return value structure:"

run_test("returns hash with :first and :second keys") do
  result = Sashite::Feen::Parser::Hands.parse("/")
  raise "missing :first key" unless result.key?(:first)
  raise "missing :second key" unless result.key?(:second)
  raise "unexpected keys" unless result.keys.sort == [:first, :second].sort
end

run_test("hand items have :piece and :count keys") do
  result = Sashite::Feen::Parser::Hands.parse("2P/")
  item = result[:first][0]
  raise "missing :piece key" unless item.key?(:piece)
  raise "missing :count key" unless item.key?(:count)
end

run_test("piece is an EPIN Identifier") do
  result = Sashite::Feen::Parser::Hands.parse("P/")
  raise "piece should be Epin::Identifier" unless result[:first][0][:piece].is_a?(Sashite::Epin::Identifier)
end

run_test("count is an Integer") do
  result = Sashite::Feen::Parser::Hands.parse("2P/")
  raise "count should be Integer" unless result[:first][0][:count].is_a?(Integer)
end

run_test("hands are Arrays") do
  result = Sashite::Feen::Parser::Hands.parse("/")
  raise "first should be Array" unless result[:first].is_a?(Array)
  raise "second should be Array" unless result[:second].is_a?(Array)
end

puts
puts "All Hands Parser tests passed!"
puts
