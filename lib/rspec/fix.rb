# frozen_string_literal: true

require "fix"
require "rspec/expectations"

# The examples of RSpec: this gem adds the word `fix` to them.
module RSpec
  # The word `fix` for the examples of RSpec:
  # `expect(value).to fix(:Name)` is met when the value meets every
  # expectation of the specification of Fix registered under that name, and
  # tells which it does not. Included in the example groups:
  # `config.include RSpec::Fix`.
  #
  # @example
  #   RSpec.configure { |config| config.include RSpec::Fix }
  #
  #   RSpec.describe Duck do
  #     it { is_expected.to fix(:Duck) }
  #   end
  module Fix
    # @param name [Symbol] the name of a registered specification
    # @param fork [Boolean] whether each context runs in a child process, on a
    #   copy of the value, as Fix does it; by default, the methods of the
    #   specification are sent to the value itself, in the process of the
    #   example
    # @return [RSpec::Fix::Matcher]
    # @raise [KeyError] when no specification has that name
    def fix(name, fork: false)
      Matcher.new(::Fix[name], fork)
    end

    # A matcher of RSpec, composable as its own are: with `and` and `or`, and
    # as an argument of another matcher. RSpec asks for the message after
    # the answer, so the matcher keeps the results of the last value it was
    # given.
    #
    # @api private
    class Matcher
      include Matchers::Composable

      # @param spec [Fix::Spec] the specification
      # @param fork [Boolean] whether each context runs in a child process
      def initialize(spec, fork)
        @spec = spec
        @fork = fork
        @results = [].freeze
      end

      # Tests a value: it is the subject of every expectation.
      #
      # @param value [Object] the value
      # @return [Boolean] whether every expectation is met
      # @raise [NotImplementedError] with a child per context, when this Ruby
      #   cannot fork
      # @raise [Aw::ChildError] with a child per context, when one died or
      #   delivered no result; what is raised outside an expectation is
      #   raised here again, with children or without
      def matches?(value)
        @results = @spec.run(fork: @fork) { value }
        @results.all?(&:passed?)
      end

      # @return [String] `fix NAME`
      def description
        @spec.to_s
      end

      # @return [String] the expectations the last value did not meet, one
      #   line each
      def failure_message
        ["expected the value to #{@spec}:", *@results.reject(&:passed?)].join("\n  ")
      end

      # @return [String] the expectations the last value met, one line each
      def failure_message_when_negated
        ["expected the value not to #{@spec}:", *@results].join("\n  ")
      end
    end
  end
end
