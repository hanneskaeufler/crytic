require "../../src/crytic/mutation/no_mutation"
require "./fake_process_runner"
require "spec"

module Crytic::Mutation
  describe NoMutation do
    describe "#run" do
      it "runs crystal spec with a single spec file" do
        mutation = NoMutation.with(["./single/test_spec.cr"])
        fake = FakeProcessRunner.new
        mutation.process_runner = fake
        mutation.run

        fake.cmd.should eq "crystal"
        fake.args.should eq "spec ./single/test_spec.cr"
      end

      it "runs crystal spec with multiple spec files" do
        mutation = NoMutation.with(["./a/b_spec.cr", "./a/c_spec.cr"])
        fake = FakeProcessRunner.new
        mutation.process_runner = fake
        mutation.run

        fake.cmd.should eq "crystal"
        fake.args.should eq "spec ./a/b_spec.cr ./a/c_spec.cr"
      end
    end
  end
end
