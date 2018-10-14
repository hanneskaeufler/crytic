require "../../src/crytic/mutation/no_mutation"
require "./fake_process_runner"
require "spec"

module Crytic::Mutation
  describe NoMutation do
    it "runs crystal spec with the spec files" do
      mutation = NoMutation.with(["./multiple/test.specs"])
      fake = FakeProcessRunner.new
      mutation.process_runner = fake
      mutation.run

      fake.cmd.should eq "crystal"
      fake.args.should eq "spec ./multiple/test.specs"
    end
  end
end
