# frozen_string_literal: true

require_relative "../../spec_helper"
require_relative "../../../lib/feen/dumper/piece_placement"

RSpec.describe Feen::Dumper::PiecePlacement do
  describe ".dump" do
    context "with valid inputs" do
      it "returns empty string for nil input" do
        expect(described_class.dump(nil)).to eq("")
      end

      it "returns empty string for empty array" do
        expect(described_class.dump([])).to eq("")
      end

      it "converts a simple 1D board with pieces only" do
        piece_placement = [
          { id: "r" }, { id: "n" }, { id: "b" }, { id: "q" },
          { id: "k" }, { id: "b" }, { id: "n" }, { id: "r" }
        ]
        expect(described_class.dump(piece_placement)).to eq("rnbqkbnr")
      end

      it "converts a 1D board with empty cells" do
        piece_placement = [
          { id: "r" }, { id: "n" }, nil, nil, { id: "k" }, nil, nil, nil
        ]
        expect(described_class.dump(piece_placement)).to eq("rn2k3")
      end

      it "converts a standard 2D chess board" do
        piece_placement = [
          [{ id: "r" }, { id: "n" }, { id: "b" }, { id: "q" }, { id: "k" }, { id: "b" }, { id: "n" }, { id: "r" }],
          [{ id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [{ id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }],
          [{ id: "R" }, { id: "N" }, { id: "B" }, { id: "Q" }, { id: "K" }, { id: "B" }, { id: "N" }, { id: "R" }]
        ]
        expect(described_class.dump(piece_placement)).to eq("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR")
      end

      it "converts a 3D board correctly" do
        piece_placement = [
          [
            [{ id: "r" }, { id: "n" }, { id: "b" }],
            [{ id: "q" }, { id: "k" }, { id: "p" }]
          ],
          [
            [{ id: "P" }, { id: "R" }, nil],
            [nil, { id: "K" }, { id: "Q" }]
          ]
        ]
        expect(described_class.dump(piece_placement)).to eq("rnb/qkp//PR1/1KQ")
      end

      it "converts a 4D board correctly" do
        piece_placement = [
          [
            [
              [{ id: "r" }],
              [{ id: "n" }]
            ],
            [
              [{ id: "p" }],
              [{ id: "q" }]
            ]
          ],
          [
            [
              [{ id: "k" }],
              [{ id: "b" }]
            ],
            [
              [{ id: "R" }],
              [{ id: "Q" }]
            ]
          ]
        ]
        expect(described_class.dump(piece_placement)).to eq("r/n//p/q///k/b//R/Q")
      end

      it "handles prefixes correctly" do
        piece_placement = [
          { id: "r" }, { id: "n" }, { id: "P", prefix: "+" },
          { id: "q" }, { id: "B", prefix: "+" }, { id: "k" }
        ]
        expect(described_class.dump(piece_placement)).to eq("rn+Pq+Bk")
      end

      it "handles suffixes correctly" do
        piece_placement = [
          { id: "r" }, { id: "K", suffix: "=" }, { id: "n" },
          { id: "Q", suffix: "<" }, { id: "b" }, { id: "R", suffix: ">" }
        ]
        expect(described_class.dump(piece_placement)).to eq("rK=nQ<bR>")
      end

      it "handles both prefixes and suffixes correctly" do
        piece_placement = [
          { id: "r" }, { id: "P", prefix: "+", suffix: "=" }, { id: "n" },
          { id: "B", prefix: "+", suffix: "<" }, { id: "k", suffix: ">" }
        ]
        expect(described_class.dump(piece_placement)).to eq("r+P=n+B<k>")
      end

      it "handles large groups of empty cells" do
        piece_placement = [{ id: "r" }] + ([nil] * 10) + [{ id: "n" }]
        expect(described_class.dump(piece_placement)).to eq("r10n")
      end

      it "handles dimensions of different sizes" do
        piece_placement = [
          [
            [{ id: "r" }, { id: "n" }, { id: "b" }],
            [{ id: "q" }, { id: "k" }, { id: "p" }]
          ],
          [
            [{ id: "P" }, { id: "R" }],
            [{ id: "K" }, { id: "Q" }]
          ]
        ]
        expect(described_class.dump(piece_placement)).to eq("rnb/qkp//PR/KQ")
      end
    end

    context "with chess positions" do
      it "converts the initial chess position correctly" do
        piece_placement = [
          [{ id: "r" }, { id: "n" }, { id: "b" }, { id: "q" }, { id: "k", suffix: "=" }, { id: "b" }, { id: "n" }, { id: "r" }],
          [{ id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [{ id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }],
          [{ id: "R" }, { id: "N" }, { id: "B" }, { id: "Q" }, { id: "K", suffix: "=" }, { id: "B" }, { id: "N" }, { id: "R" }]
        ]
        expect(described_class.dump(piece_placement)).to eq("rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR")
      end

      it "converts the Ruy Lopez opening position correctly" do
        # Position after 1.e4 e5 2.Nf3 Nc6 3.Bb5
        piece_placement = [
          [{ id: "r" }, nil, { id: "b" }, { id: "q" }, { id: "k", suffix: "=" }, { id: "b" }, { id: "n" }, { id: "r" }],
          [{ id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, nil, { id: "p" }, { id: "p" }, { id: "p" }],
          [nil, nil, { id: "n" }, nil, nil, nil, nil, nil],
          [nil, { id: "B" }, nil, nil, { id: "p" }, nil, nil, nil],
          [nil, nil, nil, nil, { id: "P" }, nil, nil, nil],
          [nil, nil, nil, nil, nil, { id: "N" }, nil, nil],
          [{ id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, nil, { id: "P" }, { id: "P" }, { id: "P" }],
          [{ id: "R" }, { id: "N" }, { id: "B" }, { id: "Q" }, { id: "K", suffix: "=" }, nil, nil, { id: "R" }]
        ]
        expect(described_class.dump(piece_placement)).to eq("r1bqk=bnr/pppp1ppp/2n5/1B2p3/4P3/5N2/PPPP1PPP/RNBQK=2R")
      end

      it "converts a position with partial castling rights" do
        piece_placement = [
          [{ id: "r" }, nil, nil, nil, { id: "k", suffix: ">" }, nil, nil, { id: "r" }],
          [{ id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }, { id: "p" }],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [{ id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }, { id: "P" }],
          [{ id: "R" }, nil, nil, nil, { id: "K", suffix: "<" }, nil, nil, { id: "R" }]
        ]
        expect(described_class.dump(piece_placement)).to eq("r3k>2r/pppppppp/8/8/8/8/PPPPPPPP/R3K<2R")
      end

      it "converts a middle game position" do
        piece_placement = [
          [nil, nil, nil, { id: "r" }, nil, { id: "r" }, { id: "k" }, nil],
          [{ id: "p" }, { id: "p" }, nil, nil, nil, { id: "p" }, { id: "p" }, { id: "p" }],
          [nil, nil, { id: "n" }, nil, { id: "b" }, nil, nil, nil],
          [nil, nil, { id: "p" }, nil, { id: "q" }, nil, nil, nil],
          [{ id: "Q" }, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, { id: "P" }, nil, nil, { id: "N" }, nil, nil],
          [{ id: "P" }, { id: "P" }, nil, nil, { id: "B" }, { id: "P" }, { id: "P" }, { id: "P" }],
          [{ id: "R" }, nil, nil, nil, nil, { id: "R" }, { id: "K" }, nil]
        ]
        expect(described_class.dump(piece_placement)).to eq("3r1rk1/pp3ppp/2n1b3/2p1q3/Q7/2P2N2/PP2BPPP/R4RK1")
      end

      it "converts a shogi position with promoted pieces" do
        piece_placement = [
          [nil, nil, nil, { id: "s" }, { id: "k" }, { id: "s" }, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, { id: "P", prefix: "+" }, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, { id: "B", prefix: "+" }, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil, nil]
        ]
        expect(described_class.dump(piece_placement)).to eq("3sks3/9/4+P4/9/7+B1/9/9/9/9")
      end
    end

    context "with edge cases" do
      it "handles a minimal 1x1 board" do
        piece_placement = [{ id: "k" }]
        expect(described_class.dump(piece_placement)).to eq("k")
      end

      it "handles nested arrays with only empty cells" do
        piece_placement = [
          [nil, nil, nil],
          [nil, nil, nil]
        ]
        expect(described_class.dump(piece_placement)).to eq("3/3")
      end

      it "handles nested arrays with varying depths" do
        piece_placement = [
          [
            [nil, nil],
            [{ id: "p" }]
          ],
          [{ id: "K" }, { id: "Q" }]
        ]
        expect(described_class.dump(piece_placement)).to eq("2/p//KQ")
      end

      it "handles very large board dimensions" do
        piece_placement = [
          [nil] * 20,
          [{ id: "K" }] + ([nil] * 19)
        ]
        expect(described_class.dump(piece_placement)).to eq("20/K19")
      end
    end
  end

  describe ".dump_dimension_group" do
    it "handles a simple 1D array" do
      piece_placement = [{ id: "r" }, { id: "n" }, { id: "b" }]
      expect(described_class.dump_dimension_group(piece_placement)).to eq("rnb")
    end

    it "handles a 2D array" do
      piece_placement = [
        [{ id: "r" }, { id: "n" }, { id: "b" }],
        [{ id: "p" }, { id: "p" }, { id: "p" }]
      ]
      expect(described_class.dump_dimension_group(piece_placement)).to eq("rnb/ppp")
    end

    it "returns empty string for nil or empty input" do
      expect(described_class.dump_dimension_group(nil)).to eq("")
      expect(described_class.dump_dimension_group([])).to eq("")
    end
  end

  describe ".dump_rank" do
    it "converts a rank with only pieces" do
      rank = [{ id: "r" }, { id: "n" }, { id: "b" }, { id: "q" }, { id: "k" }]
      expect(described_class.dump_rank(rank)).to eq("rnbqk")
    end

    it "converts a rank with empty cells" do
      rank = [{ id: "r" }, nil, nil, { id: "q" }, nil, { id: "k" }]
      expect(described_class.dump_rank(rank)).to eq("r2q1k")
    end

    it "converts a rank with consecutive empty cells" do
      rank = [nil, nil, { id: "p" }, nil, nil, nil, { id: "r" }, nil]
      expect(described_class.dump_rank(rank)).to eq("2p3r1")
    end

    it "converts a rank with pieces having prefixes and suffixes" do
      rank = [
        { id: "r" },
        { id: "P", prefix: "+" },
        nil,
        { id: "k", suffix: "=" },
        { id: "Q", prefix: "+", suffix: ">" }
      ]
      expect(described_class.dump_rank(rank)).to eq("r+P1k=+Q>")
    end

    it "returns empty string for nil or empty input" do
      expect(described_class.dump_rank(nil)).to eq("")
      expect(described_class.dump_rank([])).to eq("")
    end
  end

  describe ".dump_cell" do
    it "returns a piece identifier" do
      cell = { id: "p" }
      expect(described_class.dump_cell(cell)).to eq("p")
    end

    it "includes prefix if present" do
      cell = { id: "P", prefix: "+" }
      expect(described_class.dump_cell(cell)).to eq("+P")
    end

    it "includes suffix if present" do
      cell = { id: "K", suffix: "=" }
      expect(described_class.dump_cell(cell)).to eq("K=")
    end

    it "combines prefix and suffix correctly" do
      cell = { id: "Q", prefix: "+", suffix: "<" }
      expect(described_class.dump_cell(cell)).to eq("+Q<")
    end

    it "returns empty string for nil cell" do
      expect(described_class.dump_cell(nil)).to eq("")
    end

    it "handles additional irrelevant keys in the hash" do
      cell = { id: "r", prefix: "+", suffix: ">", irrelevant: "value" }
      expect(described_class.dump_cell(cell)).to eq("+r>")
    end
  end
end
