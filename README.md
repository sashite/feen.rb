# FEEN.rb

[![Build Status](https://travis-ci.org/sashite/feen.rb.svg?branch=master)](https://travis-ci.org/sashite/feen.rb)
[![Documentation](https://img.shields.io/:yard-docs-38c800.svg)](https://rubydoc.info/gems/feen/frames)

> FEEN (Forsyth–Edwards Expanded Notation) support for the Ruby language.

## Overview

This is an implementation of [FEEN](https://developer.sashite.com/specs/forsyth-edwards-expanded-notation), a generic format that can be used for serializing and deserializing chess positions.

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

### Serialization

The Xiangqi's starting position can be serialized this way:

```ruby
require "feen"

FEEN.dump([10, 9],
  "車", "馬", "象", "士", "將", "士", "象", "馬", "車",
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  nil, "砲", nil, nil, nil, nil, nil, "砲", nil,
  "卒", nil, "卒", nil, "卒", nil, "卒", nil, "卒",
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  "兵", nil, "兵", nil, "兵", nil, "兵", nil, "兵",
  nil, "炮", nil, nil, nil, nil, nil, "炮", nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  "俥", "傌", "相", "仕", "帥", "仕", "相", "傌", "俥",
  is_turn_to_topside: false, bottomside_in_hand_pieces: [], topside_in_hand_pieces: []
)
# => "車,馬,象,士,將,士,象,馬,車/9/1,砲,5,砲,1/卒,1,卒,1,卒,1,卒,1,卒/9/9/兵,1,兵,1,兵,1,兵,1,兵/1,炮,5,炮,1/9/俥,傌,相,仕,帥,仕,相,傌,俥 B /"
```

### Deserialization

In the other direction, the same Xiangqi starting position can be deserialized this way:

```ruby
require "feen"

FEEN.parse("車,馬,象,士,將,士,象,馬,車/9/1,砲,5,砲,1/卒,1,卒,1,卒,1,卒,1,卒/9/9/兵,1,兵,1,兵,1,兵,1,兵/1,炮,5,炮,1/9/俥,傌,相,仕,帥,仕,相,傌,俥 B /")
# => {
#      is_turn_to_topside: false,
#      indexes: [10, 9],
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
#      ],
#      bottomside_in_hand_pieces: [],
#      topside_in_hand_pieces: []
#    }
```

## Examples

### Classic Tsume Shogi Problem

Let's serialize the position of a classic Shogi problem.

```ruby
require "feen"

FEEN.dump([9, 9],
  nil, nil, nil, "s", "k", "s", nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, "+P", nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, "+B", nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  turn: "K",
  bottomside_in_hand_pieces: %w[S],
  topside_in_hand_pieces: %w[b g g g g n n n n p p p p p p p p p p p p p p p p p r r s]
)
# => "3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 B S/b,g,g,g,g,n,n,n,n,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,r,r,s"
```

Note: checkmate in 2 moves.

### Four-player chess initial setup

```ruby
require "feen"

FEEN.dump(
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
  nil , nil , nil , "rR", "rN", "rB", "rQ", "rK", "rB", "rN", "rR", nil , nil , nil,
  indexes: [14, 14],
  turn: "rK"
)
# => "3,yR,yN,yB,yK,yQ,yB,yN,yR,3/3,yP,yP,yP,yP,yP,yP,yP,yP,3/14/bR,bP,10,gP,gR/bN,bP,10,gP,gN/bB,bP,10,gP,gB/bK,bP,10,gP,gQ/bQ,bP,10,gP,gK/bB,bP,10,gP,gB/bN,bP,10,gP,gN/bR,bP,10,gP,gR/14/3,rP,rP,rP,rP,rP,rP,rP,rP,3/3,rR,rN,rB,rQ,rK,rB,rN,rR,3 rK ///"
```

## License

The code is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashite

This [gem](https://rubygems.org/gems/feen) is maintained by [Sashite](https://sashite.com/).

With some [lines of code](https://github.com/sashite/), let's share the beauty of Chinese, Japanese and Western cultures through the game of chess!
