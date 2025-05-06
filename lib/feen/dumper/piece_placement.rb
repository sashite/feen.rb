# frozen_string_literal: true

require_relative File.join("piece_placement", "board")

module Feen
  module Dumper
    module PiecePlacement
      # Converts a piece placement structure to a FEEN-compliant string
      #
      # @param shape [Array<Integer>] The dimensions of the board (e.g., [8, 8] for a chess board)
      # @param contents [Array<nil, Piece>] Flattened array of board contents
      # @return [String] FEEN piece placement string
      # @raise [ArgumentError] If parameters are invalid
      # @example
      #   PiecePlacement.dump([8, 8], [nil, nil, piece1, nil, piece2, ...])
      #   # => "2p5/8/8/..."
      def self.dump(shape, contents)
        board = Board.new(shape)
        board.flatten_squares(*contents)
      end
    end
  end
end
