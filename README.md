# FEEN.rb

[![Build Status](https://travis-ci.org/sashite/feen.rb.svg?branch=master)](https://travis-ci.org/sashite/feen.rb)
[![Documentation](https://img.shields.io/:yard-docs-38c800.svg)][https://rubydoc.info/gems/feen/frames]

> FEEN support for the Ruby language.

## Overview

This is an implementation of [FEEN](https://developer.sashite.com/specs/forsyth-edwards-expanded-notation), a generic format that can be used for serializing and deserializing positions from the main two-player chess variants including _Chess_, _Makruk_, _Shogi_, _Xiangqi_, and even multidimensional ones such as _Millennium 3D chess_, _Space shogi_, _Three-dimensional chess_ 🖖

![3D chess on Star Trek (from the episode "Court Martial")](https://github.com/sashite/feen.rb/raw/master/star-trek-chess.jpg)

## Installation

1. Add the dependency to your `Gemfile`:

   ```ruby
   gem 'feen'
   ```

2. Run `bundle install`

## Usage

```ruby
require 'feen'

# Serialize Xiangqi's starting position

FEEN.dump([10, 9],
  '車', '馬', '象', '士', '將', '士', '象', '馬', '車',
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  nil, '砲', nil, nil, nil, nil, nil, '砲', nil,
  '卒', nil, '卒', nil, '卒', nil, '卒', nil, '卒',
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  '兵', nil, '兵', nil, '兵', nil, '兵', nil, '兵',
  nil, '炮', nil, nil, nil, nil, nil, '炮', nil,
  nil, nil, nil, nil, nil, nil, nil, nil, nil,
  '俥', '傌', '相', '仕', '帥', '仕', '相', '傌', '俥')
# => '車,馬,象,士,將,士,象,馬,車/9/1,砲,5,砲,1/卒,1,卒,1,卒,1,卒,1,卒/9/9/兵,1,兵,1,兵,1,兵,1,兵/1,炮,5,炮,1/9/俥,傌,相,仕,帥,仕,相,傌,俥 B /'

# Deserialize Xiangqi's starting position

FEEN.parse('車,馬,象,士,將,士,象,馬,車/9/1,砲,5,砲,1/卒,1,卒,1,卒,1,卒,1,卒/9/9/兵,1,兵,1,兵,1,兵,1,兵/1,炮,5,炮,1/9/俥,傌,相,仕,帥,仕,相,傌,俥 B /')
# => {
#      is_turn_to_topside: false,
#      indexes: [10, 9],
#      squares: [
#        '車', '馬', '象', '士', '將', '士', '象', '馬', '車',
#        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#        nil, '砲', nil, nil, nil, nil, nil, '砲', nil,
#        '卒', nil, '卒', nil, '卒', nil, '卒', nil, '卒',
#        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#        '兵', nil, '兵', nil, '兵', nil, '兵', nil, '兵',
#        nil, '炮', nil, nil, nil, nil, nil, '炮', nil,
#        nil, nil, nil, nil, nil, nil, nil, nil, nil,
#        '俥', '傌', '相', '仕', '帥', '仕', '相', '傌', '俥'
#      ],
#      bottomside_in_hand_pieces: [],
#      topside_in_hand_pieces: []
#    }
```

## License

The code is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## About Sashite

This [gem](https://rubygems.org/gems/feen) is maintained by [Sashite](https://sashite.com/).

With some [lines of code](https://github.com/sashite/), let's share the beauty of Chinese, Japanese and Western cultures through the game of chess!
