# TODO — sashite-feen Ruby Implementation

## 1. Extract canonical ordering logic into a shared module

**Files affected:** `parser/hand.rb`, `dumper/hands.rb`

The methods `compare_pieces`, `decompose`, and `case_rank` are duplicated verbatim (~70 lines) between `Parser::Hand` and `Dumper::Hands`. Any bug fix to the canonical ordering must currently be applied in two places.

**Action items:**

- Create a shared module (e.g. `Shared::EpinOrdering`) exposing `compare_pieces`, `decompose`, and `case_rank`.
- Unify `compare_items` as well — the parser takes separate arguments `(count_a, piece_a, count_b, piece_b)` while the dumper takes array pairs `(item_a, item_b)`, but the core logic is identical. Either standardize the signature or have both delegate to the shared `compare_pieces`.
- Update `Parser::Hand` and `Dumper::Hands` to call into the shared module instead of defining their own copies.
- Verify that all existing tests still pass after the refactor.

## 2. Align the README with the actual `dump` API

**Files affected:** `README-feen-implementation-in-ruby.md`

The README documents `Sashite::Feen.dump` with keyword arguments and raw data structures:

```ruby
# README shows this (incorrect):
Sashite::Feen.dump(
  piece_placement: { segments: [...], separators: [...] },
  hands: { first: [...], second: [...] },
  style_turn: { active: "C", inactive: "c" }
)
```

The actual implementation takes a single `Qi::Position` argument:

```ruby
# Actual API:
Sashite::Feen.dump(position)
```

**Action items:**

- Remove or replace the keyword-argument examples in the README.
- Document the real signature: `Sashite::Feen.dump(position)` where `position` is a `Qi::Position`.
- Provide examples that construct a `Qi::Position` via `Qi.new(board, hands, styles, turn)` or obtain one via `Sashite::Feen.parse(...)` before dumping.

## 3. Add a dedicated validation fast path

**Files affected:** `parser.rb` (module `Parser`)

Currently `valid?` delegates to `parse`, which builds a full `Qi::Position` object before returning `true`. For inputs that are invalid (and potentially frequent in validation-heavy contexts), the overhead of constructing intermediate objects is wasted.

```ruby
# Current implementation:
def self.valid?(input)
  return false unless ::String === input
  parse(input)
  true
rescue ::ArgumentError
  false
end
```

**Action items:**

- Introduce a lightweight validation path that runs all four validation stages (syntactic, canonicality, dimensional coherence, cardinality) without constructing `Qi::Position` or expanding hands into flat arrays.
- The sub-parsers (`PiecePlacement`, `Hands`, `StyleTurn`) could each expose a `valid?` or `validate` method that checks validity and returns counts/metadata (e.g. total squares, total pieces) without building the full result objects.
- Keep the current `valid?` → `parse` fallback as a safe default, and swap in the fast path once it is tested for equivalence.
- Benchmark both paths on a mix of valid and invalid inputs to confirm the improvement.
