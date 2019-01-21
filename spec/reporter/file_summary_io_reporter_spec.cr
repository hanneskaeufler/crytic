require "../../src/crytic/mutation/result"
require "../../src/crytic/reporter/file_summary_io_reporter"
require "../spec_helper"

module Crytic::Reporter
  HEADER_AND_FOOTER_ROW_COUNT = 4

  describe FileSummaryIoReporter do
    describe "#report_summary" do
      it "outputs a table header and footer" do
        io = IO::Memory.new
        subject = FileSummaryIoReporter.new(io)

        subject.report_summary([] of Mutation::Result)

        io.to_s.should match /^\| File \| Mutants \| Killed \|\n-+\n-+\n$/m
      end

      it "outputs a row for each mutated file" do
        io = IO::Memory.new
        subject = FileSummaryIoReporter.new(io)
        results = [result(filename: "subject.cr")]

        subject.report_summary(results)

        io.to_s.lines.size.should eq results.size + HEADER_AND_FOOTER_ROW_COUNT
        io.to_s.lines[3].should match /^\|\s+subject\.cr\s+\|/
      end

      it "groups table lines by filename" do
        io = IO::Memory.new
        subject = FileSummaryIoReporter.new(io)
        results = [
          result(filename: "subject.cr"),
          result(filename: "subject.cr"),
        ]

        subject.report_summary(results)

        io.to_s.lines.size.should eq 1 + HEADER_AND_FOOTER_ROW_COUNT
      end

      it "counts number of total and killed mutations per file" do
        io = IO::Memory.new
        subject = FileSummaryIoReporter.new(io)
        results = [
          result(status: Mutation::Status::Uncovered, filename: "subject.cr"),
          result(status: Mutation::Status::Covered, filename: "subject.cr"),
          result(status: Mutation::Status::Covered, filename: "subject.cr"),
        ]

        subject.report_summary(results)
        number_of_mutations = /(\d+) \|\s+(\d+) \|$/m.match(io.to_s)
        number_of_mutations.try(&.[1]).should eq "3"
        number_of_mutations.try(&.[2]).should eq "2"
      end

      it "pads to the max width" do
        io = IO::Memory.new
        subject = FileSummaryIoReporter.new(io)
        results = [
          result(filename: "subject.cr"),
          result(filename: "./some/long/friggin/path.cr"),
        ] of Mutation::Result

        subject.report_summary(results)
        line_widths = io.to_s.lines.map(&.size)
        line_widths.all? { |width| width == line_widths.first }.should eq true
      end
    end
  end
end
