# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../lib/feen/dumper/piece_placement"
require_relative "../../../lib/feen/piece"

module Feen
  module Dumper
    class PiecePlacementTest < Minitest::Test
      def setup
        # Create pieces for testing
        @white_king = Feen::Piece.new("K")
        @white_king_castling = Feen::Piece.new("K", suffix: "=")
        @white_king_kingside = Feen::Piece.new("K", suffix: ">")
        @white_king_queenside = Feen::Piece.new("K", suffix: "<")
        @white_queen = Feen::Piece.new("Q")
        @white_rook = Feen::Piece.new("R")
        @white_bishop = Feen::Piece.new("B")
        @white_knight = Feen::Piece.new("N")
        @white_pawn = Feen::Piece.new("P")
        @white_pawn_ep_right = Feen::Piece.new("P", suffix: ">")
        @white_pawn_ep_left = Feen::Piece.new("P", suffix: "<")

        @black_king = Feen::Piece.new("k")
        @black_king_castling = Feen::Piece.new("k", suffix: "=")
        @black_queen = Feen::Piece.new("q")
        @black_rook = Feen::Piece.new("r")
        @black_bishop = Feen::Piece.new("b")
        @black_knight = Feen::Piece.new("n")
        @black_pawn = Feen::Piece.new("p")

        @shogi_promoted_pawn = Feen::Piece.new("P", prefix: "+")
        @shogi_promoted_bishop = Feen::Piece.new("B", prefix: "+")
      end

      def test_empty_board
        # Test an empty 8x8 board
        shape = [8, 8]
        contents = Array.new(64) # All nil (empty)
        result = PiecePlacement.dump(shape, contents)
        assert_equal "8/8/8/8/8/8/8/8", result
      end

      def test_standard_chess_position
        # Test standard chess initial position
        shape = [8, 8]
        contents = Array.new(64)

        # Set up white pieces (bottom row, indexes 0-7)
        contents[0] = @white_rook
        contents[1] = @white_knight
        contents[2] = @white_bishop
        contents[3] = @white_queen
        contents[4] = @white_king_castling
        contents[5] = @white_bishop
        contents[6] = @white_knight
        contents[7] = @white_rook

        # Set up white pawns (second row, indexes 8-15)
        8.times { |i| contents[8 + i] = @white_pawn }

        # Set up black pawns (seventh row, indexes 48-55)
        8.times { |i| contents[48 + i] = @black_pawn }

        # Set up black pieces (top row, indexes 56-63)
        contents[56] = @black_rook
        contents[57] = @black_knight
        contents[58] = @black_bishop
        contents[59] = @black_queen
        contents[60] = @black_king_castling
        contents[61] = @black_bishop
        contents[62] = @black_knight
        contents[63] = @black_rook

        result = PiecePlacement.dump(shape, contents)
        assert_equal "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR", result
      end

      def test_chess_position_after_e4
        # Test chess position after first move e2-e4
        shape = [8, 8]
        contents = Array.new(64)

        # Set up white pieces (bottom row, indexes 0-7)
        contents[0] = @white_rook     # a1
        contents[1] = @white_knight   # b1
        contents[2] = @white_bishop   # c1
        contents[3] = @white_queen    # d1
        contents[4] = @white_king_castling # e1
        contents[5] = @white_bishop   # f1
        contents[6] = @white_knight   # g1
        contents[7] = @white_rook     # h1

        # Set up white pawns (second row, indexes 8-15) with e-pawn moved
        contents[8] = @white_pawn     # a2
        contents[9] = @white_pawn     # b2
        contents[10] = @white_pawn    # c2
        contents[11] = @white_pawn    # d2
        # e2 is now empty (index 12)
        contents[13] = @white_pawn    # f2
        contents[14] = @white_pawn    # g2
        contents[15] = @white_pawn    # h2

        # Place e-pawn on e4 (index 28)
        contents[28] = @white_pawn # e4

        # Set up black pawns (seventh row, indexes 48-55)
        contents[48] = @black_pawn    # a7
        contents[49] = @black_pawn    # b7
        contents[50] = @black_pawn    # c7
        contents[51] = @black_pawn    # d7
        contents[52] = @black_pawn    # e7
        contents[53] = @black_pawn    # f7
        contents[54] = @black_pawn    # g7
        contents[55] = @black_pawn    # h7

        # Set up black pieces (top row, indexes 56-63)
        contents[56] = @black_rook    # a8
        contents[57] = @black_knight  # b8
        contents[58] = @black_bishop  # c8
        contents[59] = @black_queen   # d8
        contents[60] = @black_king_castling # e8
        contents[61] = @black_bishop  # f8
        contents[62] = @black_knight  # g8
        contents[63] = @black_rook    # h8

        result = PiecePlacement.dump(shape, contents)
        assert_equal "rnbqk=bnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQK=BNR", result
      end

      def test_board_with_en_passant
        # Test position with en passant possibilities
        shape = [8, 8]
        contents = Array.new(64)

        # Using a zero-based index where a1=0, the board looks like:
        # 56 57 58 59 60 61 62 63  (a8-h8)
        # 48 49 50 51 52 53 54 55  (a7-h7)
        # 40 41 42 43 44 45 46 47  (a6-h6)
        # 32 33 34 35 36 37 38 39  (a5-h5)
        # 24 25 26 27 28 29 30 31  (a4-h4)
        # 16 17 18 19 20 21 22 23  (a3-h3)
        #  8  9 10 11 12 13 14 15  (a2-h2)
        #  0  1  2  3  4  5  6  7  (a1-h1)
        #  a  b  c  d  e  f  g  h

        # White pawn that can be captured en passant from the left
        # This represents a white pawn that has just moved from d2 to d4
        contents[27] = @white_pawn_ep_left # d4 (4th rank, 4th file)

        # Black pawn that can capture via en passant
        # This represents a black pawn on c4, which can capture the white pawn en passant
        contents[26] = @black_pawn # c4 (4th rank, 3rd file)

        result = PiecePlacement.dump(shape, contents)

        # The expected output for a valid en passant position:
        # - The pawns are on the 4th rank
        # - There are 2 empty squares at the beginning of the 4th rank (a4-b4)
        # - Then black pawn on c4, white pawn on d4 with en passant marker
        # - Then 4 empty squares (e4-h4)
        assert_equal "8/8/8/8/2pP<4/8/8/8", result
      end

      def test_sparse_board
        # Test a sparse board with few pieces
        shape = [8, 8]
        contents = Array.new(64)

        # Place just a few pieces
        contents[0] = @white_king   # a1
        contents[63] = @black_king  # h8
        contents[27] = @white_queen # d4

        result = PiecePlacement.dump(shape, contents)
        assert_equal "7k/8/8/8/3Q4/8/8/K7", result
      end

      def test_3d_board
        # Test a 3D board (e.g., 3D chess) - 2 levels, 4x4 each
        shape = [2, 4, 4]
        contents = Array.new(32, nil)

        # Place some pieces on the first level
        contents[0] = @white_king
        contents[3] = @white_queen

        # Place some pieces on the second level
        contents[16] = @black_king
        contents[19] = @black_queen

        result = PiecePlacement.dump(shape, contents)
        assert_equal "k2q/4/4/4//K2Q/4/4/4", result
      end

      def test_shogi_pieces
        # Test Shogi pieces with promotion prefixes
        shape = [9, 9]
        contents = Array.new(81, nil)

        # Using a zero-based index where bottom-left = 0, the board looks like:
        # 72 73 74 75 76 77 78 79 80  (a9-i9) 9th rank (top)
        # 63 64 65 66 67 68 69 70 71  (a8-i8) 8th rank
        # 54 55 56 57 58 59 60 61 62  (a7-i7) 7th rank
        # 45 46 47 48 49 50 51 52 53  (a6-i6) 6th rank
        # 36 37 38 39 40 41 42 43 44  (a5-i5) 5th rank
        # 27 28 29 30 31 32 33 34 35  (a4-i4) 4th rank
        # 18 19 20 21 22 23 24 25 26  (a3-i3) 3rd rank
        #  9 10 11 12 13 14 15 16 17  (a2-i2) 2nd rank
        #  0  1  2  3  4  5  6  7  8  (a1-i1) 1st rank (bottom)
        #  a  b  c  d  e  f  g  h  i

        # Diagram showing the expected position:
        # 9th rank (top)    | . . . . . . . . . |
        # 8th rank          | . . . . . . . . . |
        # 7th rank          | . . . . . . . . . |
        # 6th rank          | . . . . . . . . . |
        # 5th rank          | . . . . +P . . . . | (+P = promoted pawn)
        # 4th rank          | . . . . . . . . . |
        # 3rd rank          | . . . . . +B . . . | (+B = promoted bishop)
        # 2nd rank          | . . . . . . . . . |
        # 1st rank (bottom) | . . . . . . . . . |
        #                     a b c d e f g h i

        # Place some promoted pieces
        contents[40] = @shogi_promoted_pawn   # Promoted pawn at index 40 = e5 (5th rank, 5th file)
        contents[23] = @shogi_promoted_bishop # Promoted bishop at index 23 = f3 (3rd rank, 6th file)

        result = PiecePlacement.dump(shape, contents)

        # In FEEN notation:
        # - Ranks are separated by '/'
        # - Ranks are ordered from top (9th) to bottom (1st)
        # - The promoted pawn +P is on the 5th rank, at position 5 (with 4 empty squares before)
        # - The promoted bishop +B is on the 3rd rank, at position 6 (with 5 empty squares before)
        assert_equal "9/9/9/9/4+P4/9/5+B3/9/9", result
      end

      def test_asymmetric_board
        # Test an asymmetric board (non-square)
        shape = [3, 8]
        contents = Array.new(24, nil)

        # Add some pieces
        contents[0] = @white_rook
        contents[7] = @white_rook
        contents[8] = @black_pawn
        contents[15] = @black_pawn
        contents[16] = @black_king
        contents[23] = @white_king

        result = PiecePlacement.dump(shape, contents)
        assert_equal "k6K/p6p/R6R", result
      end

      def test_single_row_board
        # Test a 1D board (single row)
        shape = [8]
        contents = [@white_king, nil, nil, @black_pawn, nil, @black_king, nil, @white_queen]

        result = PiecePlacement.dump(shape, contents)
        assert_equal "K2p1k1Q", result
      end

      def test_empty_contents
        # Test empty contents array
        shape = [0, 0]
        contents = []

        result = PiecePlacement.dump(shape, contents)
        assert_equal "", result
      end

      def test_complex_4d_board
        # Test a 4D board - 2x2x2x2 hypercube
        shape = [2, 2, 2, 2]
        contents = Array.new(16, nil)

        # Place some pieces
        contents[0] = @white_king
        contents[15] = @black_king

        result = PiecePlacement.dump(shape, contents)
        assert_equal "2/2//2/1k///K1/2//2/2", result
      end

      def test_invalid_shape
        # Test invalid shape
        shape = "not an array"
        contents = []

        assert_raises(ArgumentError) do
          PiecePlacement.dump(shape, contents)
        end
      end

      def test_invalid_shape_dimensions
        # Test shape with invalid dimensions
        shape = [8, -3]
        contents = Array.new(24, nil)

        assert_raises(ArgumentError) do
          PiecePlacement.dump(shape, contents)
        end
      end

      def test_contents_size_mismatch
        # Test when contents size doesn't match shape
        shape = [8, 8]
        contents = Array.new(60, nil) # Should be 64

        assert_raises(ArgumentError) do
          PiecePlacement.dump(shape, contents)
        end
      end

      def test_invalid_content_type
        # Test with invalid content type
        shape = [8, 8]
        contents = Array.new(64)
        contents[0] = "not a piece or nil"

        assert_raises(ArgumentError) do
          PiecePlacement.dump(shape, contents)
        end
      end

      def test_zero_dimensional_board
        # Test a board with zero dimensions
        shape = []
        contents = []

        result = PiecePlacement.dump(shape, contents)
        assert_equal "", result
      end

      def test_custom_board_size
        # Test a custom size board (5x5)
        shape = [5, 5]
        contents = Array.new(25, nil)

        # Place some pieces
        contents[0] = @white_king   # a1
        contents[4] = @white_queen  # e1
        contents[20] = @black_king  # a5
        contents[24] = @black_queen # e5

        result = PiecePlacement.dump(shape, contents)
        assert_equal "k3q/5/5/5/K3Q", result
      end

      def test_board_with_all_piece_types
        # Test a board with all types of pieces and modifiers
        shape = [3, 8]
        contents = Array.new(24, nil)

        # Row 1: Basic pieces
        contents[0] = @white_pawn
        contents[1] = @white_knight
        contents[2] = @white_bishop
        contents[3] = @white_rook
        contents[4] = @white_queen
        contents[5] = @white_king
        contents[6] = @black_pawn
        contents[7] = @black_king

        # Row 2: Pieces with suffixes
        contents[8] = @white_king_castling
        contents[9] = @white_king_kingside
        contents[10] = @white_king_queenside
        contents[11] = @white_pawn_ep_left
        contents[12] = @white_pawn_ep_right
        contents[13] = @black_king_castling
        contents[14] = nil
        contents[15] = nil

        # Row 3: Pieces with prefixes
        contents[16] = @shogi_promoted_pawn
        contents[17] = @shogi_promoted_bishop
        contents[18] = nil
        contents[19] = nil
        contents[20] = nil
        contents[21] = nil
        contents[22] = nil
        contents[23] = nil

        result = PiecePlacement.dump(shape, contents)
        assert_equal "+P+B6/K=K>K<P<P>k=2/PNBRQKpk", result
      end
    end
  end
end
