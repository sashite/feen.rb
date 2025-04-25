# frozen_string_literal: true

require_relative "../spec_helper"
require_relative "../../lib/feen/sanitizer"

RSpec.describe Feen::Sanitizer do
  describe ".clean_fen" do
    context "with invalid input format" do
      it "returns the original string when fewer than 4 parts are present" do
        invalid_fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w"
        expect(Feen::Sanitizer.clean_fen(invalid_fen)).to eq(invalid_fen)
      end

      it "handles empty strings" do
        expect(Feen::Sanitizer.clean_fen("")).to eq("")
      end
    end

    context "with castling rights" do
      it "preserves all castling rights when valid" do
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(fen)
      end

      it "removes white kingside castling when king is not in place" do
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQ1BNR w KQkq - 0 1"
        expected = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQ1BNR w kq - 0 1"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(expected)
      end

      it "removes white queenside castling when king is not in place" do
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQ1BNR w KQkq - 0 1"
        expected = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQ1BNR w kq - 0 1"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(expected)
      end

      it "removes black kingside castling when king is not in place" do
        fen = "rnbq1bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        expected = "rnbq1bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQ - 0 1"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(expected)
      end

      it "removes black queenside castling when king is not in place" do
        fen = "rnbq1bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        expected = "rnbq1bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQ - 0 1"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(expected)
      end

      it "removes white kingside castling when rook is not in place" do
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBN1 w KQkq - 0 1"
        expected = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBN1 w Qkq - 0 1"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(expected)
      end

      it "removes white queenside castling when rook is not in place" do
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/1NBQKBNR w KQkq - 0 1"
        expected = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/1NBQKBNR w Kkq - 0 1"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(expected)
      end

      it "removes black kingside castling when rook is not in place" do
        fen = "rnbqkbn1/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        expected = "rnbqkbn1/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQq - 0 1"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(expected)
      end

      it "removes black queenside castling when rook is not in place" do
        fen = "1nbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        expected = "1nbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQk - 0 1"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(expected)
      end

      it 'sets castling to "-" when all castling rights are invalid' do
        fen = "rnbq1bn1/pppppppp/8/8/8/8/PPPPPPPP/1NBQ1BN1 w KQkq - 0 1"
        expected = "rnbq1bn1/pppppppp/8/8/8/8/PPPPPPPP/1NBQ1BN1 w - - 0 1"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(expected)
      end
    end

    context "with en passant targets" do
      it "preserves valid en passant target for white" do
        # Black's pawn just moved from e7 to e5, allowing white's pawn on d5 to capture en passant
        fen = "rnbqkbnr/pppp1ppp/8/3Pp3/8/8/PPP1PPPP/RNBQKBNR w KQkq e6 0 2"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(fen)
      end

      it "preserves valid en passant target for black" do
        # White's pawn just moved from e2 to e4, allowing black's pawn on d4 to capture en passant
        fen = "rnbqkbnr/ppp1pppp/8/8/3pP3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 2"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(fen)
      end

      it "removes en passant target when no capturing pawn exists for white" do
        # No white pawn adjacent to capture the black pawn that moved
        fen = "rnbqkbnr/pppp1ppp/8/4p3/8/8/PPPPPPPP/RNBQKBNR w KQkq e6 0 2"
        expected = "rnbqkbnr/pppp1ppp/8/4p3/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 2"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(expected)
      end

      it "removes en passant target when no capturing pawn exists for black" do
        # No black pawn adjacent to capture the white pawn that moved
        fen = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"
        expected = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq - 0 1"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(expected)
      end

      it "removes en passant target when target rank is invalid" do
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq e7 0 1"
        expected = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(expected)
      end

      it "removes en passant target when file is out of bounds" do
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq i6 0 1"
        expected = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(expected)
      end
    end

    context "with complex positions" do
      it "correctly handles a position after several moves" do
        # Position after 1.e4 e5 2.Nf3 Nc6 3.Bb5
        fen = "r1bqkbnr/pppp1ppp/2n5/1B2p3/4P3/5N2/PPPP1PPP/RNBQK2R b KQkq - 3 3"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(fen)
      end

      it "handles positions with captured pieces" do
        # Position with several captures
        fen = "r1bqkb1r/pppp1ppp/2n2n2/4p3/3PP3/5N2/PPP2PPP/RNBQKB1R w KQkq - 0 4"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(fen)
      end

      it "correctly handles positions where castling is still possible but one rook moved" do
        # White queenside rook moved but kingside castling still possible
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/R3KBNR w Kkq - 0 1"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(fen)
      end
    end

    context "with additional parts in FEN string" do
      it "preserves halfmove clock and fullmove number" do
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 10 5"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(fen)
      end

      it "preserves custom extensions beyond the standard FEN format" do
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1 custom data"
        expect(Feen::Sanitizer.clean_fen(fen)).to eq(fen)
      end
    end
  end
end
