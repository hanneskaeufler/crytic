require "../src/crytic/runner"
require "./fake_reporter"
require "./fake_generator"
require "./spec_helper"

describe Crytic::Runner do
  describe "#run" do
    it "raises for empty specs" do
      expect_raises(ArgumentError) do
        runner.run("", [] of String)
      end
    end

    it "raises for non-existent files" do
      expect_raises(ArgumentError, "Source file") do
        runner.run("./nope.cr", ["./nope_spec.cr"])
      end
      expect_raises(ArgumentError, "Source file") do
        runner.run(["./nope.cr", "./fixtures/simple/bar.cr"], ["./fixtures/simple/bar_spec.cr"])
      end
      expect_raises(ArgumentError, "Spec file") do
        runner.run("./fixtures/simple/bar.cr", ["./nope_spec.cr"])
      end
    end
  end
end

private def runner
  Crytic::Runner.new(
    threshold: 100.0,
    reporters: [Crytic::Reporter::IoReporter.new(IO::Memory.new)] of Crytic::Reporter::Reporter,
    generator: FakeGenerator.new)
end
