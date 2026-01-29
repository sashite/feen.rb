#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../../lib/sashite/feen"

# Helper function to run a test and report errors
def run_test(name)
  print "  #{name}... "
  yield
  puts "✓"
rescue StandardError => e
  warn "✗ Failure: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end unless defined?(run_test)

puts
puts "=== Feen Public API Tests ==="
puts

# ============================================================================
# PARSE - MINIMAL VALID INPUTS
# ============================================================================

puts "parse - minimal valid inputs:"

run_test("parses 'K / C/c'") do
  position = Sashite::Feen.parse("K / C/c")
  raise "wrong type" unless position.is_a?(Sashite::Feen::Position)
  raise "wrong string" unless position.to_s == "K / C/c"
end

run_test("parses '8 / C/c' (empty board)") do
  position = Sashite::Feen.parse("8 / C/c")
  raise "wrong string" unless position.to_s == "8 / C/c"
end

run_test("parses 'K P/ C/c' (piece in first hand)") do
  position = Sashite::Feen.parse("K P/ C/c")
  raise "first hand should have items" if position.hands.first.empty?
end

run_test("parses 'K /p C/c' (piece in second hand)") do
  position = Sashite::Feen.parse("K /p C/c")
  raise "second hand should have items" if position.hands.second.empty?
end

# ============================================================================
# PARSE - CHESS POSITIONS
# ============================================================================

puts
puts "parse - Chess positions:"

run_test("parses Chess initial position") do
  input = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
  position = Sashite::Feen.parse(input)
  raise "wrong to_s" unless position.to_s == input
  raise "wrong segment count" unless position.piece_placement.segments.size == 8
  raise "first to move?" unless position.style_turn.first_to_move?
end

run_test("parses Chess position after e4") do
  input = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR / c/C"
  position = Sashite::Feen.parse(input)
  raise "wrong to_s" unless position.to_s == input
  raise "should be second to move" unless position.style_turn.second_to_move?
end

run_test("parses Chess position with captures") do
  input = "r1bqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR NB/n C/c"
  position = Sashite::Feen.parse(input)
  raise "first hand should have 2 items" unless position.hands.first.size == 2
  raise "second hand should have 1 item" unless position.hands.second.size == 1
end

# ============================================================================
# PARSE - SHOGI POSITIONS
# ============================================================================

puts
puts "parse - Shogi positions:"

run_test("parses Shogi initial position") do
  input = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s"
  position = Sashite::Feen.parse(input)
  raise "wrong to_s" unless position.to_s == input
  raise "wrong segment count" unless position.piece_placement.segments.size == 9
end

run_test("parses Shogi position with pieces in hand") do
  input = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL 2P/ S/s"
  position = Sashite::Feen.parse(input)
  raise "first hand should have items" if position.hands.first.empty?
  raise "first item count should be 2" unless position.hands.first.items[0][:count] == 2
end

run_test("parses Shogi position with promoted pieces") do
  input = "+P8/9/9/9/9/9/9/9/9 / S/s"
  position = Sashite::Feen.parse(input)
  first_segment = position.piece_placement.segments[0]
  first_piece = first_segment[0]
  raise "first piece should be enhanced" unless first_piece.pin.state == :enhanced
end

# ============================================================================
# PARSE - XIANGQI POSITIONS
# ============================================================================

puts
puts "parse - Xiangqi positions:"

run_test("parses Xiangqi initial position") do
  input = "rheagaehr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RHEAGAEHR / X/x"
  position = Sashite::Feen.parse(input)
  raise "wrong to_s" unless position.to_s == input
  raise "wrong segment count" unless position.piece_placement.segments.size == 10
end

# ============================================================================
# PARSE - 3D BOARDS
# ============================================================================

puts
puts "parse - 3D boards:"

run_test("parses 3D position with double separators") do
  input = "5/5/2K2/5/5//5/5/5/5/5//5/5/2k2/5/5 / C/c"
  position = Sashite::Feen.parse(input)
  raise "should preserve double separators" unless position.to_s.include?("//")
end

run_test("parses Raumschach-style position") do
  # 5 layers of 5x5
  input = "5/5/5/5/5//5/5/2K2/5/5//5/5/5/5/5//5/5/2k2/5/5//5/5/5/5/5 / C/c"
  position = Sashite::Feen.parse(input)
  raise "wrong segment count" unless position.piece_placement.segments.size == 25
  # Check separator preservation (4 double separators between 5 layers)
  double_seps = position.piece_placement.separators.count("//")
  raise "should have 4 double separators, got #{double_seps}" unless double_seps == 4
end

# ============================================================================
# PARSE - CROSS-STYLE GAMES
# ============================================================================

puts
puts "parse - cross-style games:"

run_test("parses Chess vs Shogi game") do
  input = "K / C/s"
  position = Sashite::Feen.parse(input)
  raise "wrong active abbr" unless position.style_turn.active_style.abbr == :C
  raise "wrong inactive abbr" unless position.style_turn.inactive_style.abbr == :S
