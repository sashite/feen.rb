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
# Module-level API Tests
# ============================================================================

run_test("Module parse returns Position object") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)

  raise "parse should return Position instance" unless position.is_a?(Sashite::Feen::Position)
  raise "Position should have placement" unless position.placement.is_a?(Sashite::Feen::Placement)
  raise "Position should have hands" unless position.hands.is_a?(Sashite::Feen::Hands)
  raise "Position should have styles" unless position.styles.is_a?(Sashite::Feen::Styles)
end

run_test("Module dump converts Position to canonical string") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)
  dumped = Sashite::Feen.dump(position)

  raise "dump should return string" unless dumped.is_a?(String)
  raise "dump should produce canonical FEEN" unless dumped == feen
end

run_test("Module parse and dump round-trip correctly") do
  test_feen_strings = [
    "8/8/8/8/8/8/8/8 / C/c",
    "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/c",
    "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL P/p S/s",
    "rnsmksnr/8/pppppppp/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/m"
  ]

  test_feen_strings.each do |original|
    position = Sashite::Feen.parse(original)
    dumped = Sashite::Feen.dump(position)
    raise "Round-trip failed for: #{original}" unless dumped == original
  end
end

# ============================================================================
# Field 1: Piece Placement Tests
# ============================================================================

run_test("Parse empty board") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)
  placement = position.placement

  raise "Should have 8 ranks" unless placement.ranks.size == 8
  raise "All squares should be empty" unless placement.ranks.all? { |rank| rank.all?(&:nil?) }
  raise "Dimension should be 2" unless placement.dimension == 2
end

run_test("Parse board with pieces") do
  feen = "+RNBQ+KBN+R/8/8/8/8/8/8/+rnbq+kbn+r / C/c"
  position = Sashite::Feen.parse(feen)
  placement = position.placement

  first_rank = placement.ranks[0]
  last_rank = placement.ranks[7]

  raise "First rank should have 8 pieces" unless first_rank.compact.size == 8
  raise "Last rank should have 8 pieces" unless last_rank.compact.size == 8
  raise "Middle ranks should be empty" unless placement.ranks[1..6].all? { |rank| rank.all?(&:nil?) }
end

run_test("Parse standard chess starting position") do
  feen = "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/c"
  position = Sashite::Feen.parse(feen)
  placement = position.placement

  raise "Should have 8 ranks" unless placement.ranks.size == 8

  # Check first rank
  first_rank = placement.ranks[0]
  raise "First rank should have rook at start" unless first_rank[0].to_s == "+r"
  raise "First rank should have king" unless first_rank.any? { |p| p&.to_s == "+k" }

  # Check last rank
  last_rank = placement.ranks[7]
  raise "Last rank should have Rook at start" unless last_rank[0].to_s == "+R"
  raise "Last rank should have King" unless last_rank.any? { |p| p&.to_s == "+K" }
end

run_test("Parse mixed pieces and empty squares") do
  feen = "r1bqkb1r/+p+p+p+p1+p+p+p/2n2n2/4p3/2B1P3/5N2/+P+P+P+P1+P+P+P/RNBQK2R / C/c"
  position = Sashite::Feen.parse(feen)
  placement = position.placement

  raise "Should parse correctly" unless placement.ranks.size == 8

  first_rank = placement.ranks[0]
  raise "Should have rook at position 0" unless first_rank[0]&.to_s == "r"
  raise "Should have empty at position 1" unless first_rank[1].nil?
  raise "Should have bishop at position 2" unless first_rank[2]&.to_s == "b"
end

run_test("Parse irregular board shapes") do
  feen = "3/4/5/4/3 / G/g"
  position = Sashite::Feen.parse(feen)
  placement = position.placement

  raise "Should have 5 ranks" unless placement.ranks.size == 5
  raise "First rank should have 3 squares" unless placement.ranks[0].size == 3
  raise "Second rank should have 4 squares" unless placement.ranks[1].size == 4
  raise "Third rank should have 5 squares" unless placement.ranks[2].size == 5
end

run_test("Parse 3D board with multiple planes") do
  feen = "5/5/5/5/5//5/5/5/5/5//5/5/5/5/5 / R/r"
  position = Sashite::Feen.parse(feen)
  placement = position.placement

  raise "Should have 3 planes (15 ranks)" unless placement.ranks.size == 15
  raise "Dimension should be 3" unless placement.dimension == 3
end

