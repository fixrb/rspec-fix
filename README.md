# RSpec::Fix

[![Version](https://img.shields.io/github/v/tag/fixrb/rspec-fix?label=Version&logo=github)](https://github.com/fixrb/rspec-fix/tags)
[![Yard documentation](https://img.shields.io/badge/Yard-documentation-blue.svg?logo=github)](https://gemdocs.org/gems/rspec-fix/latest/)
[![License](https://img.shields.io/github/license/fixrb/rspec-fix?label=License&logo=github)](https://github.com/fixrb/rspec-fix/raw/main/LICENSE.md)

RSpec::Fix brings the specifications of [Fix](https://github.com/fixrb/fix) to [RSpec](https://rspec.info/), as a matcher: `expect(value).to fix(:Name)` is met when the value meets every expectation of the specification, and its message tells which it does not. It is the way to add a specification of Fix to an RSpec suite, and to keep the suite.

[fixrb.dev](https://fixrb.dev/gems/rspec-fix/) presents the gem.

## Installation

```ruby
# Gemfile
gem "rspec-fix"
```

RSpec::Fix requires Ruby 3.3 or later, and depends on [Fix](https://github.com/fixrb/fix) and on rspec-expectations, 3.13 or later.

## Usage

```ruby
# duck_spec.rb
require "rspec/fix"

Fix :Duck do
  on :walk do
    it MUST eq "Klop klop!"
  end

  on :swim do
    it SHOULD eq "Swoosh..."
  end

  on :speak do
    it MAY eq "Quaaack!"
  end
end

class Duck
  def walk = "Klop klop!"
  def swim = "Swoosh..."
  def speak = "Quaaack!"
end

class Robot
  def walk = "Klop klop!"
  def swim = "Glug glug..."
end

class RubberDuck
  def swim = "Swoosh..."
  def speak = "Squeak!"
end

RSpec.configure { |config| config.include RSpec::Fix }

RSpec.describe Duck do
  it { is_expected.to fix(:Duck) }
end

RSpec.describe Robot do
  it { is_expected.to fix(:Duck) }
end

RSpec.describe RubberDuck do
  it { is_expected.to fix(:Duck) }
end
```

`rspec duck_spec.rb` runs three examples, and one fails:

```text
  1) RubberDuck is expected to fix Duck
     Failure/Error: it { is_expected.to fix(:Duck) }

       expected the value to fix Duck:
         duck_spec.rb:6: Error: NoMethodError: undefined method 'walk' for an instance of RubberDuck
         duck_spec.rb:14: Failure: expected "Squeak!" to eq "Quaaack!"
```

`require "rspec/fix"` requires Fix, and `config.include RSpec::Fix` gives the word `fix` to every example; a group may include the module for itself instead. `fix(:Name)` finds the specification registered by `Fix :Name do … end`, and raises `KeyError` when there is none. The specification is written where the suite can require it once: in the spec file as above, or in a file of its own, which a test of Fix can require too.

The matcher is met when every expectation passes, a warning or an info included: the robot above passes, though it swims its own way and does not speak, and RSpec says nothing of it. `Fix[:Duck].test { Robot.new }` writes every line, the warning and the info among them. Not met, the matcher gives the lines of the failures and of the errors, each pointing at its expectation; `expect(value).not_to fix(:Name)` is met when one expectation is not.

It composes as the matchers of RSpec do: `fix(:Duck).and fix(:Bird)`, `be_a(Duck).or fix(:Duck)`, `all(fix(:Duck))` for the values of a collection, and as an argument of another matcher, `include(pet: fix(:Duck))`.

The methods of the specification are sent to the value itself, in the process of the example, where its transaction, its doubles and its coverage tool are. A method that changes the value changes it for the contexts that follow, and for the rest of the example.

`fix(:Name, fork: true)` runs each context in a child process, as Fix does it, on a system with `fork`: the methods are sent to a copy of the value, and the one the example holds is left as it was. It is for a value whose state is all in the process, since what lives outside is not copied. In a Rails application with transactional tests, a child does not see a row the example has created, and a row it writes is not rolled back; a double does not see what a child received.

The matcher takes a value, not a block: `expect { … }.to fix(:Name)` is refused by RSpec. Since the value is given once, the contexts cannot build it anew with their lets: a specification meant for a matcher is written without `with`. What is not an outcome of an expectation is raised: an `Interrupt`, and with `fork: true` a child that died or a Ruby without `fork`.

## Versioning

RSpec::Fix follows [Semantic Versioning 2.0](https://semver.org/).

## License

The [gem](https://rubygems.org/gems/rspec-fix) is available as open source under the terms of the [MIT License](https://github.com/fixrb/rspec-fix/raw/main/LICENSE.md).

## Sponsors

This project is sponsored by [Sashité](https://sashite.com/)
