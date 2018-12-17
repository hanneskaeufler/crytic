require "../../src/crytic/runner/parallel_runner"
require "../fake_generator"
require "../fake_reporter"
require "../spec_helper"

describe Crytic::ParallelRunner do
  describe "#run" do
    it "raises for empty specs" do
      expect_raises(ArgumentError) do
        parallel_runner.run("", [] of String)
      end
    end

    it "raises for non-existent files" do
      expect_raises(ArgumentError) do
        parallel_runner.run("./nope.cr", ["./nope_spec.cr"])
      end
      expect_raises(ArgumentError) do
        parallel_runner.run("./fixtures/simple/bar.cr", ["./nope_spec.cr"])
      end
    end

    it "returns false for a failing original suite" do
      reporter = FakeReporter.new
      subject = Crytic::ParallelRunner.new(
        threshold: 100.0,
        generator: FakeGenerator.new,
        reporters: [reporter] of Crytic::Reporter::Reporter)
      source = ["./fixtures/simple/bar.cr"]
      specs = ["./fixtures/failing/verification_failure_spec.cr"]

      subject.run(source, specs).should eq false
    end

    it "returns true for no mutations" do
      reporter = FakeReporter.new
      subject = Crytic::ParallelRunner.new(
        threshold: 100.0,
        generator: FakeGenerator.new,
        reporters: [reporter] of Crytic::Reporter::Reporter)
      source = ["./fixtures/simple/bar.cr"]
      specs = ["./fixtures/simple/bar_spec.cr"]

      subject.run(source, specs).should eq true
    end
  end
end

private def parallel_runner
  Crytic::ParallelRunner.new(
    threshold: 100.0,
    reporters: [] of Crytic::Reporter::Reporter,
    generator: FakeGenerator.new)
end
