# frozen_string_literal: true

require_relative "../../spec_helper"
require_relative "../../../lib/feen/parser/piece_placement"

RSpec.describe Feen::Parser::PiecePlacement do
  describe ".parse" do
    context "with valid inputs" do
      it "parses an empty board correctly" do
        result = described_class.parse("8")
        expect(result).to eq([nil] * 8)
      end

      it "parses a simple 1D board with basic pieces" do
        result = described_class.parse("rnbqkbnr")
        expected = [
          { id: "r" }, { id: "n" }, { id: "b" }, { id: "q" },
          { id: "k" }, { id: "b" }, { id: "n" }, { id: "r" }
        ]
        expect(result).to eq(expected)
      end

      it "parses a 1D board with empty cells" do
        result = described_class.parse("rn2k3")
        expected = [
          { id: "r" }, { id: "n" }, nil, nil, { id: "k" }, nil, nil, nil
        ]
        expect(result).to eq(expected)
      end

      it "parses a standard 2D board (chess)" do
        feen_string = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
        result = described_class.parse(feen_string)

        # Verify the 2D structure (8x8 matrix)
        expect(result.length).to eq(8) # 8 ranks
        result.each do |rank|
          expect(rank.length).to eq(8) # 8 files in each rank
        end

        # Check some specific elements
        expect(result[0][0]).to eq({ id: "r" }) # Top-left cell
        expect(result[7][7]).to eq({ id: "R" }) # Bottom-right cell
        expect(result[2]).to eq([nil] * 8) # Third rank, all empty cells
      end

      it "parses a 3D board correctly according to FEEN specification" do
        # This string defines a 3D structure:
        # - Two 2D sections separated by '//'
        # - Each 2D section has two ranks separated by '/'
        feen_string = "rnb/qkp//PR1/1KQ"
        result = described_class.parse(feen_string)

        # According to FEEN spec, multiple slashes indicate deeper nesting levels
        # This should be a 3D structure: [[[r,n,b],[q,k,p]],[[P,R,1],[1,K,Q]]]
        expected = [
          [
            [{ id: "r" }, { id: "n" }, { id: "b" }],
            [{ id: "q" }, { id: "k" }, { id: "p" }]
          ],
          [
            [{ id: "P" }, { id: "R" }, nil],
            [nil, { id: "K" }, { id: "Q" }]
          ]
        ]
        expect(result).to eq(expected)
      end

      it "parses a 4D board correctly" do
        # A 4D structure: two 3D sections separated by '///'
        feen_string = "r/n//p/q///k/b//R/Q"
        result = described_class.parse(feen_string)

        # Each additional slash increases the dimension level
        expected = [
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
        expect(result).to eq(expected)
      end

      it "parses a board with prefixes correctly" do
        result = described_class.parse("rn+Pq+Bk")
        expected = [
          { id: "r" }, { id: "n" }, { id: "P", prefix: "+" },
          { id: "q" }, { id: "B", prefix: "+" }, { id: "k" }
        ]
        expect(result).to eq(expected)
      end

      it "parses a board with suffixes correctly" do
        result = described_class.parse("rK=nQ<bR>")
        expected = [
          { id: "r" }, { id: "K", suffix: "=" }, { id: "n" },
          { id: "Q", suffix: "<" }, { id: "b" }, { id: "R", suffix: ">" }
        ]
        expect(result).to eq(expected)
      end

      it "parses a board with both prefixes AND suffixes correctly" do
        result = described_class.parse("r+P=n+B<k>")
        expected = [
          { id: "r" }, { id: "P", prefix: "+", suffix: "=" }, { id: "n" },
          { id: "B", prefix: "+", suffix: "<" }, { id: "k", suffix: ">" }
        ]
        expect(result).to eq(expected)
      end

      it "parses large numbers of empty cells correctly" do
        result = described_class.parse("r10n")
        expected = [{ id: "r" }] + ([nil] * 10) + [{ id: "n" }]
        expect(result).to eq(expected)
      end

      it "parses a board with dimensions of different sizes" do
        # A 3D board where one 2D section has 2 ranks of 3 cells
        # and another 2D section has 2 ranks of 2 cells
        feen_string = "rnb/qkp//PR/KQ"
        result = described_class.parse(feen_string)

        expected = [
          [
            [{ id: "r" }, { id: "n" }, { id: "b" }],
            [{ id: "q" }, { id: "k" }, { id: "p" }]
          ],
          [
            [{ id: "P" }, { id: "R" }],
            [{ id: "K" }, { id: "Q" }]
          ]
        ]
        expect(result).to eq(expected)
      end

      context "with famous chess positions" do
        it "parses the initial chess position correctly with castling rights" do
          initial_position = "rnbqk=bnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQK=BNR"
          result = described_class.parse(initial_position)

          # Verify pieces at strategic positions
          expect(result[0][0]).to eq({ id: "r" }) # Black rook at a8
          expect(result[0][4]).to eq({ id: "k", suffix: "=" }) # Black king at e8 with castling rights
          expect(result[7][4]).to eq({ id: "K", suffix: "=" }) # White king at e1 with castling rights
          expect(result[1]).to eq([{ id: "p" }] * 8) # Black pawns
          expect(result[6]).to eq([{ id: "P" }] * 8) # White pawns
        end

        it "parses the Ruy Lopez opening position correctly" do
          # Position after 1.e4 e5 2.Nf3 Nc6 3.Bb5
          ruy_lopez = "r1bqk=bnr/pppp1ppp/2n5/1B2p3/4P3/5N2/PPPP1PPP/RNBQK=2R"
          result = described_class.parse(ruy_lopez)

          # Verify key pieces
          expect(result[0][1]).to be_nil # Empty square at b8
          expect(result[2][2]).to eq({ id: "n" }) # Black knight at c6
          expect(result[3][1]).to eq({ id: "B" }) # White bishop at b5
          expect(result[7][6]).to be_nil # Empty square at g1 (moved knight)
          expect(result[0][4]).to eq({ id: "k", suffix: "=" }) # Black king with castling rights
          expect(result[7][4]).to eq({ id: "K", suffix: "=" }) # White king with castling rights
        end

        it "parses a complex middle game position" do
          # Complex position with various pieces and empty spaces
          middle_game = "3r1rk1/pp3ppp/2n1b3/2p1q3/Q7/2P2N2/PP2BPPP/R4RK1"
          result = described_class.parse(middle_game)

          # Verify structure and specific pieces
          expect(result[0][3]).to eq({ id: "r" }) # Black rook at d8
          expect(result[3][4]).to eq({ id: "q" }) # Black queen at e5
          expect(result[4][0]).to eq({ id: "Q" }) # White queen at a4
        end
      end

      context "with chess castling rights using suffixes" do
        it "parses a position with castling rights" do
          # Position with castling rights indicated by suffixes
          castling_position = "r3k=2r/pppppppp/8/8/8/8/PPPPPPPP/R3K=2R"
          result = described_class.parse(castling_position)

          # Verify castling rights (indicated by suffix)
          expect(result[0][4]).to eq({ id: "k", suffix: "=" }) # Black king with castling rights on both sides
          expect(result[7][4]).to eq({ id: "K", suffix: "=" }) # White king with castling rights on both sides
        end

        it "parses a position with partial castling rights" do
          # Position with partial castling rights
          partial_castling = "r3k>2r/pppppppp/8/8/8/8/PPPPPPPP/R3K<2R"
          result = described_class.parse(partial_castling)

          # Verify kings have the correct suffixes
          expect(result[0][4]).to eq({ id: "k", suffix: ">" }) # Black king with kingside castling only
          expect(result[7][4]).to eq({ id: "K", suffix: "<" }) # White king with queenside castling only
        end
      end

      context "with edge cases and boundary conditions" do
        it "parses a minimal 1x1 board" do
          result = described_class.parse("k")
          expect(result).to eq([{ id: "k" }])
        end

        it "parses a very large 1D board (stress test)" do
          # Create a string with a very large number of empty squares
          large_board = "r1000R"
          result = described_class.parse(large_board)

          expect(result.length).to eq(1002) # 1 + 1000 + 1
          expect(result.first).to eq({ id: "r" })
          expect(result.last).to eq({ id: "R" })
          expect(result[1...-1].all?(&:nil?)).to be true
        end
      end
    end

    context "with invalid inputs" do
      it "raises an error for nil input" do
        expect { described_class.parse(nil) }.to raise_exception(ArgumentError)
      end

      it "raises an error for an empty string" do
        expect { described_class.parse("") }.to raise_exception(ArgumentError)
      end

      it "raises an error for invalid characters" do
        expect { described_class.parse("rn$qk") }.to raise_exception(ArgumentError)
      end

      it "raises an error for a prefix without a piece identifier" do
        expect { described_class.parse("rn+") }.to raise_exception(ArgumentError)
      end

      it "raises an error for a prefix followed by a non-alphabetic character" do
        expect { described_class.parse("rn+1") }.to raise_exception(ArgumentError)
      end

      it "raises an error for an invalid piece identifier" do
        expect { described_class.parse("rn1p/") }.to raise_exception(ArgumentError)
      end
    end
  end

  describe ".parse_rank" do
    it "returns an empty array for an empty input" do
      expect(described_class.parse_rank("")).to eq([])
    end

    it "parses a rank with only pieces correctly" do
      result = described_class.parse_rank("rnbqkbnr")
      expected = [
        { id: "r" }, { id: "n" }, { id: "b" }, { id: "q" },
        { id: "k" }, { id: "b" }, { id: "n" }, { id: "r" }
      ]
      expect(result).to eq(expected)
    end

    it "parses a rank with pieces and empty cells correctly" do
      result = described_class.parse_rank("rn1qk1nr")
      expected = [
        { id: "r" }, { id: "n" }, nil, { id: "q" },
        { id: "k" }, nil, { id: "n" }, { id: "r" }
      ]
      expect(result).to eq(expected)
    end

    it "parses a rank with only empty cells correctly" do
      result = described_class.parse_rank("8")
      expected = [nil] * 8
      expect(result).to eq(expected)
    end

    it "parses a rank with prefixes and suffixes correctly" do
      result = described_class.parse_rank("r+P=nk<+R>")
      expected = [
        { id: "r" },
        { id: "P", prefix: "+", suffix: "=" },
        { id: "n" },
        { id: "k", suffix: "<" },
        { id: "R", prefix: "+", suffix: ">" }
      ]
      expect(result).to eq(expected)
    end

    it "raises an error for an invalid piece character" do
      expect { described_class.parse_rank("r?b") }.to raise_exception(ArgumentError)
    end
  end

  describe ".find_min_dimension_depth" do
    it "returns 1 for a standard 2D board" do
      expect(described_class.find_min_dimension_depth("rnbqkbnr/pppppppp")).to eq(1)
    end

    it "returns 1 for a 3D board with single and double slashes" do
      expect(described_class.find_min_dimension_depth("rnb/qkp//PR1/1KQ")).to eq(1)
    end

    it "returns 1 if no separator is found" do
      expect(described_class.find_min_dimension_depth("rnbqkbnr")).to eq(1)
    end

    it "returns 2 for a structure with minimum separators being double slashes" do
      expect(described_class.find_min_dimension_depth("rnb//qkp//PR1")).to eq(2)
    end

    it "returns 3 for a structure with minimum separators being triple slashes" do
      expect(described_class.find_min_dimension_depth("rnb///qkp///PR1")).to eq(3)
    end
  end

  describe ".split_by_separator" do
    it "splits correctly by the specified separator" do
      expect(described_class.split_by_separator("a/b/c", "/")).to eq(%w[a b c])
    end

    it "handles 2D board structure correctly" do
      # Dans un plateau 2D standard, on a des rangs séparés par "/"
      expect(described_class.split_by_separator("rnbqkbnr/pppppppp/8/8", "/")).to eq(%w[rnbqkbnr pppppppp 8 8])
    end

    it "splits at the double slash level correctly for 3D structures" do
      # Structure 3D avec deux sections 2D
      expect(described_class.split_by_separator("a/b//c/d", "//")).to eq(["a/b", "c/d"])
    end

    it "preserves integrity of internal dimensions when splitting" do
      # Quand on divise par "//", les "/" restent intacts
      board_3d = "rnb/qkp//PR1/1KQ"
      expect(described_class.split_by_separator(board_3d, "//")).to eq(["rnb/qkp", "PR1/1KQ"])

      # Vérifier que chaque section peut ensuite être divisée par "/"
      sections = described_class.split_by_separator(board_3d, "//")
      expect(described_class.split_by_separator(sections[0], "/")).to eq(%w[rnb qkp])
      expect(described_class.split_by_separator(sections[1], "/")).to eq(%w[PR1 1KQ])
    end

    it "splits at the triple slash level for 4D structures" do
      # Structure 4D avec deux sections 3D
      board_4d = "r/n//p/q///k/b//R/Q"
      expect(described_class.split_by_separator(board_4d, "///")).to eq(["r/n//p/q", "k/b//R/Q"])
    end

    it "handles separators at the end correctly" do
      # Les séparateurs à la fin sont normalement ignorés dans FEEN
      expect(described_class.split_by_separator("a/b/c/", "/")).to eq(%w[a b c])
    end

    it "handles consecutive separators of the same dimension correctly" do
      # Séparateurs consécutifs du même niveau
      expect(described_class.split_by_separator("a//b//c", "//")).to eq(%w[a b c])
    end

    it "correctly processes more complex 3D board structures" do
      # Structure 3D plus complexe (5x5x5)
      board_3d = "5/5/5/5/5//5/5/5/5/5//5/5/5/5/5"
      sections = described_class.split_by_separator(board_3d, "//")
      expect(sections).to eq(["5/5/5/5/5", "5/5/5/5/5", "5/5/5/5/5"])

      # Vérifier que chaque section a 5 rangs
      sections.each do |section|
        expect(described_class.split_by_separator(section, "/")).to eq(%w[5 5 5 5 5])
      end
    end
  end
end
