# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "wholeable"
  spec.version = "1.4.0"
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://alchemists.io/projects/wholeable"
  spec.summary = "Provides whole value object behavior."
  spec.license = "Hippocratic-2.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/bkuhlmann/wholeable/issues",
    "changelog_uri" => "https://alchemists.io/projects/wholeable/versions",
    "homepage_uri" => "https://alchemists.io/projects/wholeable",
    "funding_uri" => "https://github.com/sponsors/bkuhlmann",
    "label" => "Wholeable",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/bkuhlmann/wholeable"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = ">= 3.4"

  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]
end
