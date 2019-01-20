require "../../src/crytic/mutation/result"
require "../../src/crytic/reporter/file_summary_io_reporter"
require "../spec_helper"

module Crytic::Reporter
  describe FileSummaryIoReporter do
    describe "#report_summary" do
      it "outputs a table header and footer" do
        io = IO::Memory.new
        subject = FileSummaryIoReporter.new(io)
        results = [] of Mutation::Result

        subject.report_summary(results)

        io.to_s.should match /^\| File \| Mutants \|\n-+\n-+\n$/m
      end

      it "outputs a row for each mutated file" do
        io = IO::Memory.new
        subject = FileSummaryIoReporter.new(io)
        results = [result(filename: "subject.cr")] of Mutation::Result

        subject.report_summary(results)

        io.to_s.lines.size.should eq results.size + 3
        io.to_s.lines[2].should match /^\|\s+subject\.cr\s+\|\s+\d+\s+\|$/
      end

      it "groups table lines by filename" do
        io = IO::Memory.new
        subject = FileSummaryIoReporter.new(io)
        results = [
          result(filename: "subject.cr"),
          result(filename: "subject.cr"),
        ] of Mutation::Result

        subject.report_summary(results)

        io.to_s.lines.size.should eq 1 + 3
      end

      it "counts number of mutations per file" do
        io = IO::Memory.new
        subject = FileSummaryIoReporter.new(io)
        results = [
          result(filename: "subject.cr"),
          result(filename: "subject.cr"),
        ] of Mutation::Result

        subject.report_summary(results)
        number_of_mutations = /(\d+) \|$/m.match(io.to_s).try(&.[1])
        number_of_mutations.should eq "2"
      end

      it "pads to the max width" do
        io = IO::Memory.new
        subject = FileSummaryIoReporter.new(io)
        results = [
          result(filename: "subject.cr"),
          result(filename: "./some/long/friggin/path.cr"),
        ] of Mutation::Result

        subject.report_summary(results)
        io.to_s.lines.map(&.size).should eq [41, 41, 41, 41, 41]
      end
    end
  end
end
