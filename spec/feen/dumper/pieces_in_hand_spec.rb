# frozen_string_literal: true

require_relative "../../spec_helper"
require_relative "../../../lib/feen/dumper/pieces_in_hand"

RSpec.describe Feen::Dumper::PiecesInHand do
  describe ".dump" do
    context "with valid inputs" do
      it 'returns "-" for nil input' do
        expect(described_class.dump(nil)).to eq("-")
      end

      it 'returns "-" for empty array' do
        expect(described_class.dump([])).to eq("-")
      end

      it "handles a single piece" do
        pieces = [{ id: "P" }]
        expect(described_class.dump(pieces)).to eq("P")
      end

      it "handles multiple pieces" do
        pieces = [
          { id: "P" },
          { id: "R" },
          { id: "N" }
        ]
        expect(described_class.dump(pieces)).to eq("NPR")
      end

      it "sorts pieces in ASCII lexicographic order" do
        pieces = [
          { id: "R" },
          { id: "P" },
          { id: "N" }
        ]
        expect(described_class.dump(pieces)).to eq("NPR")
      end

      it "handles mixed case piece identifiers" do
        pieces = [
          { id: "p" },
          { id: "P" },
          { id: "r" },
          { id: "R" }
        ]
        expect(described_class.dump(pieces)).to eq("PRpr")
      end
    end

    context "with invalid inputs" do
      it "raises ArgumentError for piece without id" do
        pieces = [
          { another_key: "value" }
        ]
        expect { described_class.dump(pieces) }.to raise_exception(ArgumentError)
      end

      it "raises ArgumentError for piece with invalid id type" do
        pieces = [
          { id: 123 }
        ]
        expect { described_class.dump(pieces) }.to raise_exception(ArgumentError)
      end

      it "raises ArgumentError for piece with invalid id value" do
        pieces = [
          { id: "ab" }
        ]
        expect { described_class.dump(pieces) }.to raise_exception(ArgumentError)
      end

      it "raises ArgumentError for piece with non-alphabetic id" do
        pieces = [
          { id: "1" }
        ]
        expect { described_class.dump(pieces) }.to raise_exception(ArgumentError)
      end

      it "raises ArgumentError for piece with prefix" do
        pieces = [
          { id: "P", prefix: "+" }
        ]
        expect { described_class.dump(pieces) }.to raise_exception(ArgumentError)
      end

      it "raises ArgumentError for piece with suffix" do
        pieces = [
          { id: "P", suffix: "=" }
        ]
        expect { described_class.dump(pieces) }.to raise_exception(ArgumentError)
      end
    end

    context "with edge cases" do
      it "handles pieces with additional unknown keys" do
        pieces = [
          { id: "P", unknown_key: "value" }
        ]
        expect(described_class.dump(pieces)).to eq("P")
      end

      it "handles a large number of pieces" do
        # Create 52 pieces (a-z and A-Z)
        pieces = ("a".."z").to_a.concat(("A".."Z").to_a).map { |c| { id: c } }
        expected = ("A".."Z").to_a.concat(("a".."z").to_a).join
        expect(described_class.dump(pieces)).to eq(expected)
      end

      it "handles empty string IDs" do
        pieces = [
          { id: "" }
        ]
        expect { described_class.dump(pieces) }.to raise_exception(ArgumentError)
      end

      it "handles nil IDs" do
        pieces = [
          { id: nil }
        ]
        expect { described_class.dump(pieces) }.to raise_exception(ArgumentError)
      end

      it "validates all pieces even if first one is valid" do
        pieces = [
          { id: "P" },
          { id: 123 }
        ]
        expect { described_class.dump(pieces) }.to raise_exception(ArgumentError)
      end
    end
  end
end
