require "../../src/crytic/runner/mutation_job"
require "../fake_mutation"
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