end

run_test("parses Shogi vs Chess, second to move") do
  input = "K / s/C"
  position = Sashite::Feen.parse(input)
  raise "should be second to move" unless position.style_turn.second_to_move?
  raise "wrong active abbr" unless position.style_turn.active_style.abbr == :S
end

# ============================================================================
# PARSE - EPIN MODIFIERS
# ============================================================================

puts
puts "parse - EPIN modifiers:"

run_test("parses enhanced pieces (+)") do
  input = "+K / C/c"
  position = Sashite::Feen.parse(input)
  piece = position.piece_placement.segments[0][0]
  raise "should be enhanced" unless piece.pin.state == :enhanced
end

run_test("parses diminished pieces (-)") do
  input = "-K / C/c"
  position = Sashite::Feen.parse(input)
  piece = position.piece_placement.segments[0][0]
  raise "should be diminished" unless piece.pin.state == :diminished
end

run_test("parses terminal pieces (^)") do
  input = "K^ / C/c"
  position = Sashite::Feen.parse(input)
  piece = position.piece_placement.segments[0][0]
  raise "should be terminal" unless piece.pin.terminal?
end

run_test("parses derived pieces (')") do
  input = "K' / C/c"
  position = Sashite::Feen.parse(input)
  piece = position.piece_placement.segments[0][0]
  raise "should be derived" unless piece.derived?
end

run_test("parses all modifiers combined (+K^')") do
  input = "+K^' / C/c"
  position = Sashite::Feen.parse(input)
  piece = position.piece_placement.segments[0][0]
  raise "should be enhanced" unless piece.pin.state == :enhanced
  raise "should be terminal" unless piece.pin.terminal?
  raise "should be derived" unless piece.derived?
end

# ============================================================================
# PARSE - COMPLEX HANDS
# ============================================================================

puts
puts "parse - complex hands:"

run_test("parses multiple piece types in hands") do
  input = "K 2P3BRN/2pq C/c"
  position = Sashite::Feen.parse(input)
  raise "first hand wrong size" unless position.hands.first.size == 4
  raise "second hand wrong size" unless position.hands.second.size == 2
end

run_test("parses EPIN modifiers in hands") do
  input = "K +P^'/ C/c"
  position = Sashite::Feen.parse(input)
  item = position.hands.first.items[0]
  raise "should be enhanced" unless item[:piece].pin.state == :enhanced
  raise "should be terminal" unless item[:piece].pin.terminal?
  raise "should be derived" unless item[:piece].derived?
end

# ============================================================================
# PARSE - ROUND-TRIP
# ============================================================================

puts
puts "parse - round-trip consistency:"

run_test("round-trip preserves Chess initial position") do
  input = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
  position = Sashite::Feen.parse(input)
  raise "round-trip failed" unless position.to_s == input
end

run_test("round-trip preserves Shogi initial position") do
  input = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s"
  position = Sashite::Feen.parse(input)
  raise "round-trip failed" unless position.to_s == input
end

run_test("round-trip preserves position with hands") do
  input = "K 2PBN/3qr C/c"
  position = Sashite::Feen.parse(input)
  raise "round-trip failed" unless position.to_s == input
end

run_test("round-trip preserves 3D separators") do
  input = "K//Q///R / C/c"
  position = Sashite::Feen.parse(input)
  raise "round-trip failed" unless position.to_s == input
end

run_test("round-trip preserves EPIN modifiers") do
  input = "+K^' / C/c"
  position = Sashite::Feen.parse(input)
  raise "round-trip failed" unless position.to_s == input
end

# ============================================================================
# PARSE - ERROR CASES
# ============================================================================

puts
puts "parse - error cases:"

run_test("raises on empty string") do
  Sashite::Feen.parse("")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::EMPTY_INPUT
end

run_test("raises on single field") do
  Sashite::Feen.parse("K")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument => e
  raise "wrong message" unless e.message == Sashite::Feen::Errors::Argument::Messages::INVALID_FIELD_COUNT
end

