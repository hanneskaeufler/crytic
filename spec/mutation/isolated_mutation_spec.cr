require "../../src/crytic/mutant/and_or_swap"
require "../../src/crytic/mutant/bool_literal_flip"
require "../../src/crytic/mutation/isolated_mutation"
require "../spec_helper"

module Crytic::Mutation
  describe Mutation do
    Spec.before_each do
      InjectMutatedSubjectIntoSpecs.reset
    end

    describe ".with" do
      it "can be used with both types of mutations" do
        transformer_mutant = Crytic::Mutant::AndOrSwap.at(location_at(0, 0))
        IsolatedMutation.with(
          original: "./bar.cr",
          specs: ["./bar_spec.cr"],
          mutant: transformer_mutant,
          preamble: no_preamble).should be_a(Crytic::Mutation::Mutation)
      end
    end

    describe "#run" do
      it "shoves the code into a tempfile, compiles the binary and executes the binary" do
        mutation = IsolatedMutation.with(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_spec.cr"],
          no_preamble)

        fake = FakeProcessRunner.new
        mutation.process_runner = fake
        mutation.file_remover = ->FakeFile.delete(String)
        mutation.tempfile_writer = ->FakeFile.tempfile(String, String, String)

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
        mutation = IsolatedMutation.with(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_spec.cr"],
          no_preamble)

        fake = FakeProcessRunner.new
        fake.exit_code = [0, 1]
        fake.fill_output_with("Finished")
        mutation.process_runner = fake
        mutation.file_remover = ->FakeFile.delete(String)
        mutation.tempfile_writer = ->FakeFile.tempfile(String, String, String)

        mutation.run.status.should eq Status::Covered
      end

      it "considers a mutant uncovered if the process succeeds" do
        mutation = IsolatedMutation.with(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_spec.cr"],
          no_preamble)

        fake = FakeProcessRunner.new
        fake.exit_code = [0, 0]
        mutation.process_runner = fake
        mutation.file_remover = ->FakeFile.delete(String)
        mutation.tempfile_writer = ->FakeFile.tempfile(String, String, String)

        mutation.run.status.should eq Status::Uncovered
      end

      it "returns a colored diff of the changes" do
        mutation = IsolatedMutation.with(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_spec.cr"],
          no_preamble)

        fake = FakeProcessRunner.new
        fake.exit_code = [0, 0]
        mutation.process_runner = fake
        mutation.file_remover = ->FakeFile.delete(String)
        mutation.tempfile_writer = ->FakeFile.tempfile(String, String, String)

        mutation.run.diff.should eq <<-DIFF
        @@ -1,5 +1,5 @@\n def bar\n\e[31m-\e[0m\e[31m  if true\e[0m\n\e[32m+\e[0m\e[32m  if false\e[0m\n     2\n   else\n     3\n
        DIFF
      end

      it "resolves nested requires" do
        mutation = IsolatedMutation.with(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_with_helper_spec.cr"],
          no_preamble)

        fake = FakeProcessRunner.new
        fake.exit_code = [0, 0]
        mutation.process_runner = fake
        mutation.file_remover = ->FakeFile.delete(String)
        mutation.tempfile_writer = ->FakeFile.tempfile(String, String, String)

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
        mutation = IsolatedMutation.with(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_with_helper_spec.cr", "./fixtures/simple/bar_additional_spec.cr"],
          no_preamble)

        fake = FakeProcessRunner.new
        mutation.process_runner = fake
        mutation.file_remover = ->FakeFile.delete(String)
        mutation.tempfile_writer = ->FakeFile.tempfile(String, String, String)

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
        mutation = IsolatedMutation.with(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_with_helper_spec.cr"],
          no_preamble)

        fake = FakeProcessRunner.new
        fake.exit_code = [1]
        fake.fill_output_with("compiler error/ no specs have run")
        mutation.process_runner = fake
        mutation.file_remover = ->FakeFile.delete(String)
        mutation.tempfile_writer = ->FakeFile.tempfile(String, String, String)

        mutation.run.status.should eq Status::Errored
      end

      it "reports timed out mutations" do
        mutation = IsolatedMutation.with(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_with_helper_spec.cr"],
          no_preamble)

        fake = FakeProcessRunner.new
        fake.exit_code = [0, 28]
        mutation.process_runner = fake
        mutation.file_remover = ->FakeFile.delete(String)
        mutation.tempfile_writer = ->FakeFile.tempfile(String, String, String)

        mutation.run.status.should eq Status::Timeout
        fake.timeout.last.should eq 10.seconds
      end

      it "can handle compilation errors" do
        mutation = IsolatedMutation.with(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_with_helper_spec.cr"],
          no_preamble)

        fake = FakeProcessRunner.new
        fake.exit_code = [1]
        mutation.process_runner = fake
        mutation.file_remover = ->FakeFile.delete(String)
        mutation.tempfile_writer = ->FakeFile.tempfile(String, String, String)

        mutation.run.status.should eq Status::Errored
      end

      it "prepends the preamble" do
        preamble = <<-CODE
        require "spec"
        Spec.fail_fast = true
        CODE

        mutation = IsolatedMutation.with(
          mutant,
          "./fixtures/simple/bar.cr",
          ["./fixtures/simple/bar_spec.cr"],
          preamble)

        fake = FakeProcessRunner.new
        mutation.process_runner = fake
        mutation.file_remover = ->FakeFile.delete(String)
        mutation.tempfile_writer = ->FakeFile.tempfile(String, String, String)

        mutation.run
        FakeFile.tempfile_contents.last.should start_with(preamble)
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

private class FakeFile
  @@files_deleted = [] of String
  @@tempfiles_created = [] of String
  @@tempfile_contents = [] of String

  def self.tempfile_contents
    @@tempfile_contents
  end

  def self.delete(filename : String)
  end

  def self.tempfile(name, extension, content) : String
    filename = "#{name}.RANDOM#{extension}"
    @@tempfile_contents << content
    @@tempfiles_created << filename
    "/tmp/#{filename}"
  end
end

private def no_preamble
  ""
end
