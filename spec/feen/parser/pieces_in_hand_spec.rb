# frozen_string_literal: true

require_relative "../../spec_helper"
require_relative "../../../lib/feen/parser/pieces_in_hand"

RSpec.describe Feen::Parser::PiecesInHand do
  describe ".parse" do
    context "with valid inputs" do
      it "returns an empty array for hyphen input" do
        expect(described_class.parse("-")).to eq([])
      end

      it "parses a single piece correctly" do
        result = described_class.parse("P")
        expect(result).to eq([{ id: "P" }])
      end

      it "parses multiple pieces correctly" do
        result = described_class.parse("NPR")
        expect(result).to eq([
                               { id: "N" },
                               { id: "P" },
                               { id: "R" }
                             ])
      end

      it "handles mixed case piece identifiers" do
        result = described_class.parse("PRpr")
        expect(result).to eq([
                               { id: "P" },
                               { id: "R" },
                               { id: "p" },
                               { id: "r" }
                             ])
      end

      it "parses a large number of pieces" do
        # All uppercase and lowercase letters
        pieces_str = ("A".."Z").to_a.join + ("a".."z").to_a.join
        result = described_class.parse(pieces_str)

        expected = ("A".."Z").to_a.concat(("a".."z").to_a).map { |c| { id: c } }
        expect(result).to eq(expected)
      end
    end

    context "with invalid inputs" do
      it "raises an error for nil input" do
        expect do
          described_class.parse(nil)
        end.to raise_exception(ArgumentError)
      end

      it "raises an error for empty string input" do
        expect do
          described_class.parse("")
        end.to raise_exception(ArgumentError)
      end

      it "raises an error for non-string input" do
        expect do
          described_class.parse(123)
        end.to raise_exception(ArgumentError)
      end

      it "raises an error for string with non-alphabetic characters" do
        expect do
          described_class.parse("P1R")
        end.to raise_exception(ArgumentError)
      end

      it "raises an error for string with special characters" do
        expect do
          described_class.parse("P!R")
        end.to raise_exception(ArgumentError)
      end

      it "raises an error for string with spaces" do
        expect do
          described_class.parse("P R")
        end.to raise_exception(ArgumentError)
      end

      it "raises an error for string with non-ASCII characters" do
        expect do
          described_class.parse("PñR")
        end.to raise_exception(ArgumentError)
      end

      it "raises an error when pieces are not in lexicographic order" do
        expect do
          described_class.parse("RPN")
        end.to raise_exception(ArgumentError)
      end
    end

    context "with edge cases" do
      it "handles a single hyphen correctly" do
        result = described_class.parse("-")
        expect(result).to eq([])
      end

      it "raises an error for multiple hyphens" do
        expect do
          described_class.parse("--")
        end.to raise_exception(ArgumentError)
      end

      it "raises an error for a hyphen combined with pieces" do
        expect do
          described_class.parse("P-R")
        end.to raise_exception(ArgumentError)
      end

      it "raises an error when input starts/ends with whitespace" do
        expect do
          described_class.parse(" PR")
        end.to raise_exception(ArgumentError)

        expect do
          described_class.parse("PR ")
        end.to raise_exception(ArgumentError)
      end

      it "raises an error for newline characters" do
        expect do
          described_class.parse("P\nR")
        end.to raise_exception(ArgumentError)
      end
    end
  end

  describe ".validate_pieces_in_hand_string" do
    it "does not raise an error for valid input" do
      expect do
        described_class.validate_pieces_in_hand_string("PR")
      end.not_to raise_exception(StandardError)
    end

    it "does not raise an error for hyphen" do
      expect do
        described_class.validate_pieces_in_hand_string("-")
      end.not_to raise_exception(StandardError)
    end
  end

  describe ".pieces_sorted?" do
    it "returns true for sorted pieces" do
      pieces = [
        { id: "N" },
        { id: "P" },
        { id: "R" }
      ]
      expect(described_class.pieces_sorted?(pieces)).to be true
    end

    it "returns false for unsorted pieces" do
      pieces = [
        { id: "P" },
        { id: "N" },
        { id: "R" }
      ]
      expect(described_class.pieces_sorted?(pieces)).to be false
    end

    it "handles case sensitivity in sorting" do
      # ASCII: uppercase comes before lowercase
      pieces = [
        { id: "P" },
        { id: "R" },
        { id: "p" },
        { id: "r" }
      ]
      expect(described_class.pieces_sorted?(pieces)).to be true

      pieces = [
        { id: "P" },
        { id: "p" },
        { id: "R" },
        { id: "r" }
      ]
      expect(described_class.pieces_sorted?(pieces)).to be false
    end

    it "returns true for a single piece" do
      pieces = [{ id: "P" }]
      expect(described_class.pieces_sorted?(pieces)).to be true
    end

    it "returns true for empty array" do
      expect(described_class.pieces_sorted?([])).to be true
    end
  end
end
