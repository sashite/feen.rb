# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "sashite-feen"
  spec.version = ::File.read("VERSION.semver").chomp
  spec.author  = "Cyril Kato"
  spec.email   = "contact@cyril.email"
  spec.summary = "FEEN (Field Expression Encoding Notation) implementation for Ruby providing rule-agnostic board position encoding."

  spec.description = <<~DESC
    FEEN (Field Expression Encoding Notation) implementation for Ruby.
    Encodes board game positions with piece placement, hands, and style-turn fields
    for abstract strategy board games with a canonical, rule-agnostic format.
  DESC

  spec.homepage               = "https://github.com/sashite/feen.rb"
  spec.license                = "Apache-2.0"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.add_dependency "qi", "~> 13.0.0"
  spec.add_dependency "sashite-epin", "~> 2.2.1"
  spec.add_dependency "sashite-sin", "~> 3.1.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/feen.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/feen.rb/main",
    "homepage_uri"          => "https://github.com/sashite/feen.rb",
    "source_code_uri"       => "https://github.com/sashite/feen.rb",
    "specification_uri"     => "https://sashite.dev/specs/feen/1.0.0/",
    "rubygems_mfa_required" => "true"
  }
end
