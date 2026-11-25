# frozen_string_literal: true

require_relative File.join("support", "coverage")
require_relative File.join("..", "lib", "rspec", "fix")
require_relative File.join("support", "helpers")

# An example of RSpec, without its runner: the matchers of RSpec and the
# word of this gem, as an example group has them after
# `config.include RSpec::Fix`.
EXAMPLE = Object.new.extend(RSpec::Matchers, RSpec::Fix)

# What RSpec raises for an expectation that is not met.
NOT_MET = RSpec::Expectations::ExpectationNotMetError

# What an example raises, or nil when its expectations are met.
def example(&)
  raised { EXAMPLE.instance_exec(&) }
end

Fix :RSpecFixTestDuck do
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

duck = Struct.new(:walk, :swim, :speak).new("Klop klop!", "Swoosh...", "Quaaack!")
robot = Struct.new(:walk, :swim).new("Klop klop!", "Glug glug...")
decoy = Struct.new(:swim, :speak).new("Swoosh...", "Squeak!")
# Fix writes a location relative to the current directory, whether this
# file was given to ruby by that path or required by an absolute one.
file = File.absolute_path(__FILE__).delete_prefix(File.join(Dir.pwd, ""))
line = __LINE__ - 18
unmet = <<~TEXT.chomp
  expected the value to fix RSpecFixTestDuck:
    #{file}:#{line}: Error: NoMethodError: undefined method 'walk' for an instance of #{decoy.class}
    #{file}:#{line + 8}: Failure: expected "Squeak!" to eq "Quaaack!"
TEXT
met = <<~TEXT.chomp
  expected the value not to fix RSpecFixTestDuck:
    #{file}:#{line}: Success: expected "Klop klop!" to eq "Klop klop!"
    #{file}:#{line + 4}: Warning: expected "Glug glug..." to eq "Swoosh..."
    #{file}:#{line + 8}: Info: NoMethodError: undefined method 'speak' for an instance of #{robot.class}
TEXT

# The matcher, by the methods RSpec asks of one: the answer for a value,
# then the message about that value. A warning and an info are met.
matcher = EXAMPLE.fix(:RSpecFixTestDuck)
raise unless matcher.instance_of?(RSpec::Fix::Matcher)
raise unless matcher.description == "fix RSpecFixTestDuck"
raise unless matcher.failure_message == "expected the value to fix RSpecFixTestDuck:"
raise unless matcher.matches?(duck).equal?(true)
raise unless matcher.failure_message == "expected the value to fix RSpecFixTestDuck:"
raise unless matcher.matches?(decoy).equal?(false)
raise unless matcher.failure_message.tr("`", "'") == unmet
raise unless matcher.matches?(robot).equal?(true)
raise unless matcher.failure_message_when_negated.tr("`", "'") == met
raise unless matcher.description == "fix RSpecFixTestDuck"

# The name is the one of a registered specification, found when the matcher
# is built.
error = raised { EXAMPLE.fix(:RSpecFixTestMissing) }
raise unless error.instance_of?(KeyError) && error.key == :RSpecFixTestMissing

# In an example: met, not met, and negated.
raise unless example { expect(duck).to fix(:RSpecFixTestDuck) }.nil?
raise unless example { expect(robot).to fix(:RSpecFixTestDuck) }.nil?
raise unless example { expect(decoy).not_to fix(:RSpecFixTestDuck) }.nil?
error = example { expect(decoy).to fix(:RSpecFixTestDuck) }
raise unless error.instance_of?(NOT_MET) && error.message.tr("`", "'") == unmet
error = example { expect(robot).not_to fix(:RSpecFixTestDuck) }
raise unless error.instance_of?(NOT_MET) && error.message.tr("`", "'") == met

# A value, not a block: the contexts cannot build the subject anew.
error = example { expect { duck }.to fix(:RSpecFixTestDuck) }
raise unless error.instance_of?(NOT_MET)
raise unless error.message.start_with?("You must pass an argument rather than a block")

# Composed as the matchers of RSpec are: on either side of `and` and `or`,
# for each value of `all`, and as an argument of another matcher.
raise unless example { expect(duck).to fix(:RSpecFixTestDuck).and be_a(Struct) }.nil?
raise unless example { expect(duck).to be_a(Struct).and fix(:RSpecFixTestDuck) }.nil?
raise unless example { expect(decoy).to fix(:RSpecFixTestDuck).or be_a(Struct) }.nil?
raise unless example { expect(decoy).to be_nil.or fix(:RSpecFixTestDuck) }.instance_of?(NOT_MET)
error = example { expect(decoy).to fix(:RSpecFixTestDuck).and be_a(Struct) }
raise unless error.instance_of?(NOT_MET) && error.message.tr("`", "'") == unmet
raise unless example { expect([duck, robot]).to all(fix(:RSpecFixTestDuck)) }.nil?
error = example { expect([duck, decoy, 3]).to all(fix(:RSpecFixTestDuck)) }
raise unless error.instance_of?(NOT_MET)
raise unless error.message.include?("object at index 1 failed to match:") && error.message.include?("of #{decoy.class}")
raise unless error.message.include?("object at index 2 failed to match:") && error.message.include?("of Integer")
raise unless example { expect(pond: duck).to include(pond: fix(:RSpecFixTestDuck)) }.nil?
raise unless example { expect(pond: decoy).to include(pond: fix(:RSpecFixTestDuck)) }.instance_of?(NOT_MET)
raise unless example { expect([decoy, duck]).to contain_exactly(fix(:RSpecFixTestDuck), be_a(Struct)) }.nil?

# The methods of the specification are sent to the value itself, in the
# process of the example. With fork: true, each context runs in a child
# process, as Fix does it, and they are sent to a copy of the value.
parent = Process.pid
Fix(:RSpecFixTestChild) { it MUST(satisfy { |pid| pid == parent && Process.pid != parent }) }
Fix(:RSpecFixTestParent) { it MUST(satisfy { |pid| pid == parent && Process.pid == parent }) }
raise unless example { expect(parent).to fix(:RSpecFixTestParent) }.nil?
raise unless example { expect(parent).not_to fix(:RSpecFixTestChild) }.nil?
raise unless example { expect(parent).to fix(:RSpecFixTestChild, fork: true) }.nil?
raise unless example { expect(parent).not_to fix(:RSpecFixTestParent, fork: true) }.nil?
Fix(:RSpecFixTestPush) { on(:push, 1) { on(:size) { it MUST eq 1 } } }
stack = []
raise unless example { expect(stack).to fix(:RSpecFixTestPush, fork: true) }.nil? && stack.empty?
raise unless example { expect(stack).to fix(:RSpecFixTestPush) }.nil? && stack == [1]

# What is not an outcome of an expectation is raised, with children or
# without.
Fix(:RSpecFixTestCall) { on(:call) { it MUST eq 1 } }
raise unless example { expect(-> { 1 }).to fix(:RSpecFixTestCall) }.nil?
raise unless example { expect(-> { raise Interrupt }).to fix(:RSpecFixTestCall) }.instance_of?(Interrupt)
raise unless example { expect(-> { raise Interrupt }).to fix(:RSpecFixTestCall, fork: true) }.instance_of?(Interrupt)
raise unless example { expect(-> { exit! 2 }).to fix(:RSpecFixTestCall, fork: true) }.instance_of?(Aw::ChildError)

# The public surface: one word for the examples, and the methods of a
# matcher of RSpec.
raise unless RSpec::Fix.public_instance_methods(false) == %i[fix]
surface = %i[description failure_message failure_message_when_negated matches?]
raise unless RSpec::Fix::Matcher.public_instance_methods(false).sort == surface
