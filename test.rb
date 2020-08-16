# frozen_string_literal: false

require 'simplecov'

::SimpleCov.command_name 'Brutal test suite'
::SimpleCov.start

require_relative "lib/feen"

# Dump an empty 3x8x8 board position
raise unless FEEN.dump(
  active_side_id: 0,
  indexes: [3, 8, 8],
  pieces_in_hand_grouped_by_sides: [
    [],
    []
  ],
  squares: Array.new(3 * 8 * 8)
) == "8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8 0 /"

# Dump Four-player chess's starting position
raise unless FEEN.dump(
  active_side_id: 0,
  indexes: [14, 14],
  pieces_in_hand_grouped_by_sides: [
    [],
    [],
    [],
    []
  ],
  squares: [
    nil , nil , nil , "yR", "yN", "yB", "yK", "yQ", "yB", "yN", "yR", nil , nil , nil ,
    nil , nil , nil , "yP", "yP", "yP", "yP", "yP", "yP", "yP", "yP", nil , nil , nil ,
    nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil ,
    "bR", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gR",
    "bN", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gN",
    "bB", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gB",
    "bK", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gQ",
    "bQ", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gK",
    "bB", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gB",
    "bN", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gN",
    "bR", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gR",
    nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil ,
    nil , nil , nil , "rP", "rP", "rP", "rP", "rP", "rP", "rP", "rP", nil , nil , nil ,
    nil , nil , nil , "rR", "rN", "rB", "rQ", "rK", "rB", "rN", "rR", nil , nil , nil
  ]
) == "3,yR,yN,yB,yK,yQ,yB,yN,yR,3/3,yP,yP,yP,yP,yP,yP,yP,yP,3/14/bR,bP,10,gP,gR/bN,bP,10,gP,gN/bB,bP,10,gP,gB/bK,bP,10,gP,gQ/bQ,bP,10,gP,gK/bB,bP,10,gP,gB/bN,bP,10,gP,gN/bR,bP,10,gP,gR/14/3,rP,rP,rP,rP,rP,rP,rP,rP,3/3,rR,rN,rB,rQ,rK,rB,rN,rR,3 0 ///"

# Dump Chess's starting position
raise unless FEEN.dump(
  active_side_id: 0,
  indexes: [8, 8],
  pieces_in_hand_grouped_by_sides: [
    [],
    []
  ],
  squares: [
    "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
    "♟", "♟", "♟", "♟", "♟", "♟", "♟", "♟",
    nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil,
    "♙", "♙", "♙", "♙", "♙", "♙", "♙", "♙",
    "♖", "♘", "♗", "♕", "♔", "♗", "♘", "♖"
  ]
) == "♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/8/8/♙,♙,♙,♙,♙,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ 0 /"

# Dump Chess's position after the move 1. e4
raise unless FEEN.dump(
  active_side_id: 1,
  indexes: [8, 8],
  pieces_in_hand_grouped_by_sides: [
    [],
    []
  ],
  squares: [
    "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
    "♟", "♟", "♟", "♟", "♟", "♟", "♟", "♟",
    nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, "♙", nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil,
    "♙", "♙", "♙", "♙", nil, "♙", "♙", "♙",
    "♖", "♘", "♗", "♕", "♔", "♗", "♘", "♖"
  ]
) == "♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/4,♙,3/8/♙,♙,♙,♙,1,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ 1 /"

# Dump Chess's position after the moves 1. e4 c5
raise unless FEEN.dump(
  active_side_id: 0,
  indexes: [8, 8],
  pieces_in_hand_grouped_by_sides: [
    [],
    []
  ],
  squares: [
    "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
    "♟", "♟", "♟", "♟", nil, "♟", "♟", "♟",
    nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, "♟", nil, nil, nil,
    nil, nil, nil, nil, "♙", nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil,
    "♙", "♙", "♙", "♙", nil, "♙", "♙", "♙",
    "♖", "♘", "♗", "♕", "♔", "♗", "♘", "♖"
  ]
) == "♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,1,♟,♟,♟/8/4,♟,3/4,♙,3/8/♙,♙,♙,♙,1,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ 0 /"

