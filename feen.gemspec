# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "feen"
  spec.version                = ::File.read("VERSION.semver").chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "FEEN (Forsyth–Edwards Enhanced Notation) support for the Ruby language."
  spec.description            = "A Ruby interface for data serialization and deserialization in FEEN format. " \
                                "FEEN is a compact, canonical, and rule-agnostic textual format for representing " \
                                "static board positions in two-player piece-placement games like Chess, Shōgi, " \
                                "Xiangqi, and others."
  spec.homepage               = "https://github.com/sashite/feen.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*.rb"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.add_dependency "pnn", "~> 2.0.0"
  spec.add_dependency "sashite-snn", "~> 1.0.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/feen.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/feen.rb/main",
    "homepage_uri"          => "https://github.com/sashite/feen.rb",
    "source_code_uri"       => "https://github.com/sashite/feen.rb",
    "specification_uri"     => "https://sashite.dev/documents/feen/1.0.0/",
    "rubygems_mfa_required" => "true"
  }
end
