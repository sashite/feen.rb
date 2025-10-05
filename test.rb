# frozen_string_literal: true

require "simplecov"

SimpleCov.command_name "Unit Tests"
SimpleCov.start

# Tests for Sashite::Feen (Forsyth–Edwards Enhanced Notation)
#
# Tests the FEEN implementation for Ruby, focusing on the functional API
# with immutable Position, Placement, Hands, and Styles objects.

require_relative "lib/sashite-feen"

# Helper function to run a test and report errors
def run_test(name)
  print "  #{name}... "
  yield
  puts "✓ Success"
rescue StandardError => e
  warn "✗ Failure: #{e.message}"
  warn "    #{e.backtrace.first}"
  exit(1)
end

puts
puts "Tests for Sashite::Feen (Forsyth–Edwards Enhanced Notation) v1.0.0"
puts

# ============================================================================
# 1. MODULE API TESTS
# ============================================================================

puts "Module API Tests"
puts "-" * 80

run_test("parse returns immutable Position object") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)

  raise "Should return Position" unless position.is_a?(Sashite::Feen::Position)
  raise "Position should be frozen" unless position.frozen?
end

run_test("dump converts Position to canonical string") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)
  dumped = Sashite::Feen.dump(position)

  raise "Should return String" unless dumped.is_a?(String)
  raise "Should be canonical" unless dumped == feen
end

run_test("parse and dump round-trip correctly") do
  examples = [
    "8/8/8/8/8/8/8/8 / C/c",
    "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/c",
    "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s",
    "rnsmksnr/8/pppppppp/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/m"
  ]

  examples.each do |original|
    position = Sashite::Feen.parse(original)
    dumped = Sashite::Feen.dump(position)
    raise "Failed for: #{original}" unless dumped == original
  end
end

run_test("position.to_s returns canonical FEEN") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)

  raise "to_s should match dump" unless position.to_s == feen
  raise "to_s should match dump" unless position.to_s == Sashite::Feen.dump(position)
end

puts

# ============================================================================
# 2. POSITION OBJECT TESTS
# ============================================================================

puts "Position Object Tests"
puts "-" * 80

run_test("Position provides component access") do
  feen = "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R P/p C/c"
  position = Sashite::Feen.parse(feen)

  raise "Should have placement" unless position.placement.is_a?(Sashite::Feen::Placement)
  raise "Should have hands" unless position.hands.is_a?(Sashite::Feen::Hands)
  raise "Should have styles" unless position.styles.is_a?(Sashite::Feen::Styles)
end

run_test("Position is immutable") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)

  raise "Position frozen" unless position.frozen?
  raise "Placement frozen" unless position.placement.frozen?
  raise "Hands frozen" unless position.hands.frozen?
  raise "Styles frozen" unless position.styles.frozen?
end

run_test("Position equality works correctly") do
  feen1 = "8/8/8/8/8/8/8/8 / C/c"
  feen2 = "8/8/8/8/8/8/8/8 / C/c"
  feen3 = "8/8/8/8/8/8/8/8 / c/C"

  pos1 = Sashite::Feen.parse(feen1)
  pos2 = Sashite::Feen.parse(feen2)
  pos3 = Sashite::Feen.parse(feen3)

  raise "Equal positions should be ==" unless pos1 == pos2
  raise "Different positions should not be ==" if pos1 == pos3
end

run_test("Position hash is consistent") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  pos1 = Sashite::Feen.parse(feen)
  pos2 = Sashite::Feen.parse(feen)

  raise "Equal positions have same hash" unless pos1.hash == pos2.hash
end

puts

# ============================================================================
# 3. PLACEMENT OBJECT TESTS
# ============================================================================

puts "Placement Object Tests"
puts "-" * 80

run_test("Placement provides ranks access") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)
  placement = position.placement

  raise "Should have ranks" unless placement.ranks.is_a?(Array)
  raise "Ranks should be frozen" unless placement.ranks.frozen?
  raise "Should have 8 ranks" unless placement.ranks.size == 8
end

run_test("Placement provides separators access") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)
  placement = position.placement

  raise "Should have separators" unless placement.separators.is_a?(Array)
  raise "Should have 7 separators" unless placement.separators.size == 7
  raise "All should be /" unless placement.separators.all? { |s| s == "/" }
