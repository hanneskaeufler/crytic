require "../../src/crytic/mutant/and_or_swap"
require "../../src/crytic/mutant/bool_literal_flip"
require "../../src/crytic/mutation/isolated_mutation"
require "../spec_helper"

module Crytic::Mutation
  describe Mutation do
    describe ".with" do
      it "can be used with both types of mutations" do
        transformer_mutant = Crytic::Mutant::AndOrSwap.at(location_at(0, 0))
        IsolatedMutation.with(environment(config(
          original: "./fixtures/simple/bar.cr",
          specs: ["./bar_spec.cr"],
          mutant: transformer_mutant)))
          .should be_a(Crytic::Mutation::Mutation)
      end
    end

    describe "#run" do
      it "shoves the code into a tempfile, compiles the binary and executes the binary" do
        fake = FakeProcessRunner.new
        mutation = IsolatedMutation.with(environment(config(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_spec.cr"]),
          process_runner: fake))

        mutation.run.should be_a(Crytic::Mutation::Result)
        fake.cmd_with_args[-2].should eq "crystal build -o /tmp/crytic.RANDOM --no-debug /tmp/crytic.RANDOM.cr"
        fake.cmd_with_args.last.should eq "/tmp/crytic.RANDOM"
        FakeFile.tempfile_contents.last.should eq <<-CODE
        # require of `fixtures/simple/bar.cr` from `fixtures/simple/bar_spec.cr`
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
        fake = FakeProcessRunner.new
        fake.exit_code = [0, 1]
        fake.fill_output_with("Finished")

        mutation = IsolatedMutation.with(environment(config(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_spec.cr"]),
          process_runner: fake))

        mutation.run.status.should eq Status::Covered
      end

      it "considers a mutant uncovered if the process succeeds" do
        fake = FakeProcessRunner.new
        fake.exit_code = [0, 0]
        mutation = IsolatedMutation.with(environment(config(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_spec.cr"])))

        mutation.run.status.should eq Status::Uncovered
      end

      it "returns a colored diff of the changes" do
        mutation = IsolatedMutation.with(environment(config(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_spec.cr"])))

        # When running this spec as part of crytic, we have to
        # explicitly enable the colorization because otherwise
        # it is evaluated that the spec isn't run from a tty
        # and doesn't support coloring. This is the case
        # since crystal 0.32.0 by the following change:
        # https://github.com/crystal-lang/crystal/pull/8271/files#diff-0c497e87ce156eb81914a478f8564cc2R81
        Colorize.enabled = true

        mutation.run.diff.should eq <<-DIFF
        @@ -1,5 +1,5 @@\n def bar\n\e[31m-\e[39m\e[31m  if true\e[39m\n\e[32m+\e[39m\e[32m  if false\e[39m\n     2\n   else\n     3\n
        DIFF
      end

      it "resolves nested requires" do
        mutation = IsolatedMutation.with(environment(config(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_with_helper_spec.cr"])))

        mutation.run
        FakeFile.tempfile_contents.last.should eq <<-CODE
        # require of `fixtures/simple/spec_helper.cr` from `fixtures/simple/bar_with_helper_spec.cr`
        require "http"
        # require of `fixtures/simple/bar.cr` from `fixtures/simple/spec_helper.cr`
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

      it "only requires/includes the subject once for multiple spec files" do
        mutation = IsolatedMutation.with(environment(config(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_with_helper_spec.cr", "./fixtures/simple/bar_additional_spec.cr"])))

        mutation.run

        FakeFile.tempfile_contents.last.should eq <<-CODE
        # require of `fixtures/simple/spec_helper.cr` from `fixtures/simple/bar_with_helper_spec.cr`
        require "http"
        # require of `fixtures/simple/bar.cr` from `fixtures/simple/spec_helper.cr`
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


        require "spec"

        describe("bar") do
          it("works") do
            2.should(eq(2))
          end
        end

        CODE
      end

      it "considers errors/failed to compile as not covered" do
        fake = FakeProcessRunner.new
        fake.exit_code = [1]
        fake.fill_output_with("compiler error/ no specs have run")
        mutation = IsolatedMutation.with(environment(config(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_with_helper_spec.cr"]),
          process_runner: fake))

        mutation.run.status.should eq Status::Errored
      end

      it "reports timed out mutations" do
        fake = FakeProcessRunner.new
        fake.exit_code = [0, 28]
        mutation = IsolatedMutation.with(environment(config(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_with_helper_spec.cr"]),
          fake))

        mutation.run.status.should eq Status::Timeout
        fake.timeout.last.should eq 10.seconds
      end

      it "can handle compilation errors" do
        fake = FakeProcessRunner.new
        fake.exit_code = [1]
        mutation = IsolatedMutation.with(environment(config(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_with_helper_spec.cr"]),
          fake))

        mutation.run.status.should eq Status::Errored
      end

      it "prepends the preamble" do
        preamble = <<-CODE
        require "spec"
        Spec.fail_fast = true
        CODE

        mutation = IsolatedMutation.with(environment(config(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_spec.cr"],
          preamble: preamble)))

        mutation.run
        FakeFile.tempfile_contents.last.should start_with(preamble)
      end

      it "saves the error output when binary compilation failed" do
        fake = FakeProcessRunner.new
        fake.exit_code = [1]
        fake.fill_output_with "this is the error"
        mutation = IsolatedMutation.with(environment(config(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_with_helper_spec.cr"]),
          process_runner: fake))

        mutation.run.output.should eq "this is the error"
      end

      it "saves the error output when binary execution failed" do
        fake = FakeProcessRunner.new
        fake.exit_code = [0, 1]
        fake.fill_output_with "this is the error"
        mutation = IsolatedMutation.with(environment(config(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_with_helper_spec.cr"]),
          process_runner: fake))

        mutation.run.output.should eq "this is the error"
        fake.errors.last.to_s.should eq "this is the error"
      end
    end
  end
end

private def mutant
  Crytic::Mutant::BoolLiteralFlip.at(location_at(
    line_number: 2,
    column_number: 6,
  ))
end