run_test("raises on invalid piece placement") do
  Sashite::Feen.parse("/K / C/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument
  # Expected
end

run_test("raises on invalid hands") do
  Sashite::Feen.parse("K PP C/c")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument
  # Expected
end

run_test("raises on invalid style-turn") do
  Sashite::Feen.parse("K / C/C")
  raise "should have raised"
rescue Sashite::Feen::Errors::Argument
  # Expected
end

run_test("error is ArgumentError subclass") do
  Sashite::Feen.parse("")
  raise "should have raised"
rescue ArgumentError
  # Expected - should be catchable as ArgumentError
end

# ============================================================================
# VALID? - TRUE CASES
# ============================================================================

puts
puts "valid? - true cases:"

run_test("returns true for minimal FEEN") do
  raise "should be valid" unless Sashite::Feen.valid?("K / C/c")
end

run_test("returns true for Chess initial position") do
  input = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
  raise "should be valid" unless Sashite::Feen.valid?(input)
end

run_test("returns true for Shogi initial position") do
  input = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s"
  raise "should be valid" unless Sashite::Feen.valid?(input)
end

run_test("returns true for position with hands") do
  raise "should be valid" unless Sashite::Feen.valid?("K 2P/n C/c")
end

run_test("returns true for cross-style game") do
  raise "should be valid" unless Sashite::Feen.valid?("K / C/s")
end

run_test("returns true for 3D position") do
  raise "should be valid" unless Sashite::Feen.valid?("K//Q / C/c")
end

run_test("returns true for EPIN modifiers") do
  raise "should be valid" unless Sashite::Feen.valid?("+K^' / C/c")
end

# ============================================================================
# VALID? - FALSE CASES
# ============================================================================

puts
puts "valid? - false cases:"

run_test("returns false for empty string") do
  raise "should be invalid" if Sashite::Feen.valid?("")
end

run_test("returns false for nil") do
  raise "should be invalid" if Sashite::Feen.valid?(nil)
end

run_test("returns false for non-string") do
  raise "should be invalid" if Sashite::Feen.valid?(123)
  raise "should be invalid" if Sashite::Feen.valid?(:symbol)
  raise "should be invalid" if Sashite::Feen.valid?([])
end

run_test("returns false for single field") do
  raise "should be invalid" if Sashite::Feen.valid?("K")
end

run_test("returns false for two fields") do
  raise "should be invalid" if Sashite::Feen.valid?("K /")
end

run_test("returns false for four fields") do
  raise "should be invalid" if Sashite::Feen.valid?("K / C/c extra")
end

run_test("returns false for leading separator") do
  raise "should be invalid" if Sashite::Feen.valid?("/K / C/c")
end

run_test("returns false for trailing separator") do
  raise "should be invalid" if Sashite::Feen.valid?("K/ / C/c")
end

run_test("returns false for invalid hands") do
  raise "should be invalid" if Sashite::Feen.valid?("K PP C/c")
end

run_test("returns false for same case style-turn") do
  raise "should be invalid" if Sashite::Feen.valid?("K / C/C")
end

run_test("returns false for zero empty count") do
  raise "should be invalid" if Sashite::Feen.valid?("0 / C/c")
end

run_test("returns false for leading zero") do
  raise "should be invalid" if Sashite::Feen.valid?("08 / C/c")
end

# ============================================================================
# SECURITY TESTS
# ============================================================================

puts
puts "Security tests:"

run_test("rejects newline at end") do
  raise "should be invalid" if Sashite::Feen.valid?("K / C/c\n")
end

run_test("rejects newline in piece placement") do
  raise "should be invalid" if Sashite::Feen.valid?("K\n8 / C/c")
end

run_test("rejects null byte") do
  raise "should be invalid" if Sashite::Feen.valid?("K\x00 / C/c")
end

run_test("rejects Unicode lookalikes") do
  # Cyrillic 'К' looks like Latin 'K'
  raise "should be invalid" if Sashite::Feen.valid?("\xD0\x9A / C/c")
end

run_test("rejects newline in hands") do
  raise "should be invalid" if Sashite::Feen.valid?("K P\n/ C/c")
end

run_test("rejects newline in style-turn") do
  raise "should be invalid" if Sashite::Feen.valid?("K / C\n/c")
end

# ============================================================================
# INTEGRATION TESTS
# ============================================================================

puts
puts "Integration tests:"

run_test("parsed position components are accessible") do
  input = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
  position = Sashite::Feen.parse(input)

  # Access piece_placement
  raise "wrong type" unless position.piece_placement.is_a?(Sashite::Feen::Position::PiecePlacement)

  # Access hands
  raise "wrong type" unless position.hands.is_a?(Sashite::Feen::Position::Hands)

  # Access style_turn
  raise "wrong type" unless position.style_turn.is_a?(Sashite::Feen::Position::StyleTurn)
end

run_test("parsed position can be used as hash key") do
  input = "K / C/c"
  pos1 = Sashite::Feen.parse(input)
  pos2 = Sashite::Feen.parse(input)

  hash = { pos1 => "value" }
  raise "should find by equal key" unless hash[pos2] == "value"
end

run_test("parsed position equality works") do
  input = "K / C/c"
  pos1 = Sashite::Feen.parse(input)
  pos2 = Sashite::Feen.parse(input)

  raise "should be equal" unless pos1 == pos2
  raise "should have same hash" unless pos1.hash == pos2.hash
end

run_test("different positions are not equal") do
  pos1 = Sashite::Feen.parse("K / C/c")
  pos2 = Sashite::Feen.parse("Q / C/c")

  raise "should not be equal" if pos1 == pos2
end

run_test("inspect produces useful output") do
  position = Sashite::Feen.parse("K / C/c")
  inspect_str = position.inspect
  raise "should contain class" unless inspect_str.include?("Position")
  raise "should contain FEEN" unless inspect_str.include?("K / C/c")
end

puts
puts "All Feen public API tests passed!"
puts