run_test("Parse pieces with state modifiers") do
  feen = "+K-p+R'-B/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)
  first_rank = position.placement.ranks[0]

  raise "Should parse enhanced King" unless first_rank[0]&.to_s == "+K"
  raise "Should parse diminished pawn" unless first_rank[1]&.to_s == "-p"
  raise "Should parse enhanced foreign Rook" unless first_rank[2]&.to_s == "+R'"
  raise "Should parse diminished Bishop" unless first_rank[3]&.to_s == "-B"
end

run_test("Parse pieces with derivation suffix") do
  feen = "K'k'R'r'/8/8/8/8/8/8/8 / C/o"
  position = Sashite::Feen.parse(feen)
  first_rank = position.placement.ranks[0]

  raise "Should parse foreign King" unless first_rank[0]&.to_s == "K'"
  raise "Should parse foreign king" unless first_rank[1]&.to_s == "k'"
  raise "Should parse foreign Rook" unless first_rank[2]&.to_s == "R'"
  raise "Should parse foreign rook" unless first_rank[3]&.to_s == "r'"
end

run_test("Dump empty board correctly") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)
  dumped = Sashite::Feen.dump(position)

  raise "Dump should match input" unless dumped == feen
end

run_test("Dump compresses consecutive empty squares") do
  # Create position manually with some empty squares
  feen = "r7/8/8/8/8/8/8/7R / C/c"
  position = Sashite::Feen.parse(feen)
  dumped = Sashite::Feen.dump(position)

  raise "Should compress empty squares" unless dumped == feen
  raise "Should not have consecutive digits" unless !dumped.match?(/\d\d/)
end

# ============================================================================
# Field 2: Pieces in Hand Tests
# ============================================================================

run_test("Parse empty hands") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)
  hands = position.hands

  raise "First player hands should be empty" unless hands.first_player.empty?
  raise "Second player hands should be empty" unless hands.second_player.empty?
  raise "Hands should be empty" unless hands.empty?
end

run_test("Parse single pieces in hand") do
  feen = "8/8/8/8/8/8/8/8 P/p C/c"
  position = Sashite::Feen.parse(feen)
  hands = position.hands

  raise "First player should have 1 piece" unless hands.first_player.size == 1
  raise "Second player should have 1 piece" unless hands.second_player.size == 1
  raise "First player piece should be P" unless hands.first_player[0].to_s == "P"
  raise "Second player piece should be p" unless hands.second_player[0].to_s == "p"
end

run_test("Parse multiple pieces with counts") do
  feen = "8/8/8/8/8/8/8/8 3P2R/2pB C/c"
  position = Sashite::Feen.parse(feen)
  hands = position.hands

  raise "First player should have 5 pieces" unless hands.first_player.size == 5
  raise "Second player should have 3 pieces" unless hands.second_player.size == 3

  first_pieces = hands.first_player.map(&:to_s)
  raise "Should have 3 pawns" unless first_pieces.count("P") == 3
  raise "Should have 2 rooks" unless first_pieces.count("R") == 2
end

run_test("Parse pieces with state modifiers in hand") do
  feen = "8/8/8/8/8/8/8/8 +K-p/+R' C/c"
  position = Sashite::Feen.parse(feen)
  hands = position.hands

  first_pieces = hands.first_player.map(&:to_s)
  second_pieces = hands.second_player.map(&:to_s)

  raise "Should parse enhanced King" unless first_pieces.include?("+K")
  raise "Should parse diminished pawn" unless first_pieces.include?("-p")
  raise "Should parse enhanced foreign Rook" unless second_pieces.include?("+R'")
end

run_test("Dump empty hands correctly") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)
  dumped = Sashite::Feen.dump(position)

  raise "Should dump empty hands as '/'" unless dumped.include?(" / ")
end

run_test("Dump pieces in canonical order") do
  # According to FEEN spec: by quantity (desc), letter (asc), case, prefix, suffix
  feen = "8/8/8/8/8/8/8/8 3P2pR/B C/c"
  position = Sashite::Feen.parse(feen)
  dumped = Sashite::Feen.dump(position)

  # Should be sorted: 3P (most), then 2p, then R, then B
  hands_part = dumped.split(" ")[1]
  first_player_part = hands_part.split("/")[0]

  raise "Pieces should be in canonical order" unless first_player_part == "3P2pR"
end