end

run_test("Placement provides dimension") do
  feen_2d = "8/8/8/8/8/8/8/8 / C/c"
  feen_3d = "5/5//5/5 / R/r"

  pos_2d = Sashite::Feen.parse(feen_2d)
  pos_3d = Sashite::Feen.parse(feen_3d)

  raise "2D should be dimension 2" unless pos_2d.placement.dimension == 2
  raise "3D should be dimension 3" unless pos_3d.placement.dimension == 3
end

run_test("Placement provides rank_count") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)

  raise "Should have 8 ranks" unless position.placement.rank_count == 8
end

run_test("Placement provides one_dimensional?") do
  feen_1d = "K2P / C/c"
  feen_2d = "8/8 / C/c"

  pos_1d = Sashite::Feen.parse(feen_1d)
  pos_2d = Sashite::Feen.parse(feen_2d)

  raise "1D should return true" unless pos_1d.placement.one_dimensional?
  raise "2D should return false" if pos_2d.placement.one_dimensional?
end

run_test("Placement provides all_pieces") do
  feen = "RNBQKBNR/PPPPPPPP/8/8/8/8/pppppppp/rnbqkbnr / C/c"
  position = Sashite::Feen.parse(feen)
  pieces = position.placement.all_pieces

  raise "Should return array" unless pieces.is_a?(Array)
  raise "Should have 32 pieces" unless pieces.size == 32
  raise "Should exclude nils" unless pieces.none?(&:nil?)
end

run_test("Placement provides total_squares") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)

  raise "Should have 64 squares" unless position.placement.total_squares == 64
end

run_test("Placement to_s returns piece placement field") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)
  placement_str = position.placement.to_s

  raise "Should match field 1" unless placement_str == "8/8/8/8/8/8/8/8"
end

puts

# ============================================================================
# 4. PLACEMENT TO_A TESTS (Dimension-Aware)
# ============================================================================

puts "Placement to_a Tests (Dimension-Aware)"
puts "-" * 80

run_test("to_a for 1D board returns flat array") do
  feen = "K2P3k / C/c"
  position = Sashite::Feen.parse(feen)
  array = position.placement.to_a

  raise "Should be flat array" unless array.is_a?(Array)
  raise "Should have 8 elements" unless array.size == 8
  raise "First should be K" unless array[0].to_s == "K"
  raise "Should have nils" unless array[1].nil? && array[2].nil?
  raise "Fourth should be P" unless array[3].to_s == "P"
end

run_test("to_a for empty 1D board returns empty array") do
  placement = Sashite::Feen::Placement.new([], [], 1)
  array = placement.to_a

  raise "Should be empty array" unless array == []
end

run_test("to_a for 2D board returns array of arrays") do
  feen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR / C/c"
  position = Sashite::Feen.parse(feen)
  array = position.placement.to_a

  raise "Should be array of arrays" unless array.all? { |r| r.is_a?(Array) }
  raise "Should have 8 ranks" unless array.size == 8
  raise "Each rank has 8 squares" unless array.all? { |r| r.size == 8 }
  raise "First rank first piece is r" unless array[0][0].to_s == "r"
end

run_test("to_a for 3D board returns array of ranks") do
  feen = "5/5//5/5 / R/r"
  position = Sashite::Feen.parse(feen)
  array = position.placement.to_a

  raise "Should be array of arrays" unless array.all? { |r| r.is_a?(Array) }
  raise "Should have 4 ranks" unless array.size == 4
  raise "Should equal ranks" unless array == position.placement.ranks
end

puts

# ============================================================================
# 5. HANDS OBJECT TESTS
# ============================================================================

puts "Hands Object Tests"
puts "-" * 80

run_test("Hands provides first_player access") do
  feen = "8/8/8/8/8/8/8/8 2P/p C/c"
  position = Sashite::Feen.parse(feen)
  hands = position.hands

  raise "Should be array" unless hands.first_player.is_a?(Array)
  raise "Should be frozen" unless hands.first_player.frozen?
  raise "Should have 2 pieces" unless hands.first_player.size == 2
end

