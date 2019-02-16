require "../../src/crytic/mutation/no_mutation"
require "../../src/crytic/runner/sequential"
require "../spec_helper"

module Crytic::Runner
  describe Sequential do
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

      it "takes a list of subjects" do
        reporter = FakeReporter.new
        runner = Sequential.new(
          threshold: 100.0,
          generator: FakeGenerator.new,
          reporters: [reporter] of Crytic::Reporter::Reporter,
          no_mutation_factory: fake_no_mutation_factory)

        runner.run(
          ["./fixtures/require_order/blog.cr", "./fixtures/require_order/pages/blog/archive.cr"],
          ["./fixtures/simple/bar_spec.cr"]).should eq false
      end

      it "doesn't execute mutations if the initial suite run fails" do
        reporter = FakeReporter.new
        runner = Sequential.new(
          threshold: 100.0,
          generator: FakeGenerator.new,
          reporters: [reporter] of Crytic::Reporter::Reporter,
          no_mutation_factory: ->(specs : Array(String)) {
            process_runner = Crytic::FakeProcessRunner.new
            no_mutation = Crytic::Mutation::NoMutation.with(specs, process_runner)
            process_runner.exit_code = [1, 0]
            no_mutation
          })

        runner.run(
          ["./fixtures/require_order/blog.cr", "./fixtures/require_order/pages/blog/archive.cr"],
          ["./fixtures/simple/bar_spec.cr"]).should eq false
      end

      it "reports events in order" do
        reporter = FakeReporter.new
        runner = Sequential.new(
          threshold: 100.0,
          generator: FakeGenerator.new([fake_mutation]),
          reporters: [reporter] of Crytic::Reporter::Reporter,
          no_mutation_factory: fake_no_mutation_factory)

        runner.run("./fixtures/simple/bar.cr", ["./fixtures/simple/bar_spec.cr"])

        reporter.events.should eq ["report_original_result", "report_mutations", "report_neutral_result", "report_result", "report_summary", "report_msi"]
      end

      it "skips the mutations if the neutral result errored" do
        reporter = FakeReporter.new
        mutation = fake_mutation
        runner = Sequential.new(
          threshold: 100.0,
          generator: FakeGenerator.new(
            neutral: erroring_mutation,
            mutations: [mutation]),
          reporters: [reporter] of Crytic::Reporter::Reporter,
          no_mutation_factory: fake_no_mutation_factory)

        runner.run("./fixtures/simple/bar.cr", ["./fixtures/simple/bar_spec.cr"])

        reporter.events.should_not contain("report_result")
        mutation.as(FakeMutation).run_call_count.should eq 0
      end
    end
  end
end

private def runner
  Crytic::Runner::Sequential.new(
    threshold: 100.0,
    reporters: [Crytic::Reporter::IoReporter.new(IO::Memory.new)] of Crytic::Reporter::Reporter,
    generator: FakeGenerator.new)
end

private def fake_no_mutation_factory
  ->(specs : Array(String)) {
    Crytic::Mutation::NoMutation.with(specs, Crytic::FakeProcessRunner.new)
  }
end