run_test("Dump adds count prefix for multiple identical pieces") do
  feen = "8/8/8/8/8/8/8/8 2P/3p C/c"
  position = Sashite::Feen.parse(feen)
  dumped = Sashite::Feen.dump(position)

  raise "Should have count prefix for pawns" unless dumped.include?("2P/3p")
end

# ============================================================================
# Field 3: Style-Turn Tests
# ============================================================================

run_test("Parse style-turn with active player first") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)
  styles = position.styles

  raise "Active style should be first player Chess" unless styles.active.to_s == "C"
  raise "Inactive style should be second player Chess" unless styles.inactive.to_s == "c"
end

run_test("Parse style-turn with active player second") do
  feen = "8/8/8/8/8/8/8/8 / c/C"
  position = Sashite::Feen.parse(feen)
  styles = position.styles

  raise "Active style should be second player Chess" unless styles.active.to_s == "c"
  raise "Inactive style should be first player Chess" unless styles.inactive.to_s == "C"
end

run_test("Parse cross-style game") do
  feen = "8/8/8/8/8/8/8/8 / C/m"
  position = Sashite::Feen.parse(feen)
  styles = position.styles

  raise "Active should be Chess" unless styles.active.to_s == "C"
  raise "Inactive should be Makruk" unless styles.inactive.to_s == "m"
end

run_test("Dump style-turn correctly") do
  feen = "8/8/8/8/8/8/8/8 / S/s"
  position = Sashite::Feen.parse(feen)
  dumped = Sashite::Feen.dump(position)

  raise "Should preserve style-turn" unless dumped.end_with?(" S/s")
end

# ============================================================================
# Error Handling Tests
# ============================================================================

run_test("Syntax error for wrong field count") do
  invalid_feen = "8/8/8/8/8/8/8/8 /"

  begin
    Sashite::Feen.parse(invalid_feen)
    raise "Should have raised Syntax error"
  rescue Sashite::Feen::Error::Syntax => e
    raise "Error message should mention field count" unless e.message.include?("3 space-separated fields")
  end
end

run_test("Syntax error for empty style field") do
  invalid_feen = "8/8/8/8/8/8/8/8 / /"

  begin
    Sashite::Feen.parse(invalid_feen)
    raise "Should have raised Syntax error"
  rescue Sashite::Feen::Error::Syntax => e
    raise "Error message should mention empty style" unless e.message.include?("cannot be empty")
  end
end

run_test("Syntax error for invalid character in rank") do
  invalid_feen = "8/8/8/8/8/8/8/X# / C/c"

  begin
    Sashite::Feen.parse(invalid_feen)
    raise "Should have raised Syntax error"
  rescue Sashite::Feen::Error::Syntax => e
    raise "Error message should mention expected letter" unless e.message == 'unexpected character "#" at position 1 in rank'
  end
end

run_test("Style error for invalid SIN") do
  invalid_feen = "8/8/8/8/8/8/8/8 / 1/2"

  begin
    Sashite::Feen.parse(invalid_feen)
    raise "Should have raised Style error"
  rescue Sashite::Feen::Error::Style => e
    raise "Error message should mention invalid SIN" unless e.message.include?("SIN")
  end
end

run_test("Count error for zero pieces") do
  invalid_feen = "8/8/8/8/8/8/8/8 0P/ C/c"

  begin
    Sashite::Feen.parse(invalid_feen)
    raise "Should have raised Count error"
  rescue Sashite::Feen::Error::Count => e
    raise "Error message should mention count" unless e.message.include?("at least 1")
  end
end

run_test("Count error for excessive count") do
  invalid_feen = "8/8/8/8/8/8/8/8 9999P/ C/c"

  begin
    Sashite::Feen.parse(invalid_feen)
    raise "Should have raised Count error"
  rescue Sashite::Feen::Error::Count => e
    raise "Error message should mention too large" unless e.message.include?("too large")
  end
end

run_test("All FEEN errors inherit from base Error class") do
  raise "Syntax should inherit from Error" unless Sashite::Feen::Error::Syntax < Sashite::Feen::Error
  raise "Piece should inherit from Error" unless Sashite::Feen::Error::Piece < Sashite::Feen::Error
  raise "Style should inherit from Error" unless Sashite::Feen::Error::Style < Sashite::Feen::Error
  raise "Count should inherit from Error" unless Sashite::Feen::Error::Count < Sashite::Feen::Error
  raise "Validation should inherit from Error" unless Sashite::Feen::Error::Validation < Sashite::Feen::Error
