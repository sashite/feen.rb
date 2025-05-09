# frozen_string_literal: true

require_relative "../lib/feen"

# File: test/test_feen.rb

# --- Test for basic module functionality ---

# --- Test 1: Round-trip parsing and dumping ---
# This tests that a FEEN string can be parsed and then dumped back to the same string
feen_string = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR - CHESS/chess"
parsed = Feen.parse(feen_string)
dumped = Feen.dump(
  piece_placement: parsed[:piece_placement],
  pieces_in_hand: parsed[:pieces_in_hand],
  games_turn: parsed[:games_turn]
)
raise "Test 1 failed: Round-trip parsing and dumping does not match" unless dumped == feen_string

# --- Test 2: FEN to FEEN conversion ---
fen_string = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
feen_string = Feen.from_fen(fen_string)
expected = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR - CHESS/chess"
raise "Test 2 failed: FEN to FEEN conversion mismatch" unless feen_string == expected

# --- Test 3: FEEN to FEN conversion ---
feen_string = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR - CHESS/chess"
fen_string = Feen.to_fen(feen_string)
expected = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
raise "Test 3 failed: FEEN to FEN conversion mismatch" unless fen_string == expected

# --- Test 4: Complete roundtrip FEN -> FEEN -> FEN ---
fen_string = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
feen_string = Feen.from_fen(fen_string)
fen_result = Feen.to_fen(feen_string)
raise "Test 4 failed: FEN -> FEEN -> FEN roundtrip mismatch" unless fen_result == fen_string

# --- Test 5: Validation of valid FEEN string ---
feen_string = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR - CHESS/chess"
raise "Test 5 failed: Valid FEEN string not recognized" unless Feen.valid?(feen_string)

# --- Test 6: Validation of invalid FEEN string ---
invalid_feen = "invalid feen string"
raise "Test 6 failed: Invalid FEEN string incorrectly recognized as valid" if Feen.valid?(invalid_feen)

# --- Test 7: Parsing Shogi position with pieces in hand ---
feen_string = "lnsgk2nl/1r4gs1/p1pppp1pp/1p4p2/7P1/2P6/PP1PPPP1P/1SG4R1/LN2KGSNL Bb SHOGI/shogi"
result = Feen.parse(feen_string)
expected_pieces_in_hand = ["B", "b"]
raise "Test 7 failed: Pieces in hand not parsed correctly" unless result[:pieces_in_hand] == expected_pieces_in_hand

# --- Test 8: Parsing and dumping 3D position ---
feen_string = "rnb/qkp//PR1/1KQ - FOO/bar"
parsed = Feen.parse(feen_string)
dumped = Feen.dump(
  piece_placement: parsed[:piece_placement],
  pieces_in_hand: parsed[:pieces_in_hand],
  games_turn: parsed[:games_turn]
)
raise "Test 8 failed: 3D position parsing and dumping does not match" unless dumped == feen_string

# --- Test 9: Different game types ---
feen_string = "rheagaehr/9/1c5c1/s1s1s1s1s/9/9/S1S1S1S1S/1C5C1/9/RHEAGAEHR - XIANGQI/xiangqi"
parsed = Feen.parse(feen_string)
expected_games_turn = ["XIANGQI", "xiangqi"]
raise "Test 9 failed: Games turn not parsed correctly" unless parsed[:games_turn] == expected_games_turn

# --- Test 10: FEN with castling rights ---
fen_string = "r3k2r/pppppppp/8/8/8/8/PPPPPPPP/R3K2R w KQkq - 0 1"
feen_string = Feen.from_fen(fen_string)
result = Feen.parse(feen_string)
# Check if kings have castling markers
white_king_row = result[:piece_placement][7]
black_king_row = result[:piece_placement][0]
white_king_pos = white_king_row.find_index { |p| p == "K=" || p == "K<" || p == "K>" || p == "K" }
black_king_pos = black_king_row.find_index { |p| p == "k=" || p == "k<" || p == "k>" || p == "k" }

raise "Test 10a failed: White king not found" unless white_king_pos
raise "Test 10b failed: Black king not found" unless black_king_pos
raise "Test 10c failed: White king does not have castling marker" unless white_king_row[white_king_pos] == "K="
raise "Test 10d failed: Black king does not have castling marker" unless black_king_row[black_king_pos] == "k="

# --- Test 11: FEN with en passant ---
fen_string = "rnbqkbnr/ppp1pppp/8/3pP3/8/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 2"
feen_string = Feen.from_fen(fen_string)
result = Feen.parse(feen_string)
# Check if pawn has en passant marker
pawn_row = result[:piece_placement][3] # 4th rank
pawn_pos = pawn_row.find_index { |p| p == "P<" || p == "P>" || p == "+P" || p == "-P" || p == "P" }

raise "Test 11a failed: Pawn not found" unless pawn_pos
raise "Test 11b failed: Pawn does not have en passant marker" unless pawn_row[pawn_pos].include?("<") || pawn_row[pawn_pos].include?(">")

# --- Test 12: Edge cases ---
# Empty board
feen_string = "8/8/8/8/8/8/8/8 - CHESS/chess"
parsed = Feen.parse(feen_string)
dumped = Feen.dump(
  piece_placement: parsed[:piece_placement],
  pieces_in_hand: parsed[:pieces_in_hand],
  games_turn: parsed[:games_turn]
)
raise "Test 12 failed: Empty board parsing and dumping does not match" unless dumped == feen_string

# --- Test 13: Error cases ---
# Invalid FEN string
begin
  Feen.from_fen("invalid fen string")
  raise "Test 13a failed: Should have raised ArgumentError for invalid FEN string"
rescue ArgumentError
  # Expected behavior
end

# Invalid FEEN string
begin
  Feen.to_fen("invalid feen string")
  raise "Test 13b failed: Should have raised ArgumentError for invalid FEEN string"
rescue ArgumentError
  # Expected behavior
end

# --- Test 14: FEEN with non-chess games (not convertible to FEN) ---
feen_string = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL - SHOGI/shogi"
begin
  Feen.to_fen(feen_string)
  raise "Test 14 failed: Should have raised ArgumentError for FEEN with non-chess format"
rescue ArgumentError
  # Expected behavior
end

# --- Test 15: Modified pieces with prefixes/suffixes ---
feen_string = "rnbqk<bnr/pppppppp/8/4+P3/8/8/PPPP1PPP/RNBQK>BNR - CHESS/chess"
parsed = Feen.parse(feen_string)
modified_pawn = parsed[:piece_placement][3][4] # 5th rank, 5th file
white_king = parsed[:piece_placement][7][4] # 1st rank, 5th file
black_king = parsed[:piece_placement][0][4] # 8th rank, 5th file

raise "Test 15a failed: Modified pawn not correctly parsed" unless modified_pawn == "+P"
raise "Test 15b failed: White king castling rights not correctly parsed" unless white_king == "K>"
raise "Test 15c failed: Black king castling rights not correctly parsed" unless black_king == "k<"

puts "All tests passed successfully!"