run_test("Hands provides second_player access") do
  feen = "8/8/8/8/8/8/8/8 P/3p C/c"
  position = Sashite::Feen.parse(feen)
  hands = position.hands

  raise "Should be array" unless hands.second_player.is_a?(Array)
  raise "Should be frozen" unless hands.second_player.frozen?
  raise "Should have 3 pieces" unless hands.second_player.size == 3
end

run_test("Hands provides empty?") do
  feen_empty = "8/8/8/8/8/8/8/8 / C/c"
  feen_with = "8/8/8/8/8/8/8/8 P/ C/c"

  pos_empty = Sashite::Feen.parse(feen_empty)
  pos_with = Sashite::Feen.parse(feen_with)

  raise "Empty hands return true" unless pos_empty.hands.empty?
  raise "Non-empty hands return false" if pos_with.hands.empty?
end

run_test("Hands to_s returns pieces-in-hand field") do
  feen = "8/8/8/8/8/8/8/8 2P/p C/c"
  position = Sashite::Feen.parse(feen)
  hands_str = position.hands.to_s

  raise "Should match field 2" unless hands_str == "2P/p"
end

run_test("Hands with count prefix parsing") do
  feen = "8/8/8/8/8/8/8/8 3P2R/2pB C/c"
  position = Sashite::Feen.parse(feen)
  hands = position.hands

  first_pieces = hands.first_player.map(&:to_s)
  raise "Should have 3 P" unless first_pieces.count("P") == 3
  raise "Should have 2 R" unless first_pieces.count("R") == 2
  raise "Total 5 pieces" unless hands.first_player.size == 5

  second_pieces = hands.second_player.map(&:to_s)
  raise "Should have 2 p" unless second_pieces.count("p") == 2
  raise "Should have 1 B" unless second_pieces.count("B") == 1
end

puts

# ============================================================================
# 6. STYLES OBJECT TESTS
# ============================================================================

puts "Styles Object Tests"
puts "-" * 80

run_test("Styles provides active access") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)
  styles = position.styles

  raise "Should have active" unless styles.active.to_s == "C"
end

run_test("Styles provides inactive access") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)
  styles = position.styles

  raise "Should have inactive" unless styles.inactive.to_s == "c"
end

run_test("Styles to_s returns style-turn field") do
  feen = "8/8/8/8/8/8/8/8 / S/s"
  position = Sashite::Feen.parse(feen)
  styles_str = position.styles.to_s

  raise "Should match field 3" unless styles_str == "S/s"
end

run_test("Styles indicates active player via case") do
  feen_white = "8/8/8/8/8/8/8/8 / C/c"
  feen_black = "8/8/8/8/8/8/8/8 / c/C"

  pos_white = Sashite::Feen.parse(feen_white)
  pos_black = Sashite::Feen.parse(feen_black)

  raise "White active: C" unless pos_white.styles.active.to_s == "C"
  raise "Black active: c" unless pos_black.styles.active.to_s == "c"
end

puts

# ============================================================================
# 7. ERROR HANDLING TESTS
# ============================================================================

puts "Error Handling Tests"
puts "-" * 80

run_test("Error::Syntax for wrong field count") do
  invalid = "8/8/8/8/8/8/8/8 /"

  begin
    Sashite::Feen.parse(invalid)
    raise "Should raise Syntax error"
  rescue Sashite::Feen::Error::Syntax => e
    raise "Should mention field count" unless e.message.include?("3 space-separated fields")
  end
end

run_test("Error::Syntax for empty style") do
  invalid = "8/8/8/8/8/8/8/8 / /"

  begin
    Sashite::Feen.parse(invalid)
    raise "Should raise Syntax error"
  rescue Sashite::Feen::Error::Syntax => e
    raise "Should mention empty" unless e.message.include?("cannot be empty")
  end
end

run_test("Error::Style for invalid SIN") do
  invalid = "8/8/8/8/8/8/8/8 / 1/2"

  begin
    Sashite::Feen.parse(invalid)
    raise "Should raise Style error"
  rescue Sashite::Feen::Error::Style => e
    raise "Should mention SIN" unless e.message.include?("SIN")
  end
end

