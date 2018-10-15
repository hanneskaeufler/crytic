require "../../src/crytic/mutant/bool_literal_flip"
require "../../src/crytic/mutation/mutation"
require "./fake_process_runner"
require "spec"

module Crytic::Mutation
  describe Mutation do
    Spec.before_each do
      InjectMutatedSubjectIntoSpecs.reset
    end

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
        eval # require of `fixtures/simple/bar.cr` from `fixtures/simple/bar_spec.cr:1`
        def bar
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
        @@ -1,5 +1,5 @@\n def bar\n\e[31m-\e[0m\e[31m  if true\e[0m\n\e[32m+\e[0m\e[32m  if false\e[0m\n     2\n   else\n     3\n
        DIFF
      end

      it "resolves nested requires" do
        mutant = Crytic::Mutant::BoolLiteralFlip.at(Crystal::Location.new(
          filename: nil,
          line_number: 2,
          column_number: 6,
        ))
        mutation = Mutation.with(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_with_helper_spec.cr"])

        fake = FakeProcessRunner.new
        fake.exit_code = 0
        mutation.process_runner = fake

        mutation.run
        fake.cmd.should eq "crystal"
        fake.args.should eq <<-CODE
        eval # require of `fixtures/simple/spec_helper.cr` from `fixtures/simple/bar_with_helper_spec.cr:1`
        require "http"
        # require of `fixtures/simple/bar.cr` from `fixtures/simple/spec_helper.cr:2`
        def bar
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
end
