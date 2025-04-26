# frozen_string_literal: true

require_relative "../../spec_helper"
require_relative "../../../lib/feen/dumper/pieces_in_hand"

RSpec.describe Feen::Dumper::PiecesInHand do
  describe ".dump" do
    context "with valid inputs" do
      it 'returns "-" for no pieces' do
        expect(described_class.dump).to eq("-")
      end

      it 'returns "-" for empty array' do
        expect(described_class.dump).to eq("-")
      end

      it "handles a single piece" do
        expect(described_class.dump("P")).to eq("P")
      end

      it "handles multiple pieces" do
        expect(described_class.dump("P", "R", "N")).to eq("NPR")
      end

      it "sorts pieces in ASCII lexicographic order" do
        expect(described_class.dump("R", "P", "N")).to eq("NPR")
      end

      it "handles mixed case piece identifiers" do
        expect(described_class.dump("p", "P", "r", "R")).to eq("PRpr")
      end
    end

    context "with invalid inputs" do
      it "raises ArgumentError for non-string piece" do
        expect { described_class.dump(123) }.to raise_exception(ArgumentError)
      end

      it "raises ArgumentError for multi-character string" do
        expect { described_class.dump("ab") }.to raise_exception(ArgumentError)
      end

      it "raises ArgumentError for non-alphabetic character" do
        expect { described_class.dump("1") }.to raise_exception(ArgumentError)
      end

      it "raises ArgumentError for special character" do
        expect { described_class.dump("!") }.to raise_exception(ArgumentError)
      end

      it "raises ArgumentError for empty string" do
        expect { described_class.dump("") }.to raise_exception(ArgumentError)
      end

      it "raises ArgumentError for nil" do
        expect { described_class.dump(nil) }.to raise_exception(ArgumentError)
      end
    end

    context "with edge cases" do
      it "handles a large number of pieces" do
        # Create 52 pieces (a-z and A-Z)
        pieces = ("a".."z").to_a.concat(("A".."Z").to_a)
        expected = ("A".."Z").to_a.concat(("a".."z").to_a).join
        expect(described_class.dump(*pieces)).to eq(expected)
      end

      it "validates all pieces even if first one is valid" do
        expect { described_class.dump("P", 123) }.to raise_exception(ArgumentError)
      end

      it "validates all pieces even if one in the middle is invalid" do
        expect { described_class.dump("P", "Q", "!", "R") }.to raise_exception(ArgumentError)
      end
    end
  end
end
