require "../../src/crytic/mutant/bool_literal_flip"
require "../../src/crytic/mutation/result"
require "../../src/crytic/runner/mutation_job"
require "../fake_reporter"
require "../spec_helper"

module Crytic::Runner
  describe MutationJob do
    describe ".dispatch" do
      it "runs the mutation" do
        mutation = FakeMutation.new
        reporter = FakeReporter.new
        results = [] of Crytic::Mutation::Result

        MutationJob.dispatch(mutation, [reporter], results)
        sleep 0.01

        mutation.run_call_count.should eq 1
      end

      it "reports the mutations result" do
        mutation = FakeMutation.new
        reporter = FakeReporter.new
        results = [] of Crytic::Mutation::Result

        MutationJob.dispatch(mutation, [reporter], results)
        sleep 0.01

        reporter.events.should eq ["report_result"]
      end

      it "saves the result" do
        mutation = FakeMutation.new
        reporter = FakeReporter.new
        results = [] of Crytic::Mutation::Result

        MutationJob.dispatch(mutation, [reporter], results)
        sleep 0.01

        results.size.should eq 1
      end
    end
  end
end

class FakeMutation
  property run_call_count = 0

  def run
    @run_call_count += 1
    Crytic::Mutation::Result.new(Crytic::Mutation::Status::Covered, irrelevant_mutant, "")
  end
end

private def irrelevant_mutant
  Crytic::Mutant::BoolLiteralFlip.at(Crystal::Location.new(
    filename: nil,
    line_number: 2,
    column_number: 6,
  ))
end
