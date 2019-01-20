require "../../src/crytic/mutation/result"
require "../../src/crytic/reporter/file_summary_io_reporter"
require "../spec_helper"

module Crytic::Reporter
  describe FileSummaryIoReporter do
    describe "#report_summary" do
      it "outputs a table header" do
        io = IO::Memory.new
        subject = FileSummaryIoReporter.new(io)
        results = [] of Mutation::Result

        subject.report_summary(results)

        io.to_s.should eq "| File | Mutants |\n"
      end

      it "outputs a row for each mutated file" do
        io = IO::Memory.new
        subject = FileSummaryIoReporter.new(io)
        results = [
          Mutation::Result.new(
            status: Crytic::Mutation::Status::Covered,
            mutant: fake_mutant(filename: "subject.cr"), diff: "diff"),
        ] of Mutation::Result

        subject.report_summary(results)

        io.to_s.lines.size.should eq results.size + 1
        io.to_s.lines[1].should eq "| subject.cr | 10 |"
      end
    end
  end
end
