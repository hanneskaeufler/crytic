require "spec"
require "../../src/crytic/mutant/bool_literal_flip"
require "../../src/crytic/mutation/mutation"

class FakeProcessRunner < Crytic::Mutation::ProcessRunner
  getter cmd
  getter args
  @args : String = ""

  def run(cmd : String, args : Array(String), output, error)
    @cmd = cmd
    @args = args.join(" ")
    0
  end
end

module Crytic::Mutation
  describe Mutation do
    it "evals the mutated code in a separate process" do
      mutant = Crytic::Mutant::BoolLiteralFlip.new
      mutation = Mutation.with(
        mutant,
        "./fixtures/simple/bar.cr",
        ["./fixtures/simple/bar_spec.cr"])

      fake = FakeProcessRunner.new
      mutation.process_runner = fake

      mutation.run.should be_a(Crytic::Mutation::Result)
      fake.cmd.should eq "crystal"
      fake.args.should eq <<-CODE
      eval \ndef bar
        if false
          2
        else
          3
        end
      end

      require "spec"
      describe("bar") do
        it("works") do
          bar.should(eq(2))
        end
      end

      CODE
    end
  end
end
