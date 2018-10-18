require "spec"
require "../src/crytic/io_reporter"
require "../src/crytic/mutant/number_literal_change"

private def fake_mutant
  Crytic::Mutant::NumberLiteralChange.at(Crystal::Location.new(filename: nil, line_number: 0, column_number: 0))
end

private def original
  Process::Status.new(0)
end

module Crytic
  describe IoReporter do
    describe "#report" do
      it "prints the original suites status" do
        io = IO::Memory.new
        IoReporter.new(io).report(original, [] of Mutation::Result)
        io.to_s.should contain("Original suite: ✅\n")
      end

      it "prints the passing mutants name with the count" do
        io = IO::Memory.new
        original = Process::Status.new(0)
        results = [
          Mutation::Result.new(is_covered: true, did_error: false, mutant: fake_mutant, diff: ""),
          Mutation::Result.new(is_covered: true, did_error: false, mutant: fake_mutant, diff: ""),
        ]
        IoReporter.new(io).report(original, results)
        io.to_s.should contain("✅ NumberLiteralChange (x2)")
      end

      it "prints failing mutants with count and diffs" do
        io = IO::Memory.new
        results = [
          Mutation::Result.new(is_covered: false, did_error: false, mutant: fake_mutant, diff: "diff"),
          Mutation::Result.new(is_covered: true, did_error: false, mutant: fake_mutant, diff: "nope"),
        ]
        IoReporter.new(io).report(original, results)
        io.to_s.should contain("❌ NumberLiteralChange (x2)")
        io.to_s.should contain("diff")
        io.to_s.should_not contain("nope")
      end

      it "prints errored mutants" do
        io = IO::Memory.new
        results = [
          Mutation::Result.new(is_covered: false, did_error: true, mutant: fake_mutant, diff: "diff"),
        ]
        IoReporter.new(io).report(original, results)
        io.to_s.should contain("❌ NumberLiteralChange")
        io.to_s.should contain("The following change broke the code")
        io.to_s.should contain("diff")
      end
    end
  end
end
