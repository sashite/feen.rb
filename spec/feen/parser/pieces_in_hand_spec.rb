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
        expect(result).to eq(["P"])
      end

      it "parses multiple pieces correctly" do
        result = described_class.parse("NPR")
        expect(result).to eq(%w[N P R])
      end

      it "handles mixed case piece identifiers" do
        result = described_class.parse("PRpr")
        expect(result).to eq(%w[P R p r])
      end

      it "parses a large number of pieces" do
        # All uppercase and lowercase letters
        pieces_str = ("A".."Z").to_a.join + ("a".."z").to_a.join
        result = described_class.parse(pieces_str)

        expected = ("A".."Z").to_a.concat(("a".."z").to_a)
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
end
