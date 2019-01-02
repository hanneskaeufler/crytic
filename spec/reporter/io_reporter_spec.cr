require "../../src/crytic/mutant/number_literal_change"
require "../../src/crytic/mutation/original_result"
require "../../src/crytic/reporter/io_reporter"
require "../fake_mutation"
require "../spec_helper"

private def original(exit_code = 0, output = "output")
  Crytic::Mutation::OriginalResult.new(exit_code: exit_code, output: output)
end

private def result(status)
  Crytic::Mutation::Result.new(status: status, mutant: fake_mutant, diff: "diff")
end

module Crytic::Reporter
  describe IoReporter do
    describe "#report_original_result" do
      it "prints the original passing suites status" do
        io = IO::Memory.new
        IoReporter.new(io).report_original_result(original)
        io.to_s.should contain("✅ Original test suite passed.\n")
      end

      it "prints the original suites failing status" do
        io = IO::Memory.new
        IoReporter.new(io).report_original_result(original(1, "failed!!!"))
        io.to_s.should contain("❌ Original test suite failed.")
        io.to_s.should contain("failed!!!")
      end
    end

    describe "#report_mutations" do
      it "prints no mutations if there are none to be run" do
        io = IO::Memory.new
        IoReporter.new(io).report_mutations([] of Mutation::Mutation)
        io.to_s.should eq("No mutations to be run.")
      end

      it "prints 1 mutation being run" do
        io = IO::Memory.new
        mutation = FakeMutation.new
        IoReporter.new(io).report_mutations([mutation])
        io.to_s.should eq("Running 1 mutation.")
      end

      it "prints more than one mutation being run" do
        io = IO::Memory.new
        mutation = FakeMutation.new
        IoReporter.new(io).report_mutations([mutation])
        io.to_s.should eq("Running 1 mutation.")
      end
    end

    describe "#report_result" do
      it "prints the passing mutants name and location" do
        io = IO::Memory.new
        IoReporter.new(io).report_result(result(Mutation::Status::Covered))
        io.to_s.should contain("✅ NumberLiteralChange at line 0, column 0")
      end

      it "prints failing mutants name" do
        io = IO::Memory.new
        IoReporter.new(io).report_result(result(Mutation::Status::Uncovered))
        io.to_s.should contain("❌ NumberLiteralChange")
        io.to_s.should contain("diff")
        io.to_s.should_not contain("nope")
      end

      it "prints errored mutant" do
        io = IO::Memory.new
        IoReporter.new(io).report_result(result(Mutation::Status::Errored))
        io.to_s.should contain("✅ NumberLiteralChange at line 0, column 0")
      end

      it "prints timed out mutants" do
        io = IO::Memory.new
        IoReporter.new(io).report_result(result(Mutation::Status::Timeout))
        io.to_s.should contain("✅ NumberLiteralChange at line 0, column 0")
      end
    end

    describe "#report_summary" do
      it "outputs result counts with a score" do
        io = IO::Memory.new
        results = [
          result(Mutation::Status::Uncovered),
          result(Mutation::Status::Covered),
          result(Mutation::Status::Errored),
          result(Mutation::Status::Timeout),
        ]
        IoReporter.new(io).report_summary(results)
        io.to_s.should contain "Finished in"
        io.to_s.should contain "4 mutations, 1 covered, 1 uncovered, 1 errored, 1 timeout. Mutation Score Indicator (MSI): 75.0%"
      end

      it "has a N/A score for 0 results" do
        io = IO::Memory.new
        results = [] of Mutation::Result
        IoReporter.new(io).report_summary(results)
        io.to_s.should contain "Mutation Score Indicator (MSI): N/A"
      end
    end

    describe "#report_msi" do
      it "is a noop" do
        io = IO::Memory.new
        results = [] of Mutation::Result
        IoReporter.new(io).report_msi(results).should eq nil
        io.to_s.should eq ""
      end
    end
  end
end
