require "../../src/crytic/mutation/no_mutation"
require "../spec_helper"

module Crytic::Mutation
  describe NoMutation do
    describe "#run" do
      it "runs crystal spec with a single spec file" do
        fake = FakeProcessRunner.new
        mutation = NoMutation.with(["./single/test_spec.cr"], fake)

        mutation.run

        fake.cmd_with_args.last.should eq "crystal spec ./single/test_spec.cr"
      end

      it "runs crystal spec with multiple spec files" do
        fake = FakeProcessRunner.new
        mutation = NoMutation.with(["./a/b_spec.cr", "./a/c_spec.cr"], fake)

        mutation.run

        fake.cmd_with_args.last.should eq "crystal spec ./a/b_spec.cr ./a/c_spec.cr"
      end
    end
  end
end
