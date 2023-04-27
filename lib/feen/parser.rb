# frozen_string_literal: true

require_relative File.join("parser", "board_shape")

module Feen
  # The parser module.
  module Parser
    # Parse a FEEN string into position params.
    #
    # @param feen [String] The FEEN string representing a position.
    #
    # @example Parse a classic Tsume Shogi problem
    #   call("3sks3/9/4+P4/9/7+B1/9/9/9/9 s")
    #   # => {
    #   #      "board_shape": [9, 9],
    #   #      "side_to_move": "s",
    #   #      "piece_placement": {
    #   #         3 => "s",
    #   #         4 => "k",
    #   #         5 => "s",
    #   #        22 => "+P",
    #   #        43 => "+B"
    #   #      }
    #
    # @return [Hash] The position params representing the position.
    def self.call(feen, regex: /\+?[a-z]/i)
      piece_placement_str, side_to_move_str = feen.split

      {
        board_shape:     BoardShape.new(piece_placement_str, regex:).to_a,
        piece_placement: piece_placement(piece_placement_str, regex:),
        side_to_move:    side_to_move_str
      }
    end

    def self.piece_placement(string, regex:)
      hash = {}
      index = 0
      string.scan(/(\d+|#{regex})/) do |match|
        if /\d+/.match?(match[0])
          index += match[0].to_i
        else
          hash[index] = match[0]
          index += 1
        end
      end
      hash
    end
    private_class_method :piece_placement
  end
end
