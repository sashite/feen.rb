# Feen.rb

[![Version](https://img.shields.io/github/v/tag/sashite/feen.rb?label=Version&logo=github)](https://github.com/sashite/feen.rb/releases)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/feen.rb/main)
[![CI](https://github.com/sashite/feen.rb/workflows/CI/badge.svg?branch=main)](https://github.com/sashite/feen.rb/actions?query=workflow%3Aci+branch%3Amain)
[![RuboCop](https://github.com/sashite/feen.rb/workflows/RuboCop/badge.svg?branch=main)](https://github.com/sashite/feen.rb/actions?query=workflow%3Arubocop+branch%3Amain)
[![License](https://img.shields.io/github/license/sashite/feen.rb?label=License&logo=github)](https://github.com/sashite/feen.rb/raw/main/LICENSE.md)

> __FEEN__ (Forsyth–Edwards Expanded Notation) support for the Ruby language.

## Overview

This is an implementation of [FEEN](https://github.com/sashite/specs/blob/main/forsyth-edwards-expanded-notation.md), a flexible and minimalist format for describing chess variant positions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "feen", ">= 5.0.0.beta1"
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

- **Board shape**: An array of integers. For instance, it would be `[10, 9]` for a Xiangqi board. Or it would be `[8, 8]` for a Chess board.
- **Piece placement**: Describes the placement of pieces on the board with a hash that references each piece on the board.
- **Side to move**: A char that indicates who moves next. In chess, "`w`" would mean that White can play a move.

#### Example

From a classic Tsume Shogi problem:

```ruby
require "feen"

Feen.dump(
  board_shape:     [9, 9],
  side_to_move:    "s",
  piece_placement: {
    3  => "s",
    4  => "k",
    5  => "s",
    22 => "+P",
    43 => "+B"
  }
)
# => "3sks3/9/4+P4/9/7+B1/9/9/9/9 s"
```

### Deserialization

Serialized positions can be converted back to fields.

#### Example

```ruby
require "feen"

Feen.parse("3sks3/9/4+P4/9/7+B1/9/9/9/9 s")
# {:board_shape=>[9, 9],
#  :piece_placement=>{3=>"s", 4=>"k", 5=>"s", 22=>"+P", 43=>"+B"},
#  :side_to_move=>"s"}
```

## License

The code is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashité

This [gem](https://rubygems.org/gems/feen) is maintained by [Sashité](https://sashite.com/).

With some [lines of code](https://github.com/sashite/), let's share the beauty of Chinese, Japanese and Western cultures through the game of chess!
