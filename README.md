# FEEN.rb

[![Build Status](https://travis-ci.org/sashite/feen.rb.svg?branch=master)](https://travis-ci.org/sashite/feen.rb)
[![Documentation](https://img.shields.io/:yard-docs-38c800.svg)](https://rubydoc.info/gems/feen/frames)

> __FEEN__ (Forsyth–Edwards Expanded Notation) support for the Ruby language.

## Overview

This is an implementation of [__FEEN__](https://developer.sashite.com/specs/forsyth-edwards-expanded-notation), a generic format that can be used for serializing and deserializing chess positions.

The main chess variants are supported, including _Chess_, _Makruk_, _Shogi_, _Xiangqi_.

This tool could also be used for more exotic variants like: _Dai dai shogi_, _Four-player chess_, _Three-dimensional chess_ 🖖

![3D chess on Star Trek (from the episode "Court Martial")](https://github.com/sashite/feen.rb/raw/master/star-trek-chess.jpg)

## Installation

1. Add the dependency to your `Gemfile`:

   ```ruby
   gem "feen"
   ```

2. Run `bundle install`

## Usage

```ruby
require "feen"

# Emit a FEEN representing the Shogi's starting position
FEEN.dump(
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
# => "l,n,s,g,k,g,s,n,l/1,r,5,b,1/p,p,p,p,p,p,p,p,p/9/9/9/P,P,P,P,P,P,P,P,P/1,B,5,R,1/L,N,S,G,K,G,S,N,L 0 /"

# Parse the Shogi's starting position FEEN
FEEN.parse("l,n,s,g,k,g,s,n,l/1,r,5,b,1/p,p,p,p,p,p,p,p,p/9/9/9/P,P,P,P,P,P,P,P,P/1,B,5,R,1/L,N,S,G,K,G,S,N,L 0 /")
# => {
#      active_side_id: 0,
#      indexes: [9, 9],
#      pieces_in_hand_grouped_by_sides: [
#        [],
#        []
#      ],
#      squares: [
#        "l", "n", "s", "g", "k", "g", "s", "n", "l",
#        nil, "r", nil, nil, nil, nil, nil, "b", nil,
#        "p", "p", "p", "p", "p", "p", "p", "p", "p",
#        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#        "P", "P", "P", "P", "P", "P", "P", "P", "P",
#        nil, "B", nil, nil, nil, nil, nil, "R", nil,
#        "L", "N", "S", "G", "K", "G", "S", "N", "L"
#      ]
#    }
```

### More examples

```ruby
# Dump an empty 3x8x8 board position
FEEN.dump(
  active_side_id: 0,
  indexes: [3, 8, 8],
  pieces_in_hand_grouped_by_sides: [
    [],
    []
  ],
  squares: Array.new(3 * 8 * 8)
)
# => "8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8 0 /"

# Dump Four-player chess's starting position
FEEN.dump(
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
# => "3,yR,yN,yB,yK,yQ,yB,yN,yR,3/3,yP,yP,yP,yP,yP,yP,yP,yP,3/14/bR,bP,10,gP,gR/bN,bP,10,gP,gN/bB,bP,10,gP,gB/bK,bP,10,gP,gQ/bQ,bP,10,gP,gK/bB,bP,10,gP,gB/bN,bP,10,gP,gN/bR,bP,10,gP,gR/14/3,rP,rP,rP,rP,rP,rP,rP,rP,3/3,rR,rN,rB,rQ,rK,rB,rN,rR,3 0 ///"

# Dump Chess's starting position
FEEN.dump(
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
# => "♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/8/8/♙,♙,♙,♙,♙,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ 0 /"

# Dump Chess's position after the move 1. e4
FEEN.dump(
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
)
# => "♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/4,♙,3/8/♙,♙,♙,♙,1,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ 1 /"

# Dump Chess's position after the moves 1. e4 c5
FEEN.dump(
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
)
# => "♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,1,♟,♟,♟/8/4,♟,3/4,♙,3/8/♙,♙,♙,♙,1,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ 0 /"

# Dump Makruk's starting position
FEEN.dump(
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
# => "♜,♞,♝,♛,♚,♝,♞,♜/8/♟,♟,♟,♟,♟,♟,♟,♟/8/8/♙,♙,♙,♙,♙,♙,♙,♙/8/♖,♘,♗,♔,♕,♗,♘,♖ 0 /"

# Dump a classic Tsume Shogi problem
FEEN.dump(
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
)
# => "3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 0 S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s"

# Dump Xiangqi's starting position
FEEN.dump(
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
# => "車,馬,象,士,將,士,象,馬,車/9/1,砲,5,砲,1/卒,1,卒,1,卒,1,卒,1,卒/9/9/兵,1,兵,1,兵,1,兵,1,兵/1,炮,5,炮,1/9/俥,傌,相,仕,帥,仕,相,傌,俥 0 /"

# Parse an empty 3x8x8 board position
FEEN.parse("8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8//8/8/8/8/8/8/8/8 0 /")
# => {
#      active_side_id: 0,
#      indexes: [3, 8, 8],
#      pieces_in_hand_grouped_by_sides: [
#        [],
#        []
#      ],
#      squares: Array.new(3 * 8 * 8)
#    }

# Parse Four-player chess's starting position
FEEN.parse("3,yR,yN,yB,yK,yQ,yB,yN,yR,3/3,yP,yP,yP,yP,yP,yP,yP,yP,3/14/bR,bP,10,gP,gR/bN,bP,10,gP,gN/bB,bP,10,gP,gB/bK,bP,10,gP,gQ/bQ,bP,10,gP,gK/bB,bP,10,gP,gB/bN,bP,10,gP,gN/bR,bP,10,gP,gR/14/3,rP,rP,rP,rP,rP,rP,rP,rP,3/3,rR,rN,rB,rQ,rK,rB,rN,rR,3 0 ///")
# => {
#      active_side_id: 0,
#      indexes: [14, 14],
#      pieces_in_hand_grouped_by_sides: [
#        [],
#        [],
#        [],
#        []
#      ],
#      squares: [
#        nil , nil , nil , "yR", "yN", "yB", "yK", "yQ", "yB", "yN", "yR", nil , nil , nil ,
#        nil , nil , nil , "yP", "yP", "yP", "yP", "yP", "yP", "yP", "yP", nil , nil , nil ,
#        nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil ,
#        "bR", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gR",
#        "bN", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gN",
#        "bB", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gB",
#        "bK", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gQ",
#        "bQ", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gK",
#        "bB", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gB",
#        "bN", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gN",
#        "bR", "bP", nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , "gP", "gR",
#        nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil , nil ,
#        nil , nil , nil , "rP", "rP", "rP", "rP", "rP", "rP", "rP", "rP", nil , nil , nil ,
#        nil , nil , nil , "rR", "rN", "rB", "rQ", "rK", "rB", "rN", "rR", nil , nil , nil
#      ]
#    }

# Parse Chess's starting position
FEEN.parse("♜,♞,♝,♛,♚,♝,♞,♜/♟,♟,♟,♟,♟,♟,♟,♟/8/8/8/8/♙,♙,♙,♙,♙,♙,♙,♙/♖,♘,♗,♕,♔,♗,♘,♖ 0 /")
# => {
#      active_side_id: 0,
#      indexes: [8, 8],
#      pieces_in_hand_grouped_by_sides: [
#        [],
#        []
#      ],
#      squares: [
#        "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
#        "♟", "♟", "♟", "♟", "♟", "♟", "♟", "♟",
#        nil, nil, nil, nil, nil, nil, nil, nil,
#        nil, nil, nil, nil, nil, nil, nil, nil,
#        nil, nil, nil, nil, nil, nil, nil, nil,
#        nil, nil, nil, nil, nil, nil, nil, nil,
#        "♙", "♙", "♙", "♙", "♙", "♙", "♙", "♙",
#        "♖", "♘", "♗", "♕", "♔", "♗", "♘", "♖"
#      ]
#    }

# Parse Makruk's starting position
FEEN.parse("♜,♞,♝,♛,♚,♝,♞,♜/8/♟,♟,♟,♟,♟,♟,♟,♟/8/8/♙,♙,♙,♙,♙,♙,♙,♙/8/♖,♘,♗,♔,♕,♗,♘,♖ 0 /")
# => {
#      active_side_id: 0,
#      indexes: [8, 8],
#      pieces_in_hand_grouped_by_sides: [
#        [],
#        []
#      ],
#      squares: [
#        "♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜",
#        nil, nil, nil, nil, nil, nil, nil, nil,
#        "♟", "♟", "♟", "♟", "♟", "♟", "♟", "♟",
#        nil, nil, nil, nil, nil, nil, nil, nil,
#        nil, nil, nil, nil, nil, nil, nil, nil,
#        "♙", "♙", "♙", "♙", "♙", "♙", "♙", "♙",
#        nil, nil, nil, nil, nil, nil, nil, nil,
#        "♖", "♘", "♗", "♔", "♕", "♗", "♘", "♖"
#      ]
#    }

# Parse a classic Tsume Shogi problem
FEEN.parse("3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 0 S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s")
# => {
#      active_side_id: 0,
#      indexes: [9, 9],
#      pieces_in_hand_grouped_by_sides: [
#        %w[S],
#        %w[b g g g g n n n n p p p p p p p p p p p p p p p p p r r s]
#      ],
#      squares: [
#        nil, nil, nil, "s", "k", "s", nil, nil, nil,
#        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#        nil, nil, nil, nil, "+P", nil, nil, nil, nil,
#        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#        nil, nil, nil, nil, nil, nil, nil, "+B", nil,
#        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#        nil, nil, nil, nil, nil, nil, nil, nil, nil
#      ]
#    }

# Parse Xiangqi's starting position
FEEN.parse("車,馬,象,士,將,士,象,馬,車/9/1,砲,5,砲,1/卒,1,卒,1,卒,1,卒,1,卒/9/9/兵,1,兵,1,兵,1,兵,1,兵/1,炮,5,炮,1/9/俥,傌,相,仕,帥,仕,相,傌,俥 0 /")
# => {
#      active_side_id: 0,
#      indexes: [10, 9],
#      pieces_in_hand_grouped_by_sides: [
#        [],
#        []
#      ],
#      squares: [
#        "車", "馬", "象", "士", "將", "士", "象", "馬", "車",
#        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#        nil, "砲", nil, nil, nil, nil, nil, "砲", nil,
#        "卒", nil, "卒", nil, "卒", nil, "卒", nil, "卒",
#        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#        "兵", nil, "兵", nil, "兵", nil, "兵", nil, "兵",
#        nil, "炮", nil, nil, nil, nil, nil, "炮", nil,
#        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#        "俥", "傌", "相", "仕", "帥", "仕", "相", "傌", "俥"
#      ]
#    }
```

## License

The code is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashite

This [gem](https://rubygems.org/gems/feen) is maintained by [Sashite](https://sashite.com/).

With some [lines of code](https://github.com/sashite/), let's share the beauty of Chinese, Japanese and Western cultures through the game of chess!