# Dump Makruk's starting position
raise unless FEEN.dump(
  active_side_id: 0,
  indexes: [8, 8],
  pieces_in_hand_grouped_by_sides: [
    [],
    []
  ],
  squares: [
    "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
    nil, nil, nil, nil, nil, nil, nil, nil,
    "♟", "♟", "♟", "♟", "♟", "♟", "♟", "♟",
    nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil,
    "♙", "♙", "♙", "♙", "♙", "♙", "♙", "♙",
    nil, nil, nil, nil, nil, nil, nil, nil,
    "♖", "♘", "♗", "♔", "♕", "♗", "♘", "♖"
  ]
) == "♜,♞,♝,♛,♚,♝,♞,♜/8/♟,♟,♟,♟,♟,♟,♟,♟/8/8/♙,♙,♙,♙,♙,♙,♙,♙/8/♖,♘,♗,♔,♕,♗,♘,♖ 0 /"

# Dump Shogi's starting position
raise unless FEEN.dump(
  active_side_id: 0,
  indexes: [9, 9],
  pieces_in_hand_grouped_by_sides: [
    [],
    []
  ],
  squares: [
    "l", "n", "s", "g", "k", "g", "s", "n", "l",
    nil, "r", nil, nil, nil, nil, nil, "b", nil,
    "p", "p", "p", "p", "p", "p", "p", "p", "p",
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    "P", "P", "P", "P", "P", "P", "P", "P", "P",
    nil, "B", nil, nil, nil, nil, nil, "R", nil,
    "L", "N", "S", "G", "K", "G", "S", "N", "L"
  ]
) == "l,n,s,g,k,g,s,n,l/1,r,5,b,1/p,p,p,p,p,p,p,p,p/9/9/9/P,P,P,P,P,P,P,P,P/1,B,5,R,1/L,N,S,G,K,G,S,N,L 0 /"

# Dump a classic Tsume Shogi problem
raise unless FEEN.dump(
  active_side_id: 0,
  indexes: [9, 9],
  pieces_in_hand_grouped_by_sides: [
    %w[S],
    %w[r r b g g g g s n n n n p p p p p p p p p p p p p p p p p]
  ],
  squares: [
    nil, nil, nil, "s", "k", "s", nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, "+P", nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, "+B", nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil
  ]
) == "3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 0 S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s"

# Dump Xiangqi's starting position
raise unless FEEN.dump(
  active_side_id: 0,
  indexes: [10, 9],
  pieces_in_hand_grouped_by_sides: [
    [],
    []
  ],
  squares: [
    "車", "馬", "象", "士", "將", "士", "象", "馬", "車",
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, "砲", nil, nil, nil, nil, nil, "砲", nil,
    "卒", nil, "卒", nil, "卒", nil, "卒", nil, "卒",
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    "兵", nil, "兵", nil, "兵", nil, "兵", nil, "兵",
    nil, "炮", nil, nil, nil, nil, nil, "炮", nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    "俥", "傌", "相", "仕", "帥", "仕", "相", "傌", "俥"
  ]
) == "車,馬,象,士,將,士,象,馬,車/9/1,砲,5,砲,1/卒,1,卒,1,卒,1,卒,1,卒/9/9/兵,1,兵,1,兵,1,兵,1,兵/1,炮,5,炮,1/9/俥,傌,相,仕,帥,仕,相,傌,俥 0 /"

# Parse an empty 3x8x8 board position
raise unless FEEN.parse("8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8 0 /").eql?(
  active_side_id: 0,
  indexes: [3, 8, 8],
  pieces_in_hand_grouped_by_sides: [
    [],
    []
  ],
  squares: Array.new(3 * 8 * 8)
)

# Parse Four-player chess's starting position
raise unless FEEN.parse("3,yR,yN,yB,yK,yQ,yB,yN,yR,3/3,yP,yP,yP,yP,yP,yP,yP,yP,3/14/bR,bP,10,gP,gR/bN,bP,10,gP,gN/bB,bP,10,gP,gB/bK,bP,10,gP,gQ/bQ,bP,10,gP,gK/bB,bP,10,gP,gB/bN,bP,10,gP,gN/bR,bP,10,gP,gR/14/3,rP,rP,rP,rP,rP,rP,rP,rP,3/3,rR,rN,rB,rQ,rK,rB,rN,rR,3 0 ///").eql?(
  active_side_id: 0,
  indexes: [14, 14],
  pieces_in_hand_grouped_by_sides: [
    [],
    [],
    [],
    []
  ],
  squares: [
    nil , nil , nil , "yR", "yN", "yB", "yK", "yQ", "yB", "yN", "yR", nil , nil , nil ,
    nil , nil , nil , "yP", "yP", "yP", "yP", "yP", "yP", "yP", "yP", nil , nil , nil ,
    nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil ,
    "bR", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gR",
    "bN", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gN",
    "bB", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gB",
    "bK", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gQ",
    "bQ", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gK",
    "bB", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gB",
    "bN", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gN",
    "bR", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gR",
    nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil ,
    nil , nil , nil , "rP", "rP", "rP", "rP", "rP", "rP", "rP", "rP", nil , nil , nil ,
    nil , nil , nil , "rR", "rN", "rB", "rQ", "rK", "rB", "rN", "rR", nil , nil , nil
  ]
)

