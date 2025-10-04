# Feen.rb

[![Version](https://img.shields.io/github/v/tag/sashite/feen.rb?label=Version&logo=github)](https://github.com/sashite/feen.rb/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://rubydoc.info/github/sashite/feen.rb/main)
![Ruby](https://github.com/sashite/feen.rb/actions/workflows/main.yml/badge.svg?branch=main)
[![License](https://img.shields.io/github/license/sashite/feen.rb?label=License&logo=github)](https://github.com/sashite/feen.rb/raw/main/LICENSE.md)

> **FEEN** (Forsyth–Edwards Enhanced Notation) implementation for the Ruby language.

## What is FEEN?

FEEN (Forsyth–Edwards Enhanced Notation) is a universal, rule-agnostic notation for representing board game positions. It extends traditional FEN to support multiple game systems, cross-style games, multi-dimensional boards, and captured pieces.

This gem implements the [FEEN Specification v1.0.0](https://sashite.dev/specs/feen/1.0.0/) as a pure functional library with immutable data structures.

## Installation

```ruby
gem "sashite-feen"
```

## API

The library provides two methods for converting between FEEN strings and position objects:

```ruby
require "sashite/feen"

# Parse a FEEN string into a position object
position = Sashite::Feen.parse("+rnbq+kbn+r/+p+p+p+p+p+p+p+p/8/8/8/8/+P+P+P+P+P+P+P+P/+RNBQ+KBN+R / C/c")

# Dump a position object into a canonical FEEN string
feen_string = Sashite::Feen.dump(position)
```

### Methods

#### `Sashite::Feen.parse(string)`

Parses a FEEN string and returns an immutable `Position` object.

- **Input**: FEEN string with three space-separated fields
- **Returns**: `Sashite::Feen::Position` instance
- **Raises**: `Sashite::Feen::Error` subclasses on invalid input

#### `Sashite::Feen.dump(position)`

Converts a position object into its canonical FEEN string representation.

- **Input**: `Sashite::Feen::Position` instance
- **Returns**: Canonical FEEN string
- **Guarantees**: Deterministic output (same position always produces same string)

### Position Object

The `Position` object returned by `parse` is immutable and provides read-only access to the three FEEN components:

```ruby
position.placement  # => Placement object (board arrangement)
position.hands      # => Hands object (pieces in hand)
position.styles     # => Styles object (style-turn information)
position.to_s       # => Canonical FEEN string (equivalent to dump)
```

## Format

A FEEN string consists of three space-separated fields:

```
<piece-placement> <pieces-in-hand> <style-turn>
```

1. **Piece placement**: Board configuration using EPIN notation
2. **Pieces in hand**: Captured pieces held by each player
3. **Style-turn**: Game styles and active player

For complete format details, see the [FEEN Specification](https://sashite.dev/specs/feen/1.0.0/).

## Error Handling

The library defines specific error classes for different validation failures:

```txt
Sashite::Feen::Error  # Base error class
├── Error::Syntax     # Malformed FEEN structure
├── Error::Piece      # Invalid EPIN notation
├── Error::Style      # Invalid SIN notation
├── Error::Count      # Invalid piece counts
└── Error::Validation # Other semantic violations
```

## Properties

- **Purely functional**: Immutable data structures, no side effects
- **Canonical output**: Deterministic string generation
- **Specification compliant**: Strict adherence to FEEN v1.0.0
- **Minimal API**: Two methods for complete functionality
- **Composable**: Built on EPIN and SIN specifications

## Dependencies

- [sashite-epin](https://github.com/sashite/epin.rb) – Extended Piece Identifier Notation
- [sashite-sin](https://github.com/sashite/sin.rb) – Style Identifier Notation

## Documentation

- [FEEN Specification v1.0.0](https://sashite.dev/specs/feen/1.0.0/)
- [FEEN Examples](https://sashite.dev/specs/feen/1.0.0/examples/)
- [API Documentation](https://rubydoc.info/github/sashite/feen.rb/main)

## License

Available as open source under the [MIT License](https://opensource.org/licenses/MIT).

## About

Maintained by [Sashité](https://sashite.com/) – promoting chess variants and sharing the beauty of board game cultures.