end

# ============================================================================
# Position Object Tests
# ============================================================================

run_test("Position object is immutable") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)

  raise "Position should be frozen" unless position.frozen?
  raise "Placement should be frozen" unless position.placement.frozen?
  raise "Hands should be frozen" unless position.hands.frozen?
  raise "Styles should be frozen" unless position.styles.frozen?
end

run_test("Position provides component access") do
  feen = "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R P/p C/c"
  position = Sashite::Feen.parse(feen)

  raise "Should have placement" unless position.respond_to?(:placement)
  raise "Should have hands" unless position.respond_to?(:hands)
  raise "Should have styles" unless position.respond_to?(:styles)

  raise "Placement should be Placement object" unless position.placement.is_a?(Sashite::Feen::Placement)
  raise "Hands should be Hands object" unless position.hands.is_a?(Sashite::Feen::Hands)
  raise "Styles should be Styles object" unless position.styles.is_a?(Sashite::Feen::Styles)
end

run_test("Position to_s returns canonical FEEN") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)

  raise "to_s should return FEEN string" unless position.to_s == feen
end

run_test("Position equality works correctly") do
  feen1 = "8/8/8/8/8/8/8/8 / C/c"
  feen2 = "8/8/8/8/8/8/8/8 / C/c"
  feen3 = "8/8/8/8/8/8/8/8 / c/C"

  position1 = Sashite::Feen.parse(feen1)
  position2 = Sashite::Feen.parse(feen2)
  position3 = Sashite::Feen.parse(feen3)

  raise "Identical positions should be equal" unless position1 == position2
  raise "Different positions should not be equal" if position1 == position3
end

run_test("Position hash is consistent") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position1 = Sashite::Feen.parse(feen)
  position2 = Sashite::Feen.parse(feen)

  raise "Equal positions should have same hash" unless position1.hash == position2.hash
end

# ============================================================================
# Placement Object Tests
# ============================================================================

run_test("Placement provides rank access") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)
  placement = position.placement

  raise "Should have ranks array" unless placement.ranks.is_a?(Array)
  raise "Ranks should be frozen" unless placement.ranks.frozen?
end

run_test("Placement stores dimension") do
  feen_2d = "8/8/8/8/8/8/8/8 / C/c"
  feen_3d = "5/5/5/5/5//5/5/5/5/5 / R/r"

  position_2d = Sashite::Feen.parse(feen_2d)
  position_3d = Sashite::Feen.parse(feen_3d)

  raise "2D board should have dimension 2" unless position_2d.placement.dimension == 2
  raise "3D board should have dimension 3" unless position_3d.placement.dimension == 3
end

run_test("Placement to_s returns piece placement field") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)
  placement_string = position.placement.to_s

  raise "Placement to_s should match field 1" unless placement_string == "8/8/8/8/8/8/8/8"
end

# ============================================================================
# Hands Object Tests
# ============================================================================

run_test("Hands provides player arrays") do
  feen = "8/8/8/8/8/8/8/8 2P/3p C/c"
  position = Sashite::Feen.parse(feen)
  hands = position.hands

  raise "Should have first_player array" unless hands.first_player.is_a?(Array)
  raise "Should have second_player array" unless hands.second_player.is_a?(Array)
  raise "Arrays should be frozen" unless hands.first_player.frozen? && hands.second_player.frozen?
end

run_test("Hands empty? method works") do
  feen_empty = "8/8/8/8/8/8/8/8 / C/c"
  feen_with_pieces = "8/8/8/8/8/8/8/8 P/ C/c"

  position_empty = Sashite::Feen.parse(feen_empty)
  position_with = Sashite::Feen.parse(feen_with_pieces)

  raise "Empty hands should return true" unless position_empty.hands.empty?
  raise "Non-empty hands should return false" if position_with.hands.empty?
end

run_test("Hands to_s returns pieces-in-hand field") do
  feen = "8/8/8/8/8/8/8/8 2P/p C/c"
  position = Sashite::Feen.parse(feen)
  hands_string = position.hands.to_s

  raise "Hands to_s should match field 2" unless hands_string == "2P/p"
end

# ============================================================================
# Styles Object Tests
# ============================================================================

run_test("Styles provides active and inactive access") do
  feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)
  styles = position.styles

  raise "Should have active style" unless styles.respond_to?(:active)
  raise "Should have inactive style" unless styles.respond_to?(:inactive)
  raise "Active should be SIN identifier" unless styles.active.to_s == "C"
  raise "Inactive should be SIN identifier" unless styles.inactive.to_s == "c"
