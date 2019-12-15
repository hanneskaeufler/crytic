require "../../src/crytic/mutation/no_mutation"
require "../../src/crytic/runner/sequential"
require "../spec_helper"

module Crytic::Runner
  def self.subjects(paths)
    paths.map { |path| Subject.from_filepath(path) }
  end

  describe Sequential do
    describe "#run" do
      it "returns false if threshold ain't reached" do
        run = Run.new(
            msi_threshold: 100.0,
            reporters: [] of Crytic::Reporter::Reporter,
            subjects: subjects(["./fixtures/require_order/blog.cr", "./fixtures/require_order/pages/blog/archive.cr"]),
            spec_files: ["./fixtures/simple/bar_spec.cr"]
        )
        runner = Sequential.new(
          generator: FakeGenerator.new,
          no_mutation_factory: fake_no_mutation_factory)

        runner.run(run).should eq false
      end

      it "doesn't execute mutations if the initial suite run fails" do
        run = Run.new(
            msi_threshold: 100.0,
            reporters: [] of Crytic::Reporter::Reporter,
            subjects: subjects(["./fixtures/require_order/blog.cr", "./fixtures/require_order/pages/blog/archive.cr"]),
            spec_files: ["./fixtures/simple/bar_spec.cr"]
        )
        runner = Sequential.new(
          generator: FakeGenerator.new,
          no_mutation_factory: ->(specs : Array(String)) {
            process_runner = Crytic::FakeProcessRunner.new
            no_mutation = Crytic::Mutation::NoMutation.with(specs, process_runner)
            process_runner.exit_code = [1, 0]
            no_mutation
          })

        runner.run(run).should eq false
      end

      it "reports events in order" do
        reporter = FakeReporter.new
        run = Run.new(
            msi_threshold: 100.0,
            reporters: [reporter] of Crytic::Reporter::Reporter,
            subjects: subjects(["./fixtures/simple/bar.cr"]),
            spec_files: ["./fixtures/simple/bar_spec.cr"]
        )
        runner = Sequential.new(
          generator: FakeGenerator.new([fake_mutation]),
          no_mutation_factory: fake_no_mutation_factory)

        runner.run(run)

        reporter.events.should eq ["report_original_result", "report_mutations", "report_neutral_result", "report_result", "report_summary", "report_msi"]
      end

      it "skips the mutations if the neutral result errored" do
        reporter = FakeReporter.new
        run = Run.new(
            msi_threshold: 100.0,
            reporters: [reporter] of Crytic::Reporter::Reporter,
            subjects: subjects(["./fixtures/simple/bar.cr"]),
            spec_files: ["./fixtures/simple/bar_spec.cr"]
        )
        mutation = fake_mutation
        runner = Sequential.new(
          generator: FakeGenerator.new(
            neutral: erroring_mutation,
            mutations: [mutation]),
          no_mutation_factory: fake_no_mutation_factory)

        runner.run(run)

        reporter.events.should_not contain("report_result")
        mutation.as(FakeMutation).run_call_count.should eq 0
      end
    end
  end
end

private def runner
  Crytic::Runner::Sequential.new(
    threshold: 100.0,
    reporters: [] of Crytic::Reporter::Reporter,
    generator: FakeGenerator.new)
end