run_test("Error::Count for zero pieces") do
  invalid = "8/8/8/8/8/8/8/8 0P/ C/c"

  begin
    Sashite::Feen.parse(invalid)
    raise "Should raise Count error"
  rescue Sashite::Feen::Error::Count => e
    raise "Should mention at least 1" unless e.message.include?("at least 1")
  end
end

run_test("Error::Count for excessive count") do
  invalid = "8/8/8/8/8/8/8/8 9999P/ C/c"

  begin
    Sashite::Feen.parse(invalid)
    raise "Should raise Count error"
  rescue Sashite::Feen::Error::Count => e
    raise "Should mention too large" unless e.message.include?("too large")
  end
end

run_test("All errors inherit from base Error") do
  raise "Syntax < Error" unless Sashite::Feen::Error::Syntax < Sashite::Feen::Error
  raise "Piece < Error" unless Sashite::Feen::Error::Piece < Sashite::Feen::Error
  raise "Style < Error" unless Sashite::Feen::Error::Style < Sashite::Feen::Error
  raise "Count < Error" unless Sashite::Feen::Error::Count < Sashite::Feen::Error
  raise "Validation < Error" unless Sashite::Feen::Error::Validation < Sashite::Feen::Error
end

puts

# ============================================================================
# 8. EXAMPLES FROM README
# ============================================================================

puts "Examples from README"
puts "-" * 80

run_test("Empty 8x8 board") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)

  raise "Should parse" unless position.is_a?(Sashite::Feen::Position)
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("Chess starting position") do
  feen = "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/c"
  position = Sashite::Feen.parse(feen)

  raise "Should have 8 ranks" unless position.placement.ranks.size == 8
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("Chess after 1.e4") do
  feen = "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/4P3/8/+P+P+P+P1+P+P+P/+RNBQ+KBN+R / c/C"
  position = Sashite::Feen.parse(feen)

  raise "Black to move" unless position.styles.active.to_s == "c"
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("Ruy Lopez opening") do
  feen = "r1bqkbnr/+p+p+p+p1+p+p+p/2n5/1B2p3/4P3/5N2/+P+P+P+P1+P+P+P/RNBQK2R / c/C"
  position = Sashite::Feen.parse(feen)

  raise "Should parse complex position" unless position.is_a?(Sashite::Feen::Position)
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("Shōgi starting position") do
  feen = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s"
  position = Sashite::Feen.parse(feen)

  raise "Should have 9 ranks" unless position.placement.ranks.size == 9
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("Shōgi with captured pieces") do
  feen = "lnsgkgsnl/1r5b1/pppp1pppp/9/4p4/9/PPPP1PPPP/1B5R1/LNSGKGSNL P/p s/S"
  position = Sashite::Feen.parse(feen)

  raise "First player has 1 piece" unless position.hands.first_player.size == 1
  raise "Second player has 1 piece" unless position.hands.second_player.size == 1
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("Chess vs Makruk cross-style") do
  feen = "rnsmksnr/8/pppppppp/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/m"
  position = Sashite::Feen.parse(feen)

  raise "Chess to move" unless position.styles.active.to_s == "C"
  raise "Makruk waiting" unless position.styles.inactive.to_s == "m"
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("Chess vs Shōgi cross-style") do
  feen = "lnsgkgsnl/1r5b1/pppppppp/9/9/9/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/s"
  position = Sashite::Feen.parse(feen)

  raise "Chess to move" unless position.styles.active.to_s == "C"
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("3D Raumschach starting position") do
  feen = "rnknr/+p+p+p+p+p/5/5/5//buqbu/+p+p+p+p+p/5/5/5//5/5/5/5/5//5/5/5/+P+P+P+P+P/BUQBU//5/5/5/+P+P+P+P+P/RNKNR / R/r"
  position = Sashite::Feen.parse(feen)

  raise "Should be 3D" unless position.placement.dimension == 3
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("Diamond-shaped irregular board") do
  feen = "3/4/5/4/3 / G/g"
  position = Sashite::Feen.parse(feen)

  sizes = position.placement.ranks.map(&:size)
  raise "Should have diamond shape" unless sizes == [3, 4, 5, 4, 3]
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("Very large board (100x3)") do
  feen = "100/100/100 / G/g"
  position = Sashite::Feen.parse(feen)

  raise "Should have 300 squares" unless position.placement.total_squares == 300
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("Single square board (1D)") do
  feen = "K / C/c"
  position = Sashite::Feen.parse(feen)

  raise "Should be 1D" unless position.placement.one_dimensional?
  raise "Should have 1 rank" unless position.placement.rank_count == 1
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("1D board with pieces and spaces") do
  feen = "K2P3k / C/c"
  position = Sashite::Feen.parse(feen)
  array = position.placement.to_a

  raise "Should be 1D" unless position.placement.one_dimensional?
  raise "Should have 8 squares" unless array.size == 8
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("Completely irregular structure") do
  feen = "99999/3///K/k//r / G/g"
  position = Sashite::Feen.parse(feen)

  raise "Should have 5 ranks" unless position.placement.ranks.size == 5
  raise "Dimension should be 4" unless position.placement.dimension == 4
  raise "First rank size 99999" unless position.placement.ranks[0].size == 99999
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("Board-less position (empty placement)") do
  feen = " / C/c"
  position = Sashite::Feen.parse(feen)

  raise "Should be 1D" unless position.placement.dimension == 1
  raise "to_a should be empty" unless position.placement.to_a == []
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