end

run_test("Styles to_s returns style-turn field") do
  feen = "8/8/8/8/8/8/8/8 / S/s"
  position = Sashite::Feen.parse(feen)
  styles_string = position.styles.to_s

  raise "Styles to_s should match field 3" unless styles_string == "S/s"
end

# ============================================================================
# Practical Game Examples
# ============================================================================

run_test("Chess opening position - Ruy Lopez") do
  feen = "r1bqkbnr/+p+p+p+p1+p+p+p/2n5/1B2p3/4P3/5N2/+P+P+P+P1+P+P+P/RNBQK2R / c/C"
  position = Sashite::Feen.parse(feen)

  raise "Should parse complex chess position" unless position.is_a?(Sashite::Feen::Position)

  dumped = Sashite::Feen.dump(position)
  raise "Should round-trip correctly" unless dumped == feen
end

run_test("Shogi position with captured pieces") do
  feen = "lnsgkgsnl/1r5b1/pppp1pppp/9/4p4/9/PPPP1PPPP/1B5R1/LNSGKGSNL P/p s/S"
  position = Sashite::Feen.parse(feen)

  raise "Should parse shogi position" unless position.is_a?(Sashite::Feen::Position)
  raise "First player should have pawn in hand" unless position.hands.first_player.size == 1
  raise "Second player should have pawn in hand" unless position.hands.second_player.size == 1

  dumped = Sashite::Feen.dump(position)
  raise "Should round-trip correctly" unless dumped == feen
end

run_test("Cross-style Chess vs Makruk") do
  feen = "rnsmksnr/8/pppppppp/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/m"
  position = Sashite::Feen.parse(feen)

  raise "Should parse cross-style position" unless position.is_a?(Sashite::Feen::Position)
  raise "Active should be Chess" unless position.styles.active.to_s == "C"
  raise "Inactive should be Makruk" unless position.styles.inactive.to_s == "m"

  dumped = Sashite::Feen.dump(position)
  raise "Should round-trip correctly" unless dumped == feen
end

run_test("3D Raumschach starting position") do
  feen = "rnknr/+p+p+p+p+p/5/5/5//buqbu/+p+p+p+p+p/5/5/5//5/5/5/5/5//5/5/5/+P+P+P+P+P/BUQBU//5/5/5/+P+P+P+P+P/RNKNR / R/r"
  position = Sashite::Feen.parse(feen)

  raise "Should parse 3D position" unless position.is_a?(Sashite::Feen::Position)
  raise "Should have dimension 3" unless position.placement.dimension == 3

  dumped = Sashite::Feen.dump(position)

  raise "Should round-trip correctly: #{dumped.inspect}" unless dumped == feen
end

# ============================================================================
# Canonical Form Tests
# ============================================================================

run_test("Canonical form - consistent output") do
  # Same position should always produce same string
  feen = "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/c"

  position1 = Sashite::Feen.parse(feen)
  position2 = Sashite::Feen.parse(feen)

  dump1 = Sashite::Feen.dump(position1)
  dump2 = Sashite::Feen.dump(position2)

  raise "Same position should produce same dump" unless dump1 == dump2
end

run_test("Canonical form - pieces in hand sorted") do
  # Create position with unsorted pieces in original FEEN
  # Parser should accept any order, but dumper should output canonical order
  feen = "8/8/8/8/8/8/8/8 RPN2B/p C/c"
  position = Sashite::Feen.parse(feen)
  dumped = Sashite::Feen.dump(position)

  # Should be sorted: 2B (highest count first), then N, P, R alphabetically
  expected = "8/8/8/8/8/8/8/8 2BNPR/p C/c"
  raise "Pieces should be in canonical order" unless dumped == expected
end

# ============================================================================
# Edge Cases and Stress Tests
# ============================================================================

run_test("Edge case - single square board") do
  feen = "K / C/c"
  position = Sashite::Feen.parse(feen)

  raise "Should parse single square board" unless position.placement.ranks.size == 1
  raise "Should have one piece" unless position.placement.ranks[0].size == 1

  dumped = Sashite::Feen.dump(position)
  raise "Should round-trip correctly" unless dumped == feen
end

