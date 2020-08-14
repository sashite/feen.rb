# frozen_string_literal: true

require_relative 'feen/dumper'
require_relative 'feen/parser'

# This module provides a Ruby interface for data serialization and
# deserialization in FEEN format.
#
# @see https://developer.sashite.com/specs/forsyth-edwards-expanded-notation
#
# @example Dump Chess's starting position
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
# @example Parse Chess's starting position
#   FEEN.parse('♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/8/8/♙,♙,♙,♙,♙,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ B /')
#
# @example Dump Makruk's starting position
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
# @example Parse Makruk's starting position
#   FEEN.parse('♜,♞,♝,♛,♚,♝,♞,♜/8/♟,♟,♟,♟,♟,♟,♟,♟/8/8/♙,♙,♙,♙,♙,♙,♙,♙/8/♖,♘,♗,♔,♕,♗,♘,♖ B /')
#
# @example Dump Shogi's starting position
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
# @example Parse Shogi's starting position
#   FEEN.parse('l,n,s,g,k,g,s,n,l/1,r,5,b,1/p,p,p,p,p,p,p,p,p/9/9/9/P,P,P,P,P,P,P,P,P/1,B,5,R,1/L,N,S,G,K,G,S,N,L B /')
#
# @example Dump Xiangqi's starting position
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
#
# @example Parse Xiangqi's starting position
#   FEEN.parse('車,馬,象,士,將,士,象,馬,車/9/1,砲,5,砲,1/卒,1,卒,1,卒,1,卒,1,卒/9/9/兵,1,兵,1,兵,1,兵,1,兵/1,炮,5,炮,1/9/俥,傌,相,仕,帥,仕,相,傌,俥 B /')
#
module FEEN
  # Dumps position params into a FEEN string.
  #
  # @param indexes [Array] The shape of the board.
  # @param squares [Array] The list of squares of on the board.
  # @param is_turn_to_topside [Boolean] The player who must play.
  # @param bottomside_in_hand_pieces [Array] The list of bottom-side's pieces in hand.
  # @param topside_in_hand_pieces [Array] The list of top-side's pieces in hand.
  #
  # @example Dump Chess's starting position
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
  # @example Dump Makruk's starting position
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
  # @example Dump Shogi's starting position
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
  # @example Dump Xiangqi's starting position
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
  # @example Dump a classic Tsume Shogi problem
  #   dump([9, 9],
  #     nil, nil, nil, 's', 'k', 's', nil, nil, nil,
  #     nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #     nil, nil, nil, nil, '+P', nil, nil, nil, nil,
  #     nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #     nil, nil, nil, nil, nil, nil, nil, '+B', nil,
  #     nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #     nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #     nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #     nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #     is_turn_to_topside: false,
  #     bottomside_in_hand_pieces: %w[S],
  #     topside_in_hand_pieces: %w[r r b g g g g s n n n n p p p p p p p p p p p p p p p p p]
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
  # @example Parse Chess's starting position
  #   parse('♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/8/8/♙,♙,♙,♙,♙,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ B /')
  #
  # @example Parse Makruk's starting position
  #   parse('♜,♞,♝,♛,♚,♝,♞,♜/8/♟,♟,♟,♟,♟,♟,♟,♟/8/8/♙,♙,♙,♙,♙,♙,♙,♙/8/♖,♘,♗,♔,♕,♗,♘,♖ B /')
  #
  # @example Parse Shogi's starting position
  #   parse('l,n,s,g,k,g,s,n,l/1,r,5,b,1/p,p,p,p,p,p,p,p,p/9/9/9/P,P,P,P,P,P,P,P,P/1,B,5,R,1/L,N,S,G,K,G,S,N,L B /')
  #
  # @example Parse Xiangqi's starting position
  #   parse('車,馬,象,士,將,士,象,馬,車/9/1,砲,5,砲,1/卒,1,卒,1,卒,1,卒,1,卒/9/9/兵,1,兵,1,兵,1,兵,1,兵/1,炮,5,炮,1/9/俥,傌,相,仕,帥,仕,相,傌,俥 B /')
  #
  # @example Parse a classic Tsume Shogi problem
  #   parse('3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 B S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s')
  #
  # @return [Hash] The position params representing the position.
  def self.parse(feen_string)
    Parser.call(feen_string)
  end
end