puts

# ============================================================================
# 9. PIECE STATE MODIFIERS AND DERIVATION
# ============================================================================

puts "Piece State Modifiers and Derivation"
puts "-" * 80

run_test("Enhanced pieces (+ prefix)") do
  feen = "+K+Q+R+B/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)
  first_rank = position.placement.ranks[0]

  raise "All should start with +" unless first_rank.compact.all? { |p| p.to_s.start_with?("+") }
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("Diminished pieces (- prefix)") do
  feen = "-K-Q-R-B/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)
  first_rank = position.placement.ranks[0]

  raise "All should start with -" unless first_rank.compact.all? { |p| p.to_s.start_with?("-") }
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("Foreign pieces (' suffix)") do
  feen = "K'Q'R'B'/k'q'r'b'/8/8/8/8/8/8 / C/s"
  position = Sashite::Feen.parse(feen)
  first_rank = position.placement.ranks[0]
  second_rank = position.placement.ranks[1]

  raise "First rank all foreign" unless first_rank.all? { |p| p.to_s.end_with?("'") }
  raise "Second rank all foreign" unless second_rank.all? { |p| p.to_s.end_with?("'") }
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("Combined modifiers (+/- and ')") do
  feen = "+K'-R'+P-p'/8/8/8/8/8/8/8 / C/s"
  position = Sashite::Feen.parse(feen)
  first_rank = position.placement.ranks[0]

  pieces = first_rank.compact.map(&:to_s)
  raise "Should have +K'" unless pieces.include?("+K'")
  raise "Should have -R'" unless pieces.include?("-R'")
  raise "Should have +P" unless pieces.include?("+P")
  raise "Should have -p'" unless pieces.include?("-p'")
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

puts

# ============================================================================
# 10. CANONICAL FORM TESTS
# ============================================================================

puts "Canonical Form Tests"
puts "-" * 80

run_test("Consistent output for same position") do
  feen = "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/c"

  pos1 = Sashite::Feen.parse(feen)
  pos2 = Sashite::Feen.parse(feen)

  dump1 = Sashite::Feen.dump(pos1)
  dump2 = Sashite::Feen.dump(pos2)

  raise "Same position produces same dump" unless dump1 == dump2
end

run_test("Pieces in hand sorted canonically") do
  # Input with unsorted pieces
  feen = "8/8/8/8/8/8/8/8 RPN2B/p C/c"
  position = Sashite::Feen.parse(feen)
  dumped = Sashite::Feen.dump(position)

  # Should be sorted: 2B (count desc), then N, P, R (alpha)
  expected = "8/8/8/8/8/8/8/8 2BNPR/p C/c"
  raise "Should sort canonically: got #{dumped}" unless dumped == expected
end

run_test("Empty square compression is optimal") do
  feen = "r7/8/8/8/8/8/8/7R / C/c"
  position = Sashite::Feen.parse(feen)
  dumped = Sashite::Feen.dump(position)

  raise "Should compress empty squares" unless dumped == feen
  raise "No consecutive digits" unless !dumped.match?(/\d\d/)
