require "spec"
require "../../src/crytic/mutant/bool_literal_flip"
require "../../src/crytic/mutation/mutation"

class FakeProcessRunner < Crytic::Mutation::ProcessRunner
  getter cmd
  getter args
  property exit_code
  @args : String = ""

  def initialize
    @exit_code = 0
  end

  def run(cmd : String, args : Array(String), output, error)
    @cmd = cmd
    @args = args.join(" ")
    @exit_code
  end
end

module Crytic::Mutation
  describe Mutation do
    describe "#run" do
      it "evals the mutated code in a separate process" do
        mutant = Crytic::Mutant::BoolLiteralFlip.at(Crystal::Location.new(
          filename: nil,
          line_number: 2,
          column_number: 6,
        ))
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

      it "considers a mutant covered if the process fails" do
        mutant = Crytic::Mutant::BoolLiteralFlip.at(Crystal::Location.new(
          filename: nil,
          line_number: 2,
          column_number: 6,
        ))
        mutation = Mutation.with(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_spec.cr"])

        fake = FakeProcessRunner.new
        fake.exit_code = 1
        mutation.process_runner = fake

        mutation.run.is_covered.should eq true
      end

      it "considers a mutant uncovered if the process succeeds" do
        mutant = Crytic::Mutant::BoolLiteralFlip.at(Crystal::Location.new(
          filename: nil,
          line_number: 2,
          column_number: 6,
        ))
        mutation = Mutation.with(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_spec.cr"])

        fake = FakeProcessRunner.new
        fake.exit_code = 0
        mutation.process_runner = fake

        mutation.run.is_covered.should eq false
      end

      it "returns a colored diff of the changes" do
        mutant = Crytic::Mutant::BoolLiteralFlip.at(Crystal::Location.new(
          filename: nil,
          line_number: 2,
          column_number: 6,
        ))
        mutation = Mutation.with(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_spec.cr"])

        fake = FakeProcessRunner.new
        fake.exit_code = 0
        mutation.process_runner = fake

        mutation.run.diff.should eq <<-DIFF
        \e[90mdef bar\n  if \e[0m\n\e[31mtru\e[0m\n\e[32mfals\e[0m\n\e[90me\n    2\n  else\n    3\n  end\nend\e[0m\n\e[31m\n\e[0m\n
        DIFF
      end
    end
  end
end
