# frozen_string_literal: true

require "open3"
require "rbconfig"
require "tmpdir"

require_relative File.join("support", "coverage")
require_relative File.join("..", "lib", "rspec", "fix")

# Each Ruby example of the README is a file, named by its first line when it
# is a comment, run by this Ruby with the lib directory on its load path,
# after the runner of RSpec, as the rspec command runs it, in an empty
# directory, so that a location is the name of the file. What it writes on
# the standard output holds the text block that follows it, and it writes
# nothing on the standard error; its status is 1 when the text block has a
# failure or an error, 0 otherwise. Ruby 3.3 quotes a method name with a
# backquote where 3.4 uses a quote: the output is read as 3.4 writes it.
# The Gemfile excerpt is left out.
readme = File.read(File.join(__dir__, "..", "README.md"), encoding: Encoding::UTF_8)
examples = readme.scan(/^```ruby\n(.*?)^```\n(?:\n[^\n]+\n\n```text\n(.*?)^```\n)?/m)
examples.reject! { |code, _| code.include?("# Gemfile") }
raise if examples.empty?
lib = File.expand_path(File.join("..", "lib"), __dir__)
Dir.mktmpdir do |dir|
  examples.each do |code, text|
    name = code[/\A# (\S+\.rb)\n/, 1] || "example.rb"
    File.write(File.join(dir, name), code)
    output, error, status = Open3.capture3(RbConfig.ruby, "-w", "-I", lib, "-r", "rspec/autorun", name, chdir: dir)
    raise "#{name}: #{error}" unless error.empty?

    text = text.to_s
    raise "#{name} wrote:\n#{output}" unless output.tr("`", "'").include?(text)
    raise "#{name} exited #{status.exitstatus}" unless status.exitstatus == (text.match?(/: (Failure|Error): /) ? 1 : 0)
  end
end