run_test("Edge case - very long rank") do
  # 20x1 board
  feen = "20 / C/c"
  position = Sashite::Feen.parse(feen)

  raise "Should parse long rank" unless position.placement.ranks[0].size == 20

  dumped = Sashite::Feen.dump(position)
  raise "Should dump as 20" unless dumped.start_with?("20 ")
end

run_test("Edge case - many pieces in hand") do
  feen = "8/8/8/8/8/8/8/8 20P10R5B/15p C/c"
  position = Sashite::Feen.parse(feen)

  raise "First player should have 35 pieces" unless position.hands.first_player.size == 35
  raise "Second player should have 15 pieces" unless position.hands.second_player.size == 15

  dumped = Sashite::Feen.dump(position)
  raise "Should preserve large counts" unless dumped.include?("20P")
end

run_test("Edge case - all piece types") do
  # Test with many different piece types
  feen = "ABCDEFGH/IJKLMNOP/QRSTUVWX/YZ6/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(feen)

  raise "Should parse all piece types" unless position.placement.ranks[0].size == 8

  dumped = Sashite::Feen.dump(position)
  raise "Should round-trip all types" unless dumped.start_with?("ABCDEFGH/")
end

run_test("Edge case - mixed state modifiers in hand") do
  feen = "8/8/8/8/8/8/8/8 +K-K+R-R+P-P/+k-k C/c"
  position = Sashite::Feen.parse(feen)

  first_pieces = position.hands.first_player
  raise "Should have 6 first player pieces" unless first_pieces.size == 6

  second_pieces = position.hands.second_player
  raise "Should have 2 second player pieces" unless second_pieces.size == 2
end

run_test("Edge case - multiple derivation markers") do
  feen = "K'Q'R'B'N'P'/k'q'r'b'n'p'/8/8/8/8/8/8 / C/s"
  position = Sashite::Feen.parse(feen)

  first_rank = position.placement.ranks[0]
  second_rank = position.placement.ranks[1]

  raise "All first rank pieces should be foreign" unless first_rank.all? { |p| p.to_s.end_with?("'") }
  raise "All second rank pieces should be foreign" unless second_rank.all? { |p| p.to_s.end_with?("'") }
end

# ============================================================================
# Integration Tests
# ============================================================================

run_test("Integration - parse, modify concept, dump") do
  # While objects are immutable, we can conceptually verify the structure
  original_feen = "8/8/8/8/8/8/8/8 / C/c"
  position = Sashite::Feen.parse(original_feen)

  # Verify we can access all components
  placement = position.placement
  hands = position.hands
  styles = position.styles

  raise "Should have valid placement" unless placement.ranks.size == 8
  raise "Should have empty hands" unless hands.empty?
  raise "Should have valid styles" unless styles.active.to_s == "C"

  # Dump should produce original
  dumped = Sashite::Feen.dump(position)
  raise "Should match original" unless dumped == original_feen
end

run_test("Integration - multiple positions in sequence") do
  positions = [
    "8/8/8/8/8/8/8/8 / C/c",
    "+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/c",
    "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL / S/s",
    "rnsmksnr/8/pppppppp/8/8/8/PPPPPPPP/RNSMKSNR / M/m"
  ].map { |feen| Sashite::Feen.parse(feen) }

  raise "Should parse all positions" unless positions.size == 4
  raise "All should be Position objects" unless positions.all? { |p| p.is_a?(Sashite::Feen::Position) }

  # All should dump correctly
  dumps = positions.map { |p| Sashite::Feen.dump(p) }
  raise "Should have 4 dumps" unless dumps.size == 4
end

run_test("Integration - complex cross-style with captures") do
  feen = "lnsgkgsnl/1r5b1/pppppppp/9/9/9/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R/LNSGKGSNL 2P'/p' C/s"
  position = Sashite::Feen.parse(feen)

  # Verify all components parsed correctly
  raise "Should have valid placement" unless position.placement.ranks.size == 9
  raise "Should have pieces in both hands" unless !position.hands.empty?
  raise "Should be cross-style" unless position.styles.active.to_s != position.styles.inactive.to_s.upcase

  # Verify foreign pieces in hand
  first_hand = position.hands.first_player
  raise "First player should have foreign pieces" unless first_hand.any? { |p| p.to_s.end_with?("'") }

  # Should round-trip
  dumped = Sashite::Feen.dump(position)
  raise "Should round-trip complex position" unless dumped == feen
end

puts
puts "All FEEN tests passed!"
puts
