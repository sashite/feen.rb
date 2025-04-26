# frozen_string_literal: true

require_relative "../../spec_helper"
require_relative "../../../lib/feen/converter/from_fen"

RSpec.describe Feen::Converter::FromFen do
  describe ".call" do
    # Tests for standard initial position
    it "converts the standard starting position" do
      fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
      feen = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR CHESS/chess -"

      expect(described_class.call(fen)).to eq(feen)
    end

    # Tests for active color
    it "handles black's turn correctly" do
      fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 0 1"
      feen = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR chess/CHESS -"

      expect(described_class.call(fen)).to eq(feen)
    end

    # Tests for various castling rights
    context "with different castling rights" do
      it "handles white king only castling rights (K side)" do
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w K - 0 1"
        feen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK>BNR CHESS/chess -"

        expect(described_class.call(fen)).to eq(feen)
      end

      it "handles white king only castling rights (Q side)" do
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w Q - 0 1"
        feen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK<BNR CHESS/chess -"

        expect(described_class.call(fen)).to eq(feen)
      end

      it "handles black king only castling rights (k side)" do
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w k - 0 1"
        feen = "rnbqk>bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR CHESS/chess -"

        expect(described_class.call(fen)).to eq(feen)
      end

      it "handles black king only castling rights (q side)" do
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w q - 0 1"
        feen = "rnbqk<bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR CHESS/chess -"

        expect(described_class.call(fen)).to eq(feen)
      end

      it "handles no castling rights" do
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w - - 0 1"
        feen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR CHESS/chess -"

        expect(described_class.call(fen)).to eq(feen)
      end

      it "handles mixed castling rights combinations" do
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w Kq - 0 1"
        feen = "rnbqk<bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK>BNR CHESS/chess -"

        expect(described_class.call(fen)).to eq(feen)
      end
    end

    # Tests for en passant
    context "with en passant possibility" do
      it "handles en passant for white pawns" do
        # Position where white pawn at d5 can capture black pawn that just moved to e5
        fen = "rnbqkbnr/pppp1ppp/8/3Pp3/8/8/PPP1PPPP/RNBQKBNR w KQkq e6 0 2"
        feen = "rnbqk=bnr/pppp1ppp/8/3Pp3/8/8/PPP1PPPP/RNBQK=BNR CHESS/chess -"

        expect(described_class.call(fen)).to eq(feen)
      end

      it "handles en passant for black pawns" do
        # Position where black pawn at e4 can capture white pawn that just moved to d4
        fen = "rnbqkbnr/ppp1pppp/8/8/3Pp3/8/PPP1PPPP/RNBQKBNR b KQkq d3 0 2"
        feen = "rnbqk=bnr/ppp1pppp/8/8/3Pp3/8/PPP1PPPP/RNBQK=BNR chess/CHESS -"

        expect(described_class.call(fen)).to eq(feen)
      end

      it "handles no en passant properly" do
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        feen = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR CHESS/chess -"

        expect(described_class.call(fen)).to eq(feen)
      end
    end

    # Tests for more complex positions
    context "with complex positions" do
      it "handles a complex middle game position" do
        fen = "r1bqkbnr/pp1ppppp/2n5/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 2 3"
        feen = "r1bqk=bnr/pp1ppppp/2n5/2p5/4P3/5N2/PPPP1PPP/RNBQK=B1R CHESS/chess -"

        expect(described_class.call(fen)).to eq(feen)
      end

      it "handles a position with no castling rights" do
        fen = "rnbq1bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w - - 0 1"
        feen = "rnbq1bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR CHESS/chess -"

        expect(described_class.call(fen)).to eq(feen)
      end

      it "handles an endgame position with few pieces" do
        fen = "4k3/8/8/8/8/8/4P3/4K3 w - - 0 1"
        feen = "4k3/8/8/8/8/8/4P3/4K3 CHESS/chess -"

        expect(described_class.call(fen)).to eq(feen)
      end
    end

    # Tests for edge cases and errors
    context "with edge case inputs" do
      it "raises an exception for an empty string" do
        expect { described_class.call("") }.to raise_exception(ArgumentError)
      end

      it "raises an exception for a non-string object" do
        expect { described_class.call(nil) }.to raise_exception(ArgumentError)
        expect { described_class.call(123) }.to raise_exception(ArgumentError)
      end

      it "raises an exception for an incomplete FEN string" do
        expect { described_class.call("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR") }.to raise_exception(ArgumentError)
      end

      it "ignores the halfmove and fullmove parts of the FEN notation" do
        # Complete FEN notation includes a halfmove clock and fullmove number
        fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 10 5"
        feen = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR CHESS/chess -"

        expect(described_class.call(fen)).to eq(feen)
      end
    end

    # Test to verify that the FEEN result is valid
    it "produces valid FEEN that matches the expected format" do
      fen = "r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/2N2N2/PPPP1PPP/R1BQK2R w KQkq - 4 5"
      feen = described_class.call(fen)

      # Verify basic structure of FEEN
      parts = feen.split
      expect(parts.length).to eq(3)
      expect(parts[1]).to eq("CHESS/chess")
      expect(parts[2]).to eq("-")
    end
  end
end
