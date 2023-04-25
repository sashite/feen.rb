# Feen.rb

[![Version](https://img.shields.io/github/v/tag/sashite/feen.rb?label=Version&logo=github)](https://github.com/sashite/feen.rb/releases)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/feen.rb/main)
[![CI](https://github.com/sashite/feen.rb/workflows/CI/badge.svg?branch=main)](https://github.com/sashite/feen.rb/actions?query=workflow%3Aci+branch%3Amain)
[![RuboCop](https://github.com/sashite/feen.rb/workflows/RuboCop/badge.svg?branch=main)](https://github.com/sashite/feen.rb/actions?query=workflow%3Arubocop+branch%3Amain)
[![License](https://img.shields.io/github/license/sashite/feen.rb?label=License&logo=github)](https://github.com/sashite/feen.rb/raw/main/LICENSE.md)

> __FEEN__ (FEN Easy Extensible Notation) support for the Ruby language.

## Overview

This is an implementation of [FEEN](https://developer.sashite.com/specs/fen-easy-extensible-notation), a generic format that can be used for serializing and deserializing positions.

A __FEEN__ string consists of a single line of ASCII text containing three data fields, separated by a space. These are:

1. Piece placement
2. Side to move
3. Pieces in hand

The main chess variants may be supported, including [Chess](https://en.wikipedia.org/wiki/Chess), [Janggi](https://en.wikipedia.org/wiki/Janggi), [Makruk](https://en.wikipedia.org/wiki/Makruk), [Shogi](https://en.wikipedia.org/wiki/Shogi), [Xiangqi](https://en.wikipedia.org/wiki/Xiangqi).

More exotic variants may be also supported, like: [Dai dai shogi](https://en.wikipedia.org/wiki/Dai_dai_shogi), [Four-player chess](https://en.wikipedia.org/wiki/Four-player_chess), or [Three-dimensional chess](https://en.wikipedia.org/wiki/Three-dimensional_chess) 🖖

![3D chess on Star Trek (from the episode "Court Martial")](https://github.com/sashite/feen.rb/raw/main/star-trek-chess.jpg)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "feen", ">= 5.0.0.beta0"
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install feen --pre
```

## Usage

### Serialization

A position can be serialized by filling in these fields:

- **Piece placement**: Describes the placement of pieces on the board with a hash that references each piece on the board. The keys could be numbers, or strings of characters representing coordinates.
- **Side to move**: A char that indicates who moves next. In chess, "`w`" would mean that White must move, and "`b`" that Black must move. In Shogi, "`s`" could mean that Sente must move, and "`g`" that Gote must move. In Xiangqi, "`r`" could mean that Red must move, and "`b`" that Black must move.
- **Pieces in hand**: An array of all captured pieces that remain _in hand_, like in Shogi.
- **Board shape**: An array of integers. For instance, it would be `[10, 9]` in Xiangqi. And it would be `[8, 8]` in Chess.

#### Examples

##### A classic Tsume Shogi problem

```ruby
require "feen"

Feen.dump(
  side_to_move:    "s",
  pieces_in_hand:  %w[S r r b g g g g s n n n n p p p p p p p p p p p p p p p p p],
  board_shape:     [9, 9],
  piece_placement: {
    3  => "s",
    4  => "k",
    5  => "s",
    22 => "+P",
    43 => "+B"
  }
)
# => "3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 s S,b,g*4,n*4,p*17,r*2,s"
```

### Deserialization

Serialized positions can be converted back to fields.

#### Examples

##### A classic Tsume Shogi problem

```ruby
require "feen"

Feen.parse("3,s,k,s,3/9/4,+P,4/9/7,+B,1/9/9/9/9 s S,b,g*4,n*4,p*17,r*2,s")
# {:board_shape=>[9, 9],
#  :pieces_in_hand=>["S", "b", "g", "g", "g", "g", "n", "n", "n", "n", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "p", "r", "r", "s"],
#  :piece_placement=>{3=>"s", 4=>"k", 5=>"s", 22=>"+P", 43=>"+B"},
#  :side_to_move=>"s"}
```

## License

The code is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This [gem](https://rubygems.org/gems/feen) is maintained by [Sashité](https://sashite.com/).

With some [lines of code](https://github.com/sashite/), let's share the beauty of Chinese, Japanese and Western cultures through the game of chess!
