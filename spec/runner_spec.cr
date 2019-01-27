require "../src/crytic/runner"
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

    it "takes a list of subjects" do
      reporter = FakeReporter.new
      runner = Crytic::Runner.new(
        threshold: 100.0,
        generator: FakeGenerator.new,
        reporters: [reporter] of Crytic::Reporter::Reporter,
        no_mutation_factory: fake_no_mutation_factory)

      runner.run(
        ["./fixtures/require_order/blog.cr", "./fixtures/require_order/pages/blog/archive.cr"],
        ["./fixtures/simple/bar_spec.cr"]).should eq true
    end

    it "doesn't execute mutations if the initial suite run fails" do
      reporter = FakeReporter.new
      runner = Crytic::Runner.new(
        threshold: 100.0,
        generator: FakeGenerator.new,
        reporters: [reporter] of Crytic::Reporter::Reporter,
        no_mutation_factory: ->(specs : Array(String)) {
          no_mutation = Crytic::Mutation::NoMutation.with(specs)
          process_runner = Crytic::FakeProcessRunner.new
          no_mutation.process_runner = process_runner
          process_runner.exit_code = [1, 0]
          no_mutation
        })

      runner.run(
        ["./fixtures/require_order/blog.cr", "./fixtures/require_order/pages/blog/archive.cr"],
        ["./fixtures/simple/bar_spec.cr"]).should eq false
    end

    it "skips the mutations if the neutral result errored" do
      reporter = FakeReporter.new
      runner = Crytic::Runner.new(
        threshold: 100.0,
        generator: FakeGenerator.new(
          neutral: FakeMutation
            .new(reported_status: Crytic::Mutation::Status::Errored)
            .as(Crytic::Mutation::MutationInterface),
          mutations: [
          FakeMutation
            .new(reported_status: Crytic::Mutation::Status::Errored)
            .as(Crytic::Mutation::MutationInterface)
        ]),
        reporters: [reporter] of Crytic::Reporter::Reporter,
        no_mutation_factory: fake_no_mutation_factory)

      runner.run("./fixtures/simple/bar.cr", ["./fixtures/simple/bar_spec.cr"])

      reporter.events.should_not contain("report_result")
    end

    it "reports events in order" do
      reporter = FakeReporter.new
      runner = Crytic::Runner.new(
        threshold: 100.0,
        generator: FakeGenerator.new([FakeMutation.new.as(Crytic::Mutation::MutationInterface)]),
        reporters: [reporter] of Crytic::Reporter::Reporter,
        no_mutation_factory: fake_no_mutation_factory)

      runner.run("./fixtures/simple/bar.cr", ["./fixtures/simple/bar_spec.cr"])

      reporter.events.should eq ["report_original_result", "report_mutations", "report_neutral_result", "report_result", "report_summary", "report_msi"]
    end
  end
end

private def runner
  Crytic::Runner.new(
    threshold: 100.0,
    reporters: [Crytic::Reporter::IoReporter.new(IO::Memory.new)] of Crytic::Reporter::Reporter,
    generator: FakeGenerator.new)
end

private def fake_no_mutation_factory
  ->(specs : Array(String)) {
    no_mutation = Crytic::Mutation::NoMutation.with(specs)
    no_mutation.process_runner = Crytic::FakeProcessRunner.new
    no_mutation
  }
end
