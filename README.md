# Feen.rb

> **FEEN** — Forsyth–Edwards Enhanced Notation for rule-agnostic board positions (Chess, Shōgi-like, Xiangqi-like, variants).

Purely functional, immutable Ruby implementation built on top of **EPIN** (piece identifiers) and **SIN** (style identifiers).

---

## Why FEEN?

* **Rule-agnostic**: expresses a board **position** without baking in game rules.
* **Portable & canonical**: a single, deterministic string per position.
* **Composable**: works nicely alongside other Sashité specs (e.g., STN for transitions).

FEEN strings have **three space-separated fields**:

```
<piece_placement> <pieces_in_hand> <style_turn>
```

---

## Installation

Add to your `Gemfile`:

```ruby
gem "sashite-feen"
````

Then:

```sh
bundle install
```

This gem depends on:

```ruby
gem "sashite-epin"
gem "sashite-sin"
```

Bundler will install them automatically when you use `sashite-feen`.

---

## Quick start

```ruby
require "sashite/feen"

# Parse
pos = Sashite::Feen.parse("<placement> <hands> <style1>/<style2>")

# Validate
Sashite::Feen.valid?("<your FEEN>") # => true/false

# Normalize (parse → canonical dump)
Sashite::Feen.normalize("<your FEEN>") # => canonical FEEN string

# Build from fields (strings)
pos = Sashite::Feen.build(
  piece_placement: "<placement>",
  pieces_in_hand:  "<bagFirst>/<bagSecond>", # empty bags allowed: "/"
  style_turn:      "<activeSIN>/<inactiveSIN>"
)

# Dump a Position (canonical)
Sashite::Feen.dump(pos) # => "<placement> <hands> <style1>/<style2>"
```

> **Tip:** FEEN itself does not do JSON; keep it minimal and functional. Serialize externally if needed.

---

## Public API

```ruby
Sashite::Feen.parse(str)      # => Position (or raises Sashite::Feen::Error)
Sashite::Feen.valid?(str)     # => Boolean
Sashite::Feen.dump(position)  # => String (canonical)
Sashite::Feen.normalize(str)  # => String (dump(parse(str)))
Sashite::Feen.build(
  piece_placement:, pieces_in_hand:, style_turn:
)                             # => Position
```

Position value-objects are immutable:

```ruby
pos.placement  # => Sashite::Feen::Placement
pos.hands      # => Sashite::Feen::Hands
pos.styles     # => Sashite::Feen::Styles
pos.to_s       # => canonical FEEN string (same as dump(pos))
```

---

## Canonicalization (short rules)

* **Piece placement (field 1)**

  * Consecutive empties compress to digits `1..9`; runs `>9` are split into `"9"` + remainder.
  * Digit `0` in empties is invalid.
  * EPIN tokens are validated via `sashite-epin` and re-emitted canonically.

* **Pieces in hand (field 2)**

  * Two concatenated bags separated by `/` (either side may be empty).
  * Counts are aggregated; `1` is omitted in output.
  * Deterministic sort per EPIN: quantity ↓, letter ↑ (case-insensitive), uppercase before lowercase, prefix `-` < `+` < none, suffix none < `'`.

* **Style-turn (field 3)**

  * Exactly two SIN tokens separated by `/`.
  * Exactly **one uppercase** style (first player) and **one lowercase** style (second).
  * The **first token is the active** player’s style.

---

## Design overview

The gem is small, layered, and testable:

* **API**: `Sashite::Feen` (parse / valid? / dump / normalize / build)
* **Value objects**: `Position`, `Placement`, `Hands`, `Styles` (immutable, canonical)
* **Parser**: `Feen::Parser` orchestrates field parsers (`Parser::PiecePlacement`, `Parser::PiecesInHand`, `Parser::StyleTurn`)
* **Dumper**: `Feen::Dumper` orchestrates field dumpers (`Dumper::PiecePlacement`, `Dumper::PiecesInHand`, `Dumper::StyleTurn`)
* **Ordering**: `Feen::Ordering` — single comparator used by the hands dumper
* **Errors**: `Feen::Error` (see below)

### Project layout

```
lib/
├─ sashite-feen.rb
└─ sashite/
   ├─ feen.rb                 # Public API
   └─ feen/
      ├─ error.rb
      ├─ position.rb
      ├─ placement.rb
      ├─ hands.rb
      ├─ styles.rb
      ├─ ordering.rb
      ├─ parser.rb
      ├─ parser/
      │  ├─ piece_placement.rb
      │  ├─ pieces_in_hand.rb
      │  └─ style_turn.rb
      ├─ dumper.rb
      └─ dumper/
         ├─ piece_placement.rb
         ├─ pieces_in_hand.rb
         └─ style_turn.rb
```

> Version is defined outside of `lib/sashite/feen/version.rb` (e.g., `VERSION.semver`).

---

## Errors

Rescue at the granularity you need:

* `Sashite::Feen::Error::Syntax` – tokenization/field arity
* `Sashite::Feen::Error::Piece`  – EPIN validation failures
* `Sashite::Feen::Error::Style`  – SIN validation/case issues
* `Sashite::Feen::Error::Count`  – invalid counts in hands
* `Sashite::Feen::Error::Bounds` – internal dimension constraints (when relevant)
* `Sashite::Feen::Error::Validation` – generic structural/semantic errors

Example:

```ruby
begin
  pos = Sashite::Feen.parse(str)
rescue Sashite::Feen::Error::Style => e
  warn "Bad style-turn: #{e.message}"
end
```

---

## Dependencies & compatibility

* Runtime: `sashite-epin`, `sashite-sin`
* Purely functional; all objects are frozen; methods return new values.
* No JSON serialization in this gem.

---

## Development

```sh
# Clone
git clone https://github.com/sashite/feen.rb.git
cd feen.rb

# Install
bundle install

# Run smoke tests
ruby test.rb

# Generate YARD docs
yard doc
```

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-change`
3. Add tests covering your changes
4. Ensure everything is green (lint, tests, docs)
5. Commit with a conventional message
6. Push and open a Pull Request

---

## License

Open source under the [MIT License](https://opensource.org/licenses/MIT).

---

## About

Maintained by **Sashité** — promoting chess variants and sharing the beauty of board-game cultures.
