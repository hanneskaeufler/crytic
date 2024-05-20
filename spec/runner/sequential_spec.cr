require "../../src/crytic/mutation/no_mutation"
require "../../src/crytic/runner/sequential"
require "../spec_helper"

module Crytic::Runner
  def self.subjects(paths)
    paths.map { |path| Subject.from_filepath(path) }
  end

  describe Sequential do
    describe "#run" do
      it "returns the runs final result" do
        run = FakeRun.new
        run.final_result = true

        Sequential.new.run(run, side_effects).should be_true

        run.final_result = false
        Sequential.new.run(run, side_effects).should be_false
      end

      it "returns false if the original spec suite fails" do
        run = FakeRun.new
        run.original_exit_code = 1

        Sequential.new.run(run, side_effects).should be_false
      end

      it "reports neutral results before mutation results" do
        run = FakeRun.new
        run.mutations = [FakeMutation.new.as(Crytic::Mutation::Mutation)]

        Sequential.new.run(run, side_effects)

        run.events.should eq ["report_neutral_result", "report_result"]
      end

      it "skips the mutations if the neutral result errored" do
        run = FakeRun.new
        mutation = fake_mutation
        run.neutral = FakeMutation.new(Crytic::Mutation::Status::Errored)
        run.mutations = [mutation]

        Sequential.new.run(run, side_effects)

        run.events.should_not contain("report_result")
        mutation.as(FakeMutation).run_call_count.should eq 0
      end
    end
  end
end

private class FakeRun
  property mutations = [] of Crytic::Mutation::Mutation
  property events = [] of String
  property original_exit_code = 0
  property? final_result = true
  property neutral = FakeMutation.new.as(Crytic::Mutation::Mutation)

  def generate_mutations
    [Crytic::Generator::MutationSet.new(neutral, mutations)]
  end

  def report_neutral_result(result)
    events << "report_neutral_result"
  end

  def report_result(result)
    events << "report_result"
  end

  def report_final(results)
    final_result?
  end

  def execute_original_test_suite(side_effects)
    Crytic::Mutation::OriginalResult.new(exit_code: original_exit_code, output: "")
  end
end
