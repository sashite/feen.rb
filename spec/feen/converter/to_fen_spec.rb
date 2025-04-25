# frozen_string_literal: true

require_relative "../../spec_helper"
require_relative "../../../lib/feen/converter/to_fen"

RSpec.describe Feen::Converter::ToFen do
  describe ".call" do
    # Tests for standard initial position
    it "converts the standard starting position" do
      feen = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR CHESS/chess -"
      fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

      expect(described_class.call(feen)).to eq(fen)
    end

    # Tests for active color
    it "handles black's turn correctly" do
      feen = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR chess/CHESS -"
      fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 0 1"

      expect(described_class.call(feen)).to eq(fen)
    end

    # Tests for various castling rights
    context "with different castling rights" do
      it "handles kings with full castling rights" do
        feen = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR CHESS/chess -"
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

        expect(described_class.call(feen)).to eq(fen)
      end

      it "handles white king with kingside castling rights only" do
        feen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK>BNR CHESS/chess -"
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w K - 0 1"

        expect(described_class.call(feen)).to eq(fen)
      end

      it "handles white king with queenside castling rights only" do
        feen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK<BNR CHESS/chess -"
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w Q - 0 1"

        expect(described_class.call(feen)).to eq(fen)
      end

      it "handles black king with kingside castling rights only" do
        feen = "rnbqk>bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR CHESS/chess -"
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w k - 0 1"

        expect(described_class.call(feen)).to eq(fen)
      end

      it "handles black king with queenside castling rights only" do
        feen = "rnbqk<bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR CHESS/chess -"
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w q - 0 1"

        expect(described_class.call(feen)).to eq(fen)
      end

      it "handles no castling rights" do
        feen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR CHESS/chess -"
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w - - 0 1"

        expect(described_class.call(feen)).to eq(fen)
      end

      it "handles mixed castling rights combinations" do
        feen = "rnbqk<bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK>BNR CHESS/chess -"
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w Kq - 0 1"

        expect(described_class.call(feen)).to eq(fen)
      end
    end

    # Tests for en passant
    context "with en passant possibility" do
      it "handles white pawn with en passant potential on e-file" do
        # The FEEN shows a white pawn on e4 that can be captured en passant from the left
        # This means a black pawn on d4 could capture it by moving to e3
        # In FEN, this should be represented with an en passant target on e3
        feen = "rnbqk=bnr/pppp1ppp/8/8/3pP<2/8/PPPP1PPP/RNBQK=BNR CHESS/chess -"
        fen = "rnbqkbnr/pppp1ppp/8/8/3pP2/8/PPPP1PPP/RNBQKBNR w KQkq e3 0 1"

        expect(described_class.call(feen)).to eq(fen)
      end

      it "handles black pawn with en passant potential on d-file" do
        # The FEEN shows a black pawn on d5 that can be captured en passant from the right
        # This means a white pawn on e5 could capture it by moving to d6
        # In FEN, this should be represented with an en passant target on d6
        feen = "rnbqk=bnr/ppp1pppp/8/3p>P2/8/8/PPPP1PPP/RNBQK=BNR chess/CHESS -"
        fen = "rnbqkbnr/ppp1pppp/8/3pP2/8/8/PPPP1PPP/RNBQKBNR b KQkq d6 0 1"

        expect(described_class.call(feen)).to eq(fen)
      end

      it "raises an exception for multiple en passant markers" do
        # An illegal position with multiple en passant markers
        feen = "rnbqk=bnr/pppppppp/8/8/2P<1P<2/8/PP1P1PPP/RNBQK=BNR CHESS/chess -"

        expect do
          described_class.call(feen)
        end.to raise_exception(ArgumentError)
      end
    end

    # Tests for more complex positions
    context "with complex positions" do
      it "handles a complex middle game position" do
        feen = "r1bqk=b1r/p2ppppp/2n2n2/1pp5/4P3/1B3N2/PPPP1PPP/RNBQK=1R CHESS/chess -"
        fen = "r1bqkb1r/p2ppppp/2n2n2/1pp5/4P3/1B3N2/PPPP1PPP/RNBQK1R w KQkq - 0 1"

        expect(described_class.call(feen)).to eq(fen)
      end

      it "handles a position with no castling rights" do
        feen = "r1bqkb1r/p2ppppp/2n2n2/1pp5/4P3/1B3N2/PPPP1PPP/RNBQK1R CHESS/chess -"
        fen = "r1bqkb1r/p2ppppp/2n2n2/1pp5/4P3/1B3N2/PPPP1PPP/RNBQK1R w - - 0 1"

        expect(described_class.call(feen)).to eq(fen)
      end

      it "handles an endgame position with few pieces" do
        feen = "4k3/8/8/8/8/8/4P3/4K3 CHESS/chess -"
        fen = "4k3/8/8/8/8/8/4P3/4K3 w - - 0 1"

        expect(described_class.call(feen)).to eq(fen)
      end
    end

    # Tests for edge cases and errors
    context "with edge case inputs" do
      it "raises an exception for an empty string" do
        expect { described_class.call("") }.to raise_exception(ArgumentError)
      end

      it "raises an exception for a non-string object" do
        expect { described_class.call(nil) }.to raise_exception(ArgumentError)
      end

      it "raises an exception for an incorrect number of fields" do
        expect { described_class.call("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR CHESS/chess") }.to raise_exception(ArgumentError)
      end

      it "raises an exception for a non-chess game type" do
        expect { described_class.call("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR SHOGI/shogi -") }.to raise_exception(ArgumentError)
      end
    end

    # Tests for method functionality
    describe ".extract_castling_rights" do
      it "extracts full castling rights correctly" do
        piece_placement = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR"
        expected_castling = "KQkq"

        expect(described_class.extract_castling_rights(piece_placement)).to eq(expected_castling)
      end

      it "extracts partial castling rights correctly" do
        piece_placement = "rnbqk>bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK<BNR"
        expected_castling = "Qk"

        expect(described_class.extract_castling_rights(piece_placement)).to eq(expected_castling)
      end

      it "returns '-' for no castling rights" do
        piece_placement = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
        expected_castling = "-"

        expect(described_class.extract_castling_rights(piece_placement)).to eq(expected_castling)
      end
    end

    describe ".extract_en_passant" do
      it "extracts en passant target for white pawn correctly" do
        # White pawn on d4 that can be captured en passant by a black pawn on c4
        # The white pawn has just moved from d2 to d4
        piece_placement = "rnbqk=bnr/pppppppp/8/8/2pP<4/8/PPP1PPPP/RNBQK=BNR"
        expected_en_passant = "d3"

        expect(described_class.extract_en_passant(piece_placement)).to eq(expected_en_passant)
      end

      it "extracts en passant target for black pawn correctly" do
        # Black pawn on d5 that can be captured en passant by a white pawn on e5
        # The black pawn has just moved from d7 to d5
        piece_placement = "rnbqk=bnr/ppp1pppp/8/3p>P3/8/8/PPPP1PPP/RNBQK=BNR"
        expected_en_passant = "d6"

        expect(described_class.extract_en_passant(piece_placement)).to eq(expected_en_passant)
      end

      it "returns '-' when no en passant target is available" do
        # Initial position, no en passant capture possibility
        piece_placement = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR"
        expected_en_passant = "-"

        expect(described_class.extract_en_passant(piece_placement)).to eq(expected_en_passant)
      end
    end
  end
end
