# frozen_string_literal: true

require_relative 'feen/dumper'
require_relative 'feen/parser'

# This module provides a Ruby interface for data serialization and
# deserialization in FEEN format.
#
# @see https://developer.sashite.com/specs/forsyth-edwards-expanded-notation
#
# @example Dump an empty 3x8x8 board position
#   FEEN.dump(
#     active_side_id: 0,
#     indexes: [3, 8, 8],
#     pieces_in_hand_grouped_by_sides: [
#       [],
#       []
#     ],
#     squares: Array.new(3 * 8 * 8)
#   )
#   # => "8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8 0 /"
#
# @example Dump Four-player chess's starting position
#   FEEN.dump(
#     active_side_id: 0,
#     indexes: [14, 14],
#     pieces_in_hand_grouped_by_sides: [
#       [],
#       [],
#       [],
#       []
#     ],
#     squares: [
#       nil , nil , nil , "yR", "yN", "yB", "yK", "yQ", "yB", "yN", "yR", nil , nil , nil ,
#       nil , nil , nil , "yP", "yP", "yP", "yP", "yP", "yP", "yP", "yP", nil , nil , nil ,
#       nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil ,
#       "bR", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gR",
#       "bN", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gN",
#       "bB", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gB",
#       "bK", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gQ",
#       "bQ", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gK",
#       "bB", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gB",
#       "bN", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gN",
#       "bR", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gR",
#       nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil ,
#       nil , nil , nil , "rP", "rP", "rP", "rP", "rP", "rP", "rP", "rP", nil , nil , nil ,
#       nil , nil , nil , "rR", "rN", "rB", "rQ", "rK", "rB", "rN", "rR", nil , nil , nil
#     ]
#   )
#   # => "3,yR,yN,yB,yK,yQ,yB,yN,yR,3/3,yP,yP,yP,yP,yP,yP,yP,yP,3/14/bR,bP,10,gP,gR/bN,bP,10,gP,gN/bB,bP,10,gP,gB/bK,bP,10,gP,gQ/bQ,bP,10,gP,gK/bB,bP,10,gP,gB/bN,bP,10,gP,gN/bR,bP,10,gP,gR/14/3,rP,rP,rP,rP,rP,rP,rP,rP,3/3,rR,rN,rB,rQ,rK,rB,rN,rR,3 0 ///"
#
# @example Dump Chess's starting position
#   FEEN.dump(
#     active_side_id: 0,
#     indexes: [8, 8],
#     pieces_in_hand_grouped_by_sides: [
#       [],
#       []
#     ],
#     squares: [
#       "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
#       "♟", "♟", "♟", "♟", "♟", "♟", "♟", "♟",
#       nil, nil, nil, nil, nil, nil, nil, nil,
#       nil, nil, nil, nil, nil, nil, nil, nil,
#       nil, nil, nil, nil, nil, nil, nil, nil,
#       nil, nil, nil, nil, nil, nil, nil, nil,
#       "♙", "♙", "♙", "♙", "♙", "♙", "♙", "♙",
#       "♖", "♘", "♗", "♕", "♔", "♗", "♘", "♖"
#     ]
#   )
#   # => "♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/8/8/♙,♙,♙,♙,♙,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ 0 /"
#
# @example Dump Chess's position after the move 1. e4
#   FEEN.dump(
#     active_side_id: 1,
#     indexes: [8, 8],
#     pieces_in_hand_grouped_by_sides: [
#       [],
#       []
#     ],
#     squares: [
#       "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
#       "♟", "♟", "♟", "♟", "♟", "♟", "♟", "♟",
#       nil, nil, nil, nil, nil, nil, nil, nil,
#       nil, nil, nil, nil, nil, nil, nil, nil,
#       nil, nil, nil, nil, "♙", nil, nil, nil,
#       nil, nil, nil, nil, nil, nil, nil, nil,
#       "♙", "♙", "♙", "♙", nil, "♙", "♙", "♙",
#       "♖", "♘", "♗", "♕", "♔", "♗", "♘", "♖"
#     ]
#   )
#   # => "♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/4,♙,3/8/♙,♙,♙,♙,1,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ 1 /"
#
# @example Dump Chess's position after the moves 1. e4 c5
#   FEEN.dump(
#     active_side_id: 0,
#     indexes: [8, 8],
#     pieces_in_hand_grouped_by_sides: [
#       [],
#       []
#     ],
#     squares: [
#       "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
#       "♟", "♟", "♟", "♟", nil, "♟", "♟", "♟",
#       nil, nil, nil, nil, nil, nil, nil, nil,
#       nil, nil, nil, nil, "♟", nil, nil, nil,
#       nil, nil, nil, nil, "♙", nil, nil, nil,
#       nil, nil, nil, nil, nil, nil, nil, nil,
#       "♙", "♙", "♙", "♙", nil, "♙", "♙", "♙",
#       "♖", "♘", "♗", "♕", "♔", "♗", "♘", "♖"
#     ]
#   )
#   # => "♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,1,♟,♟,♟/8/4,♟,3/4,♙,3/8/♙,♙,♙,♙,1,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ 0 /"
#
# @example Dump Makruk's starting position
#   FEEN.dump(
#     active_side_id: 0,
#     indexes: [8, 8],
#     pieces_in_hand_grouped_by_sides: [
#       [],
#       []
#     ],
#     squares: [
#       "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
#       nil, nil, nil, nil, nil, nil, nil, nil,
#       "♟", "♟", "♟", "♟", "♟", "♟", "♟", "♟",
#       nil, nil, nil, nil, nil, nil, nil, nil,
#       nil, nil, nil, nil, nil, nil, nil, nil,
#       "♙", "♙", "♙", "♙", "♙", "♙", "♙", "♙",
#       nil, nil, nil, nil, nil, nil, nil, nil,
#       "♖", "♘", "♗", "♔", "♕", "♗", "♘", "♖"
#     ]
#   )
#   # => "♜,♞,♝,♛,♚,♝,♞,♜/8/♟,♟,♟,♟,♟,♟,♟,♟/8/8/♙,♙,♙,♙,♙,♙,♙,♙/8/♖,♘,♗,♔,♕,♗,♘,♖ 0 /"
#
# @example Dump Shogi's starting position
#   FEEN.dump(
#     active_side_id: 0,
#     indexes: [9, 9],
#     pieces_in_hand_grouped_by_sides: [
#       [],
#       []
#     ],
#     squares: [
#       "l", "n", "s", "g", "k", "g", "s", "n", "l",
#       nil, "r", nil, nil, nil, nil, nil, "b", nil,
#       "p", "p", "p", "p", "p", "p", "p", "p", "p",
#       nil, nil, nil, nil, nil, nil, nil, nil, nil,
#       nil, nil, nil, nil, nil, nil, nil, nil, nil,
#       nil, nil, nil, nil, nil, nil, nil, nil, nil,
#       "P", "P", "P", "P", "P", "P", "P", "P", "P",
#       nil, "B", nil, nil, nil, nil, nil, "R", nil,
#       "L", "N", "S", "G", "K", "G", "S", "N", "L"
#     ]
#   )
#   # => "l,n,s,g,k,g,s,n,l/1,r,5,b,1/p,p,p,p,p,p,p,p,p/9/9/9/P,P,P,P,P,P,P,P,P/1,B,5,R,1/L,N,S,G,K,G,S,N,L 0 /"
#
# @example Dump a classic Tsume Shogi problem
#   FEEN.dump(
#     active_side_id: 0,
#     indexes: [9, 9],
#     pieces_in_hand_grouped_by_sides: [
#       %w[S],
#       %w[r r b g g g g s n n n n p p p p p p p p p p p p p p p p p]
#     ],
#     squares: [
#       nil, nil, nil, "s", "k", "s", nil, nil, nil,
#       nil, nil, nil, nil, nil, nil, nil, nil, nil,
#       nil, nil, nil, nil, "+P", nil, nil, nil, nil,
#       nil, nil, nil, nil, nil, nil, nil, nil, nil,
#       nil, nil, nil, nil, nil, nil, nil, "+B", nil,
#       nil, nil, nil, nil, nil, nil, nil, nil, nil,
#       nil, nil, nil, nil, nil, nil, nil, nil, nil,
#       nil, nil, nil, nil, nil, nil, nil, nil, nil,
#       nil, nil, nil, nil, nil, nil, nil, nil, nil
#     ]
#   )
#   # => "3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 0 S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s"
#
# @example Dump Xiangqi's starting position
#   FEEN.dump(
#     active_side_id: 0,
#     indexes: [10, 9],
#     pieces_in_hand_grouped_by_sides: [
#       [],
#       []
#     ],
#     squares: [
#       "車", "馬", "象", "士", "將", "士", "象", "馬", "車",
#       nil, nil, nil, nil, nil, nil, nil, nil, nil,
#       nil, "砲", nil, nil, nil, nil, nil, "砲", nil,
#       "卒", nil, "卒", nil, "卒", nil, "卒", nil, "卒",
#       nil, nil, nil, nil, nil, nil, nil, nil, nil,
#       nil, nil, nil, nil, nil, nil, nil, nil, nil,
#       "兵", nil, "兵", nil, "兵", nil, "兵", nil, "兵",
#       nil, "炮", nil, nil, nil, nil, nil, "炮", nil,
#       nil, nil, nil, nil, nil, nil, nil, nil, nil,
#       "俥", "傌", "相", "仕", "帥", "仕", "相", "傌", "俥"
#     ]
#   )
#   # => "車,馬,象,士,將,士,象,馬,車/9/1,砲,5,砲,1/卒,1,卒,1,卒,1,卒,1,卒/9/9/兵,1,兵,1,兵,1,兵,1,兵/1,炮,5,炮,1/9/俥,傌,相,仕,帥,仕,相,傌,俥 0 /"
#
# @example Parse an empty 3x8x8 board position
#   FEEN.parse("8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8 0 /")
#   # => {
#   #      active_side_id: 0,
#   #      indexes: [3, 8, 8],
#   #      pieces_in_hand_grouped_by_sides: [
#   #        [],
#   #        []
#   #      ],
#   #      squares: Array.new(3 * 8 * 8)
#   #    }
#
# @example Parse Four-player chess's starting position
#   FEEN.parse("3,yR,yN,yB,yK,yQ,yB,yN,yR,3/3,yP,yP,yP,yP,yP,yP,yP,yP,3/14/bR,bP,10,gP,gR/bN,bP,10,gP,gN/bB,bP,10,gP,gB/bK,bP,10,gP,gQ/bQ,bP,10,gP,gK/bB,bP,10,gP,gB/bN,bP,10,gP,gN/bR,bP,10,gP,gR/14/3,rP,rP,rP,rP,rP,rP,rP,rP,3/3,rR,rN,rB,rQ,rK,rB,rN,rR,3 0 ///")
#   # => {
#   #      active_side_id: 0,
#   #      indexes: [14, 14],
#   #      pieces_in_hand_grouped_by_sides: [
#   #        [],
#   #        [],
#   #        [],
#   #        []
#   #      ],
#   #      squares: [
#   #        nil , nil , nil , "yR", "yN", "yB", "yK", "yQ", "yB", "yN", "yR", nil , nil , nil ,
#   #        nil , nil , nil , "yP", "yP", "yP", "yP", "yP", "yP", "yP", "yP", nil , nil , nil ,
#   #        nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil ,
#   #        "bR", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gR",
#   #        "bN", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gN",
#   #        "bB", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gB",
#   #        "bK", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gQ",
#   #        "bQ", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gK",
#   #        "bB", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gB",
#   #        "bN", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gN",
#   #        "bR", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gR",
#   #        nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil ,
#   #        nil , nil , nil , "rP", "rP", "rP", "rP", "rP", "rP", "rP", "rP", nil , nil , nil ,
#   #        nil , nil , nil , "rR", "rN", "rB", "rQ", "rK", "rB", "rN", "rR", nil , nil , nil
#   #      ]
#   #    }
#
# @example Parse Chess's starting position
#   FEEN.parse("♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/8/8/♙,♙,♙,♙,♙,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ 0 /")
#   # => {
#   #      active_side_id: 0,
#   #      indexes: [8, 8],
#   #      pieces_in_hand_grouped_by_sides: [
#   #        [],
#   #        []
#   #      ],
#   #      squares: [
#   #        "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
#   #        "♟", "♟", "♟", "♟", "♟", "♟", "♟", "♟",
#   #        nil, nil, nil, nil, nil, nil, nil, nil,
#   #        nil, nil, nil, nil, nil, nil, nil, nil,
#   #        nil, nil, nil, nil, nil, nil, nil, nil,
#   #        nil, nil, nil, nil, nil, nil, nil, nil,
#   #        "♙", "♙", "♙", "♙", "♙", "♙", "♙", "♙",
#   #        "♖", "♘", "♗", "♕", "♔", "♗", "♘", "♖"
#   #      ]
#   #    }
#
# @example Parse Makruk's starting position
#   FEEN.parse("♜,♞,♝,♛,♚,♝,♞,♜/8/♟,♟,♟,♟,♟,♟,♟,♟/8/8/♙,♙,♙,♙,♙,♙,♙,♙/8/♖,♘,♗,♔,♕,♗,♘,♖ 0 /")
#   # => {
#   #      active_side_id: 0,
#   #      indexes: [8, 8],
#   #      pieces_in_hand_grouped_by_sides: [
#   #        [],
#   #        []
#   #      ],
#   #      squares: [
#   #        "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
#   #        nil, nil, nil, nil, nil, nil, nil, nil,
#   #        "♟", "♟", "♟", "♟", "♟", "♟", "♟", "♟",
#   #        nil, nil, nil, nil, nil, nil, nil, nil,
#   #        nil, nil, nil, nil, nil, nil, nil, nil,
#   #        "♙", "♙", "♙", "♙", "♙", "♙", "♙", "♙",
#   #        nil, nil, nil, nil, nil, nil, nil, nil,
#   #        "♖", "♘", "♗", "♔", "♕", "♗", "♘", "♖"
#   #      ]
#   #    }
#
# @example Parse Shogi's starting position
#   FEEN.parse("l,n,s,g,k,g,s,n,l/1,r,5,b,1/p,p,p,p,p,p,p,p,p/9/9/9/P,P,P,P,P,P,P,P,P/1,B,5,R,1/L,N,S,G,K,G,S,N,L 0 /")
#   # => {
#   #      active_side_id: 0,
#   #      indexes: [9, 9],
#   #      pieces_in_hand_grouped_by_sides: [
#   #        [],
#   #        []
#   #      ],
#   #      squares: [
#   #        "l", "n", "s", "g", "k", "g", "s", "n", "l",
#   #        nil, "r", nil, nil, nil, nil, nil, "b", nil,
#   #        "p", "p", "p", "p", "p", "p", "p", "p", "p",
#   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#   #        "P", "P", "P", "P", "P", "P", "P", "P", "P",
#   #        nil, "B", nil, nil, nil, nil, nil, "R", nil,
#   #        "L", "N", "S", "G", "K", "G", "S", "N", "L"
#   #      ]
#   #    }
#
# @example Parse a classic Tsume Shogi problem
#   FEEN.parse("3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 0 S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s")
#   # => {
#   #      active_side_id: 0,
#   #      indexes: [9, 9],
#   #      pieces_in_hand_grouped_by_sides: [
#   #        %w[S],
#   #        %w[b g g g g n n n n p p p p p p p p p p p p p p p p p r r s]
#   #      ],
#   #      squares: [
#   #        nil, nil, nil, "s", "k", "s", nil, nil, nil,
#   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#   #        nil, nil, nil, nil, "+P", nil, nil, nil, nil,
#   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#   #        nil, nil, nil, nil, nil, nil, nil, "+B", nil,
#   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#   #        nil, nil, nil, nil, nil, nil, nil, nil, nil
#   #      ]
#   #    }
#
# @example Parse Xiangqi's starting position
#   FEEN.parse("車,馬,象,士,將,士,象,馬,車/9/1,砲,5,砲,1/卒,1,卒,1,卒,1,卒,1,卒/9/9/兵,1,兵,1,兵,1,兵,1,兵/1,炮,5,炮,1/9/俥,傌,相,仕,帥,仕,相,傌,俥 0 /")
#   # => {
#   #      active_side_id: 0,
#   #      indexes: [10, 9],
#   #      pieces_in_hand_grouped_by_sides: [
#   #        [],
#   #        []
#   #      ],
#   #      squares: [
#   #        "車", "馬", "象", "士", "將", "士", "象", "馬", "車",
#   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#   #        nil, "砲", nil, nil, nil, nil, nil, "砲", nil,
#   #        "卒", nil, "卒", nil, "卒", nil, "卒", nil, "卒",
#   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#   #        "兵", nil, "兵", nil, "兵", nil, "兵", nil, "兵",
#   #        nil, "炮", nil, nil, nil, nil, nil, "炮", nil,
#   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#   #        "俥", "傌", "相", "仕", "帥", "仕", "相", "傌", "俥"
#   #      ]
#   #    }
module FEEN
  # @example Dumps position params into a FEEN string.
  #
  # @param active_side_id [Integer] The identifier of the player who must play.
  # @param indexes [Array] The shape of the board.
  # @param pieces_in_hand_grouped_by_sides [Array] The list of pieces in hand
  #   grouped by players.
  # @param squares [Array] The list of squares on the board.
  #
  # @example Dump an empty 3x8x8 board position
  #   dump(
  #     active_side_id: 0,
  #     indexes: [3, 8, 8],
  #     pieces_in_hand_grouped_by_sides: [
  #       [],
  #       []
  #     ],
  #     squares: Array.new(3 * 8 * 8)
  #   )
  #   # => "8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8 0 /"
  #
  # @example Dump Four-player chess's starting position
  #   dump(
  #     active_side_id: 0,
  #     indexes: [14, 14],
  #     pieces_in_hand_grouped_by_sides: [
  #       [],
  #       [],
  #       [],
  #       []
  #     ],
  #     squares: [
  #       nil , nil , nil , "yR", "yN", "yB", "yK", "yQ", "yB", "yN", "yR", nil , nil , nil ,
  #       nil , nil , nil , "yP", "yP", "yP", "yP", "yP", "yP", "yP", "yP", nil , nil , nil ,
  #       nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil ,
  #       "bR", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gR",
  #       "bN", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gN",
  #       "bB", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gB",
  #       "bK", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gQ",
  #       "bQ", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gK",
  #       "bB", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gB",
  #       "bN", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gN",
  #       "bR", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gR",
  #       nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil ,
  #       nil , nil , nil , "rP", "rP", "rP", "rP", "rP", "rP", "rP", "rP", nil , nil , nil ,
  #       nil , nil , nil , "rR", "rN", "rB", "rQ", "rK", "rB", "rN", "rR", nil , nil , nil
  #     ]
  #   )
  #   # => "3,yR,yN,yB,yK,yQ,yB,yN,yR,3/3,yP,yP,yP,yP,yP,yP,yP,yP,3/14/bR,bP,10,gP,gR/bN,bP,10,gP,gN/bB,bP,10,gP,gB/bK,bP,10,gP,gQ/bQ,bP,10,gP,gK/bB,bP,10,gP,gB/bN,bP,10,gP,gN/bR,bP,10,gP,gR/14/3,rP,rP,rP,rP,rP,rP,rP,rP,3/3,rR,rN,rB,rQ,rK,rB,rN,rR,3 0 ///"
  #
  # @example Dump Chess's starting position
  #   dump(
  #     active_side_id: 0,
  #     indexes: [8, 8],
  #     pieces_in_hand_grouped_by_sides: [
  #       [],
  #       []
  #     ],
  #     squares: [
  #       "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
  #       "♟", "♟", "♟", "♟", "♟", "♟", "♟", "♟",
  #       nil, nil, nil, nil, nil, nil, nil, nil,
  #       nil, nil, nil, nil, nil, nil, nil, nil,
  #       nil, nil, nil, nil, nil, nil, nil, nil,
  #       nil, nil, nil, nil, nil, nil, nil, nil,
  #       "♙", "♙", "♙", "♙", "♙", "♙", "♙", "♙",
  #       "♖", "♘", "♗", "♕", "♔", "♗", "♘", "♖"
  #     ]
  #   )
  #   # => "♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/8/8/♙,♙,♙,♙,♙,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ 0 /"
  #
  # @example Dump Chess's position after the move 1. e4
  #   dump(
  #     active_side_id: 1,
  #     indexes: [8, 8],
  #     pieces_in_hand_grouped_by_sides: [
  #       [],
  #       []
  #     ],
  #     squares: [
  #       "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
  #       "♟", "♟", "♟", "♟", "♟", "♟", "♟", "♟",
  #       nil, nil, nil, nil, nil, nil, nil, nil,
  #       nil, nil, nil, nil, nil, nil, nil, nil,
  #       nil, nil, nil, nil, "♙", nil, nil, nil,
  #       nil, nil, nil, nil, nil, nil, nil, nil,
  #       "♙", "♙", "♙", "♙", nil, "♙", "♙", "♙",
  #       "♖", "♘", "♗", "♕", "♔", "♗", "♘", "♖"
  #     ]
  #   )
  #   # => "♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/4,♙,3/8/♙,♙,♙,♙,1,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ 1 /"
  #
  # @example Dump Chess's position after the moves 1. e4 c5
  #   dump(
  #     active_side_id: 0,
  #     indexes: [8, 8],
  #     pieces_in_hand_grouped_by_sides: [
  #       [],
  #       []
  #     ],
  #     squares: [
  #       "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
  #       "♟", "♟", "♟", "♟", nil, "♟", "♟", "♟",
  #       nil, nil, nil, nil, nil, nil, nil, nil,
  #       nil, nil, nil, nil, "♟", nil, nil, nil,
  #       nil, nil, nil, nil, "♙", nil, nil, nil,
  #       nil, nil, nil, nil, nil, nil, nil, nil,
  #       "♙", "♙", "♙", "♙", nil, "♙", "♙", "♙",
  #       "♖", "♘", "♗", "♕", "♔", "♗", "♘", "♖"
  #     ]
  #   )
  #   # => "♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,1,♟,♟,♟/8/4,♟,3/4,♙,3/8/♙,♙,♙,♙,1,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ 0 /"
  #
  # @example Dump Makruk's starting position
  #   dump(
  #     active_side_id: 0,
  #     indexes: [8, 8],
  #     pieces_in_hand_grouped_by_sides: [
  #       [],
  #       []
  #     ],
  #     squares: [
  #       "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
  #       nil, nil, nil, nil, nil, nil, nil, nil,
  #       "♟", "♟", "♟", "♟", "♟", "♟", "♟", "♟",
  #       nil, nil, nil, nil, nil, nil, nil, nil,
  #       nil, nil, nil, nil, nil, nil, nil, nil,
  #       "♙", "♙", "♙", "♙", "♙", "♙", "♙", "♙",
  #       nil, nil, nil, nil, nil, nil, nil, nil,
  #       "♖", "♘", "♗", "♔", "♕", "♗", "♘", "♖"
  #     ]
  #   )
  #   # => "♜,♞,♝,♛,♚,♝,♞,♜/8/♟,♟,♟,♟,♟,♟,♟,♟/8/8/♙,♙,♙,♙,♙,♙,♙,♙/8/♖,♘,♗,♔,♕,♗,♘,♖ 0 /"
  #
  # @example Dump Shogi's starting position
  #   dump(
  #     active_side_id: 0,
  #     indexes: [9, 9],
  #     pieces_in_hand_grouped_by_sides: [
  #       [],
  #       []
  #     ],
  #     squares: [
  #       "l", "n", "s", "g", "k", "g", "s", "n", "l",
  #       nil, "r", nil, nil, nil, nil, nil, "b", nil,
  #       "p", "p", "p", "p", "p", "p", "p", "p", "p",
  #       nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #       nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #       nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #       "P", "P", "P", "P", "P", "P", "P", "P", "P",
  #       nil, "B", nil, nil, nil, nil, nil, "R", nil,
  #       "L", "N", "S", "G", "K", "G", "S", "N", "L"
  #     ]
  #   )
  #   # => "l,n,s,g,k,g,s,n,l/1,r,5,b,1/p,p,p,p,p,p,p,p,p/9/9/9/P,P,P,P,P,P,P,P,P/1,B,5,R,1/L,N,S,G,K,G,S,N,L 0 /"
  #
  # @example Dump a classic Tsume Shogi problem
  #   dump(
  #     active_side_id: 0,
  #     indexes: [9, 9],
  #     pieces_in_hand_grouped_by_sides: [
  #       %w[S],
  #       %w[r r b g g g g s n n n n p p p p p p p p p p p p p p p p p]
  #     ],
  #     squares: [
  #       nil, nil, nil, "s", "k", "s", nil, nil, nil,
  #       nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #       nil, nil, nil, nil, "+P", nil, nil, nil, nil,
  #       nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #       nil, nil, nil, nil, nil, nil, nil, "+B", nil,
  #       nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #       nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #       nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #       nil, nil, nil, nil, nil, nil, nil, nil, nil
  #     ]
  #   )
  #   # => "3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 0 S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s"
  #
  # @example Dump Xiangqi's starting position
  #   dump(
  #     active_side_id: 0,
  #     indexes: [10, 9],
  #     pieces_in_hand_grouped_by_sides: [
  #       [],
  #       []
  #     ],
  #     squares: [
  #       "車", "馬", "象", "士", "將", "士", "象", "馬", "車",
  #       nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #       nil, "砲", nil, nil, nil, nil, nil, "砲", nil,
  #       "卒", nil, "卒", nil, "卒", nil, "卒", nil, "卒",
  #       nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #       nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #       "兵", nil, "兵", nil, "兵", nil, "兵", nil, "兵",
  #       nil, "炮", nil, nil, nil, nil, nil, "炮", nil,
  #       nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #       "俥", "傌", "相", "仕", "帥", "仕", "相", "傌", "俥"
  #     ]
  #   )
  #   # => "車,馬,象,士,將,士,象,馬,車/9/1,砲,5,砲,1/卒,1,卒,1,卒,1,卒,1,卒/9/9/兵,1,兵,1,兵,1,兵,1,兵/1,炮,5,炮,1/9/俥,傌,相,仕,帥,仕,相,傌,俥 0 /"
  #
  # @return [String] The FEEN string representing the position.
  def self.dump(active_side_id:, indexes:, pieces_in_hand_grouped_by_sides:, squares:)
    Dumper.call(
      active_side_id: active_side_id,
      indexes: indexes,
      pieces_in_hand_grouped_by_sides: pieces_in_hand_grouped_by_sides,
      squares: squares
    )
  end

  # Parses a FEEN string into position params.
  #
  # @param feen [String] The FEEN string representing a position.
  #
  # @example Parse an empty 3x8x8 board position
  #   parse("8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8 0 /")
  #   # => {
  #   #      active_side_id: 0,
  #   #      indexes: [3, 8, 8],
  #   #      pieces_in_hand_grouped_by_sides: [
  #   #        [],
  #   #        []
  #   #      ],
  #   #      squares: Array.new(3 * 8 * 8)
  #   #    }
  #
  # @example Parse Four-player chess's starting position
  #   parse("3,yR,yN,yB,yK,yQ,yB,yN,yR,3/3,yP,yP,yP,yP,yP,yP,yP,yP,3/14/bR,bP,10,gP,gR/bN,bP,10,gP,gN/bB,bP,10,gP,gB/bK,bP,10,gP,gQ/bQ,bP,10,gP,gK/bB,bP,10,gP,gB/bN,bP,10,gP,gN/bR,bP,10,gP,gR/14/3,rP,rP,rP,rP,rP,rP,rP,rP,3/3,rR,rN,rB,rQ,rK,rB,rN,rR,3 0 ///")
  #   # => {
  #   #      active_side_id: 0,
  #   #      indexes: [14, 14],
  #   #      pieces_in_hand_grouped_by_sides: [
  #   #        [],
  #   #        [],
  #   #        [],
  #   #        []
  #   #      ],
  #   #      squares: [
  #   #        nil , nil , nil , "yR", "yN", "yB", "yK", "yQ", "yB", "yN", "yR", nil , nil , nil ,
  #   #        nil , nil , nil , "yP", "yP", "yP", "yP", "yP", "yP", "yP", "yP", nil , nil , nil ,
  #   #        nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil ,
  #   #        "bR", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gR",
  #   #        "bN", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gN",
  #   #        "bB", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gB",
  #   #        "bK", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gQ",
  #   #        "bQ", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gK",
  #   #        "bB", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gB",
  #   #        "bN", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gN",
  #   #        "bR", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gR",
  #   #        nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil ,
  #   #        nil , nil , nil , "rP", "rP", "rP", "rP", "rP", "rP", "rP", "rP", nil , nil , nil ,
  #   #        nil , nil , nil , "rR", "rN", "rB", "rQ", "rK", "rB", "rN", "rR", nil , nil , nil
  #   #      ]
  #   #    }
  #
  # @example Parse Chess's starting position
  #   parse("♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/8/8/♙,♙,♙,♙,♙,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ 0 /")
  #   # => {
  #   #      active_side_id: 0,
  #   #      indexes: [8, 8],
  #   #      pieces_in_hand_grouped_by_sides: [
  #   #        [],
  #   #        []
  #   #      ],
  #   #      squares: [
  #   #        "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
  #   #        "♟", "♟", "♟", "♟", "♟", "♟", "♟", "♟",
  #   #        nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        "♙", "♙", "♙", "♙", "♙", "♙", "♙", "♙",
  #   #        "♖", "♘", "♗", "♕", "♔", "♗", "♘", "♖"
  #   #      ]
  #   #    }
  #
  # @example Parse Makruk's starting position
  #   parse("♜,♞,♝,♛,♚,♝,♞,♜/8/♟,♟,♟,♟,♟,♟,♟,♟/8/8/♙,♙,♙,♙,♙,♙,♙,♙/8/♖,♘,♗,♔,♕,♗,♘,♖ 0 /")
  #   # => {
  #   #      active_side_id: 0,
  #   #      indexes: [8, 8],
  #   #      pieces_in_hand_grouped_by_sides: [
  #   #        [],
  #   #        []
  #   #      ],
  #   #      squares: [
  #   #        "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
  #   #        nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        "♟", "♟", "♟", "♟", "♟", "♟", "♟", "♟",
  #   #        nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        "♙", "♙", "♙", "♙", "♙", "♙", "♙", "♙",
  #   #        nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        "♖", "♘", "♗", "♔", "♕", "♗", "♘", "♖"
  #   #      ]
  #   #    }
  #
  # @example Parse Shogi's starting position
  #   parse("l,n,s,g,k,g,s,n,l/1,r,5,b,1/p,p,p,p,p,p,p,p,p/9/9/9/P,P,P,P,P,P,P,P,P/1,B,5,R,1/L,N,S,G,K,G,S,N,L 0 /")
  #   # => {
  #   #      active_side_id: 0,
  #   #      indexes: [9, 9],
  #   #      pieces_in_hand_grouped_by_sides: [
  #   #        [],
  #   #        []
  #   #      ],
  #   #      squares: [
  #   #        "l", "n", "s", "g", "k", "g", "s", "n", "l",
  #   #        nil, "r", nil, nil, nil, nil, nil, "b", nil,
  #   #        "p", "p", "p", "p", "p", "p", "p", "p", "p",
  #   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        "P", "P", "P", "P", "P", "P", "P", "P", "P",
  #   #        nil, "B", nil, nil, nil, nil, nil, "R", nil,
  #   #        "L", "N", "S", "G", "K", "G", "S", "N", "L"
  #   #      ]
  #   #    }
  #
  # @example Parse a classic Tsume Shogi problem
  #   parse("3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 0 S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s")
  #   # => {
  #   #      active_side_id: 0,
  #   #      indexes: [9, 9],
  #   #      pieces_in_hand_grouped_by_sides: [
  #   #        %w[S],
  #   #        %w[b g g g g n n n n p p p p p p p p p p p p p p p p p r r s]
  #   #      ],
  #   #      squares: [
  #   #        nil, nil, nil, "s", "k", "s", nil, nil, nil,
  #   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        nil, nil, nil, nil, "+P", nil, nil, nil, nil,
  #   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        nil, nil, nil, nil, nil, nil, nil, "+B", nil,
  #   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        nil, nil, nil, nil, nil, nil, nil, nil, nil
  #   #      ]
  #   #    }
  #
  # @example Parse Xiangqi's starting position
  #   parse("車,馬,象,士,將,士,象,馬,車/9/1,砲,5,砲,1/卒,1,卒,1,卒,1,卒,1,卒/9/9/兵,1,兵,1,兵,1,兵,1,兵/1,炮,5,炮,1/9/俥,傌,相,仕,帥,仕,相,傌,俥 0 /")
  #   # => {
  #   #      active_side_id: 0,
  #   #      indexes: [10, 9],
  #   #      pieces_in_hand_grouped_by_sides: [
  #   #        [],
  #   #        []
  #   #      ],
  #   #      squares: [
  #   #        "車", "馬", "象", "士", "將", "士", "象", "馬", "車",
  #   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        nil, "砲", nil, nil, nil, nil, nil, "砲", nil,
  #   #        "卒", nil, "卒", nil, "卒", nil, "卒", nil, "卒",
  #   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        "兵", nil, "兵", nil, "兵", nil, "兵", nil, "兵",
  #   #        nil, "炮", nil, nil, nil, nil, nil, "炮", nil,
  #   #        nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #   #        "俥", "傌", "相", "仕", "帥", "仕", "相", "傌", "俥"
  #   #      ]
  #   #    }
  # @return [Hash] The position params representing the position.
  def self.parse(feen)
    Parser.call(feen)
  end
end
