# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "sashite-feen"
  spec.version = ::File.read("VERSION.semver").chomp
  spec.author  = "Cyril Kato"
  spec.email   = "contact@cyril.email"
  spec.summary = "FEEN (Forsyth—Edwards Enhanced Notation) implementation for Ruby with universal position representation"

  spec.description = <<~DESC
    FEEN (Forsyth—Edwards Enhanced Notation) provides a universal, rule-agnostic format for
    representing board game positions. This gem implements the FEEN Specification v1.0.0 with
    a modern Ruby interface featuring immutable position objects and functional programming
    principles. FEEN extends traditional FEN notation to support multiple game systems (chess,
    shōgi, xiangqi, makruk), cross-style games, multi-dimensional boards, and captured pieces
    held in reserve. Built on EPIN (piece notation) and SIN (style notation) foundations,
    FEEN enables canonical position representation across diverse abstract strategy board games.
    Perfect for game engines, position analysis tools, and hybrid gaming systems requiring
    comprehensive board state representation.
  DESC

  spec.homepage               = "https://github.com/sashite/feen.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.add_dependency "sashite-epin", "~> 1.1"
  spec.add_dependency "sashite-sin", "~> 2.1"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/feen.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/feen.rb/main",
    "homepage_uri"          => "https://github.com/sashite/feen.rb",
    "source_code_uri"       => "https://github.com/sashite/feen.rb",
    "specification_uri"     => "https://sashite.dev/specs/feen/1.0.0/",
    "rubygems_mfa_required" => "true"
  }
end
