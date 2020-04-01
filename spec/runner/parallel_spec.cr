require "../../src/crytic/runner/parallel"
require "../spec_helper"

module Crytic::Runner
  describe Parallel do
    describe "#run" do
      it "returns false when the original suite failed" do
        run = FakeRun.new
        run.original_exit_code = 1

        res = Parallel.new.run(run, side_effects)

        res.should eq false
        run.original_call_count.should eq 1
      end

      it "generates mutations once" do
        run = FakeRun.new

        Parallel.new.run(run, side_effects)

        run.generate_mutations_call_count.should eq 1
      end

      it "returns the final result as per run" do
        run = FakeRun.new

        Parallel.new.run(run, side_effects).should eq true

        run.final_result = false
        Parallel.new.run(run, side_effects).should eq false
      end

      it "doesnt run the mutations if the neutral mutant failed" do
        run = FakeRun.new
        mutation = fake_mutation
        run.neutral = FakeMutation.new(Crytic::Mutation::Status::Errored)
        run.mutations = [mutation]

        Parallel.new.run(run, side_effects)
        mutation.as(FakeMutation).run_call_count.should eq 0
      end

      it "reports results for the neutral and mutation results in order" do
        run = FakeRun.new
        run.mutations = [fake_mutation]

        Parallel.new.run(run, side_effects)

        run.events.should eq ["report_neutral_result", "report_result"]
      end

      it "handles exception throwing mutations" do
        run = FakeRun.new
        run.mutations = [ThrowingMutation.new.as(Crytic::Mutation::Mutation)]

        Parallel.new.run(run, side_effects)

        run.events.should eq ["report_neutral_result", "report_exception"]
      end
    end
  end
end
