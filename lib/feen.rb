# frozen_string_literal: true

require_relative 'feen/dumper'
require_relative 'feen/parser'

# This module provides a Ruby interface for data serialization and
# deserialization in FEEN format.
#
# @see https://developer.sashite.com/specs/forsyth-edwards-expanded-notation
#
# @example Chess's starting position
#   FEEN.dump([8, 8],
#     '♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜',
#     '♟', '♟', '♟', '♟', '♟', '♟', '♟', '♟',
#     nil, nil, nil, nil, nil, nil, nil, nil,
#     nil, nil, nil, nil, nil, nil, nil, nil,
#     nil, nil, nil, nil, nil, nil, nil, nil,
#     nil, nil, nil, nil, nil, nil, nil, nil,
#     '♙', '♙', '♙', '♙', '♙', '♙', '♙', '♙',
#     '♖', '♘', '♗', '♕', '♔', '♗', '♘', '♖'
#   )
#
# @example Makruk's starting position
#   FEEN.dump([8, 8],
#     '♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜',
#     nil, nil, nil, nil, nil, nil, nil, nil,
#     '♟', '♟', '♟', '♟', '♟', '♟', '♟', '♟',
#     nil, nil, nil, nil, nil, nil, nil, nil,
#     nil, nil, nil, nil, nil, nil, nil, nil,
#     '♙', '♙', '♙', '♙', '♙', '♙', '♙', '♙',
#     nil, nil, nil, nil, nil, nil, nil, nil,
#     '♖', '♘', '♗', '♔', '♕', '♗', '♘', '♖'
#   )
#
# @example Shogi's starting position
#   FEEN.dump([9, 9],
#     'l', 'n', 's', 'g', 'k', 'g', 's', 'n', 'l',
#     nil, 'r', nil, nil, nil, nil, nil, 'b', nil,
#     'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p',
#     nil, nil, nil, nil, nil, nil, nil, nil, nil,
#     nil, nil, nil, nil, nil, nil, nil, nil, nil,
#     nil, nil, nil, nil, nil, nil, nil, nil, nil,
#     'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',
#     nil, 'B', nil, nil, nil, nil, nil, 'R', nil,
#     'L', 'N', 'S', 'G', 'K', 'G', 'S', 'N', 'L'
#   )
#
# @example Xiangqi's starting position
#   FEEN.dump([10, 9],
#     '車', '馬', '象', '士', '將', '士', '象', '馬', '車',
#     nil, nil, nil, nil, nil, nil, nil, nil, nil,
#     nil, '砲', nil, nil, nil, nil, nil, '砲', nil,
#     '卒', nil, '卒', nil, '卒', nil, '卒', nil, '卒',
#     nil, nil, nil, nil, nil, nil, nil, nil, nil,
#     nil, nil, nil, nil, nil, nil, nil, nil, nil,
#     '兵', nil, '兵', nil, '兵', nil, '兵', nil, '兵',
#     nil, '炮', nil, nil, nil, nil, nil, '炮', nil,
#     nil, nil, nil, nil, nil, nil, nil, nil, nil,
#     '俥', '傌', '相', '仕', '帥', '仕', '相', '傌', '俥'
#   )
module FEEN
  # Dumps position params into a FEEN string.
  #
  # @param indexes [Array] The shape of the board.
  # @param squares [Array] The list of squares of on the board.
  # @param is_turn_to_topside [Boolean] The player who must play.
  # @param bottomside_in_hand_pieces [Array] The list of bottom-side's pieces in hand.
  # @param topside_in_hand_pieces [Array] The list of top-side's pieces in hand.
  #
  # @example Chess's starting position
  #   dump([8, 8],
  #     '♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜',
  #     '♟', '♟', '♟', '♟', '♟', '♟', '♟', '♟',
  #     nil, nil, nil, nil, nil, nil, nil, nil,
  #     nil, nil, nil, nil, nil, nil, nil, nil,
  #     nil, nil, nil, nil, nil, nil, nil, nil,
  #     nil, nil, nil, nil, nil, nil, nil, nil,
  #     '♙', '♙', '♙', '♙', '♙', '♙', '♙', '♙',
  #     '♖', '♘', '♗', '♕', '♔', '♗', '♘', '♖'
  #   )
  #
  # @example Makruk's starting position
  #   dump([8, 8],
  #     '♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜',
  #     nil, nil, nil, nil, nil, nil, nil, nil,
  #     '♟', '♟', '♟', '♟', '♟', '♟', '♟', '♟',
  #     nil, nil, nil, nil, nil, nil, nil, nil,
  #     nil, nil, nil, nil, nil, nil, nil, nil,
  #     '♙', '♙', '♙', '♙', '♙', '♙', '♙', '♙',
  #     nil, nil, nil, nil, nil, nil, nil, nil,
  #     '♖', '♘', '♗', '♔', '♕', '♗', '♘', '♖'
  #   )
  #
  # @example Shogi's starting position
  #   dump([9, 9],
  #     'l', 'n', 's', 'g', 'k', 'g', 's', 'n', 'l',
  #     nil, 'r', nil, nil, nil, nil, nil, 'b', nil,
  #     'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p',
  #     nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #     nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #     nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #     'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P',
  #     nil, 'B', nil, nil, nil, nil, nil, 'R', nil,
  #     'L', 'N', 'S', 'G', 'K', 'G', 'S', 'N', 'L'
  #   )
  #
  # @example Xiangqi's starting position
  #   dump([10, 9],
  #     '車', '馬', '象', '士', '將', '士', '象', '馬', '車',
  #     nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #     nil, '砲', nil, nil, nil, nil, nil, '砲', nil,
  #     '卒', nil, '卒', nil, '卒', nil, '卒', nil, '卒',
  #     nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #     nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #     '兵', nil, '兵', nil, '兵', nil, '兵', nil, '兵',
  #     nil, '炮', nil, nil, nil, nil, nil, '炮', nil,
  #     nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #     '俥', '傌', '相', '仕', '帥', '仕', '相', '傌', '俥'
  #   )
  #
  # @return [String] The FEEN string representing the position.
  def self.dump(indexes, *squares, is_turn_to_topside: false, bottomside_in_hand_pieces: [], topside_in_hand_pieces: [])
    Dumper.call(
      indexes,
      *squares,
      is_turn_to_topside: is_turn_to_topside,
      bottomside_in_hand_pieces: bottomside_in_hand_pieces,
      topside_in_hand_pieces: topside_in_hand_pieces
    )
  end

  # Parses a FEEN string into position params.
  #
  # @param feen_string [String] The FEEN string representing a position.
  #
  # @example Chess's starting position
  #   parse('♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/8/8/♙,♙,♙,♙,♙,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ B /')
  #
  # @example Makruk's starting position
  #   parse('♜,♞,♝,♛,♚,♝,♞,♜/8/♟,♟,♟,♟,♟,♟,♟,♟/8/8/♙,♙,♙,♙,♙,♙,♙,♙/8/♖,♘,♗,♔,♕,♗,♘,♖ B /')
  #
  # @example Shogi's starting position
  #   parse('l,n,s,g,k,g,s,n,l/1,r,5,b,1/p,p,p,p,p,p,p,p,p/9/9/9/P,P,P,P,P,P,P,P,P/1,B,5,R,1/L,N,S,G,K,G,S,N,L B /')
  #
  # @example Xiangqi's starting position
  #   parse('車,馬,象,士,將,士,象,馬,車/9/1,砲,5,砲,1/卒,1,卒,1,卒,1,卒,1,卒/9/9/兵,1,兵,1,兵,1,兵,1,兵/1,炮,5,炮,1/9/俥,傌,相,仕,帥,仕,相,傌,俥 B /')
  #
  # @return [Hash] The position params representing the position.
  def self.parse(feen_string)
    Parser.call(feen_string)
  end
end
