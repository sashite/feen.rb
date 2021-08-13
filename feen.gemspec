# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name         = "feen"
  spec.version      = File.read("VERSION.semver").chomp
  spec.author       = "Cyril Kato"
  spec.email        = "contact@cyril.email"
  spec.summary      = "FEEN support for the Ruby language."
  spec.description  = "A Ruby interface for data serialization and deserialization in FEEN format."
  spec.homepage     = "https://developer.sashite.com/specs/forsyth-edwards-expanded-notation"
  spec.license      = "MIT"
  spec.required_ruby_version = ::Gem::Requirement.new(">= 3.0.0")
  spec.files = Dir["LICENSE.md", "README.md", "lib/**/*"]

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/sashite/feen.rb/issues",
    "documentation_uri" => "https://rubydoc.info/gems/feen/index",
    "source_code_uri" => "https://github.com/sashite/feen.rb"
  }

  spec.add_development_dependency "brutal"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rubocop-md"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rake"
  spec.add_development_dependency "rubocop-thread_safety"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "yard"
end