end

puts

# ============================================================================
# 11. EDGE CASES AND STRESS TESTS
# ============================================================================

puts "Edge Cases and Stress Tests"
puts "-" * 80

run_test("Empty ranks (trailing separator)") do
  feen = "K/// / C/c"
  position = Sashite::Feen.parse(feen)

  raise "Should have 2 ranks" unless position.placement.ranks.size == 2
  raise "First has K" unless position.placement.ranks[0].size == 1
  raise "Second is empty" unless position.placement.ranks[1].empty?
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("Very long rank (20 squares)") do
  feen = "20 / C/c"
  position = Sashite::Feen.parse(feen)

  raise "Should have 20 squares" unless position.placement.ranks[0].size == 20
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("Many pieces in hand (large counts)") do
  feen = "8/8/8/8/8/8/8/8 20P10R5B/15p C/c"
  position = Sashite::Feen.parse(feen)

  raise "First player 35 pieces" unless position.hands.first_player.size == 35
  raise "Second player 15 pieces" unless position.hands.second_player.size == 15
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("All piece types (A-Z)") do
  feen = "ABCDEFGH/IJKLMNOP/QRSTUVWX/YZ6/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)

  first_rank = position.placement.ranks[0]
  raise "Should parse all types" unless first_rank.size == 8
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("Mixed states in hand") do
  feen = "8/8/8/8/8/8/8/8 +K-K+R-R+P-P/+k-k C/c"
  position = Sashite::Feen.parse(feen)

  raise "First player 6 pieces" unless position.hands.first_player.size == 6
  raise "Second player 2 pieces" unless position.hands.second_player.size == 2
end

run_test("Multi-digit empty square counts") do
  feen = "123/456/789 / G/g"
  position = Sashite::Feen.parse(feen)

  sizes = position.placement.ranks.map(&:size)
  raise "Should parse multi-digit" unless sizes == [123, 456, 789]
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

puts

# ============================================================================
# 12. INTEGRATION TESTS
# ============================================================================

puts "Integration Tests"
puts "-" * 80

run_test("Parse multiple positions in sequence") do
  feen_strings = [
    "8/8/8/8/8/8/8/8 / C/c",
    "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/c",
    "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s",
    "rnsmksnr/8/pppppppp/8/8/8/PPPPPPPP/RNSMKSNR / M/m"
  ]

  positions = feen_strings.map { |f| Sashite::Feen.parse(f) }

  raise "Should parse all" unless positions.size == 4
  raise "All Position objects" unless positions.all? { |p| p.is_a?(Sashite::Feen::Position) }

  dumps = positions.map { |p| Sashite::Feen.dump(p) }
  raise "All should round-trip" unless dumps == feen_strings
end

run_test("Complex cross-style with captures") do
  feen = "lnsgkgsnl/1r5b1/pppppppp/9/9/9/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R/LNSGKGSNL 2P'/p' C/s"
  position = Sashite::Feen.parse(feen)

  raise "Valid placement" unless position.placement.ranks.size == 9
  raise "Has pieces in hands" unless !position.hands.empty?
  raise "Cross-style" unless position.styles.active.to_s != position.styles.inactive.to_s.upcase

  first_hand = position.hands.first_player
  raise "Has foreign pieces" unless first_hand.any? { |p| p.to_s.end_with?("'") }

  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

run_test("Accessing all components systematically") do
  feen = "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R 2P/p C/c"
  position = Sashite::Feen.parse(feen)

  # Placement
  placement = position.placement
  raise "8 ranks" unless placement.ranks.size == 8
  raise "Dimension 2" unless placement.dimension == 2
  raise "64 squares" unless placement.total_squares == 64

  # Hands
  hands = position.hands
  raise "First player has pieces" unless hands.first_player.size == 2
  raise "Second player has pieces" unless hands.second_player.size == 1

  # Styles
  styles = position.styles
  raise "Active C" unless styles.active.to_s == "C"
  raise "Inactive c" unless styles.inactive.to_s == "c"

  # Round-trip
  raise "Should round-trip" unless Sashite::Feen.dump(position) == feen
end

puts

# ============================================================================
# SUMMARY
# ============================================================================

puts
puts "All FEEN tests passed!"
puts
