# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "feen"
  spec.version                = ::File.read("VERSION.semver").chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "FEEN support for the Ruby language."
  spec.description            = "A Ruby interface for data serialization and deserialization in FEEN format."
  spec.homepage               = "https://github.com/sashite/feen.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.metadata["rubygems_mfa_required"] = "true"
end