# Parse Chess's starting position
raise unless FEEN.parse("♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/8/8/♙,♙,♙,♙,♙,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ 0 /").eql?(
  active_side_id: 0,
  indexes: [8, 8],
  pieces_in_hand_grouped_by_sides: [
    [],
    []
  ],
  squares: [
    "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
    "♟", "♟", "♟", "♟", "♟", "♟", "♟", "♟",
    nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil,
    "♙", "♙", "♙", "♙", "♙", "♙", "♙", "♙",
    "♖", "♘", "♗", "♕", "♔", "♗", "♘", "♖"
  ]
)

# Parse Makruk's starting position
raise unless FEEN.parse("♜,♞,♝,♛,♚,♝,♞,♜/8/♟,♟,♟,♟,♟,♟,♟,♟/8/8/♙,♙,♙,♙,♙,♙,♙,♙/8/♖,♘,♗,♔,♕,♗,♘,♖ 0 /").eql?(
  active_side_id: 0,
  indexes: [8, 8],
  pieces_in_hand_grouped_by_sides: [
    [],
    []
  ],
  squares: [
    "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
    nil, nil, nil, nil, nil, nil, nil, nil,
    "♟", "♟", "♟", "♟", "♟", "♟", "♟", "♟",
    nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil,
    "♙", "♙", "♙", "♙", "♙", "♙", "♙", "♙",
    nil, nil, nil, nil, nil, nil, nil, nil,
    "♖", "♘", "♗", "♔", "♕", "♗", "♘", "♖"
  ]
)

# Parse Shogi's starting position
raise unless FEEN.parse("l,n,s,g,k,g,s,n,l/1,r,5,b,1/p,p,p,p,p,p,p,p,p/9/9/9/P,P,P,P,P,P,P,P,P/1,B,5,R,1/L,N,S,G,K,G,S,N,L 0 /").eql?(
  active_side_id: 0,
  indexes: [9, 9],
  pieces_in_hand_grouped_by_sides: [
    [],
    []
  ],
  squares: [
    "l", "n", "s", "g", "k", "g", "s", "n", "l",
    nil, "r", nil, nil, nil, nil, nil, "b", nil,
    "p", "p", "p", "p", "p", "p", "p", "p", "p",
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    "P", "P", "P", "P", "P", "P", "P", "P", "P",
    nil, "B", nil, nil, nil, nil, nil, "R", nil,
    "L", "N", "S", "G", "K", "G", "S", "N", "L"
  ]
)

# Parse a classic Tsume Shogi problem
raise unless FEEN.parse("3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 0 S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s").eql?(
  active_side_id: 0,
  indexes: [9, 9],
  pieces_in_hand_grouped_by_sides: [
    %w[S],
    %w[b g g g g n n n n p p p p p p p p p p p p p p p p p r r s]
  ],
  squares: [
    nil, nil, nil, "s", "k", "s", nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, "+P", nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, "+B", nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil
  ]
)

# Parse Xiangqi's starting position
raise unless FEEN.parse("車,馬,象,士,將,士,象,馬,車/9/1,砲,5,砲,1/卒,1,卒,1,卒,1,卒,1,卒/9/9/兵,1,兵,1,兵,1,兵,1,兵/1,炮,5,炮,1/9/俥,傌,相,仕,帥,仕,相,傌,俥 0 /").eql?(
  active_side_id: 0,
  indexes: [10, 9],
  pieces_in_hand_grouped_by_sides: [
    [],
    []
  ],
  squares: [
    "車", "馬", "象", "士", "將", "士", "象", "馬", "車",
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, "砲", nil, nil, nil, nil, nil, "砲", nil,
    "卒", nil, "卒", nil, "卒", nil, "卒", nil, "卒",
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    "兵", nil, "兵", nil, "兵", nil, "兵", nil, "兵",
    nil, "炮", nil, nil, nil, nil, nil, "炮", nil,
    nil, nil, nil, nil, nil, nil, nil, nil, nil,
    "俥", "傌", "相", "仕", "帥", "仕", "相", "傌", "俥"
  ]
)
