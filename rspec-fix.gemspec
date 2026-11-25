# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "rspec-fix"
  spec.version                = File.read(File.join(__dir__, "VERSION.semver")).chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "A matcher of RSpec that tests a value against a specification of Fix"
  spec.description            = "RSpec::Fix adds the word fix to the examples of RSpec: expect(value).to fix(:Name) " \
                                "is met when the value meets every expectation of that specification of Fix, " \
                                "and its message tells which it does not. A specification of Fix, beside the " \
                                "suite a project already has."
  spec.homepage               = "https://fixrb.dev/gems/rspec-fix/"
  spec.license                = "MIT"
  spec.files                  = Dir["LICENSE.md", "README.md", "lib/**/*.rb", base: __dir__]
  spec.required_ruby_version  = ">= 3.3.0"

  spec.metadata["bug_tracker_uri"]       = "https://github.com/fixrb/rspec-fix/issues"
  spec.metadata["documentation_uri"]     = "https://gemdocs.org/gems/#{spec.name}/#{spec.version}/"
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["source_code_uri"]       = "https://github.com/fixrb/rspec-fix"

  spec.add_dependency "fix", "~> 1.0"
  spec.add_dependency "rspec-expectations", ">= 3.13", "< 5"
end
