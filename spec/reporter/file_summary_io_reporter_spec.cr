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

        subject.report_summary(Mutation::ResultSet.new)

        io.to_s.should match /^\| File \|    MSI    \| Mutants \| Killed \| Timeout \| Errored \| Uncovered \|\n-+\n-+\n$/m
      end

      it "outputs a row for each mutated file" do
        io = IO::Memory.new
        subject = FileSummaryIoReporter.new(io)
        results = Mutation::ResultSet.new([result(filename: "subject.cr")])

        subject.report_summary(results)

        io.to_s.lines.size.should eq results.size + HEADER_AND_FOOTER_ROW_COUNT
        io.to_s.lines[3].should match /^\|\s+subject\.cr\s+\|/
      end

      it "groups table lines by filename" do
        io = IO::Memory.new
        subject = FileSummaryIoReporter.new(io)
        results = Mutation::ResultSet.new([
          result(filename: "subject.cr"),
          result(filename: "subject.cr"),
        ])

        subject.report_summary(results)

        io.to_s.lines.size.should eq 1 + HEADER_AND_FOOTER_ROW_COUNT
      end

      it "counts number of mutations per file" do
        io = IO::Memory.new
        subject = FileSummaryIoReporter.new(io)
        results = Mutation::ResultSet.new([
          result(status: Mutation::Status::Covered, filename: "subject.cr"),
          result(status: Mutation::Status::Timeout, filename: "subject.cr"),
          result(status: Mutation::Status::Timeout, filename: "subject.cr"),
          result(status: Mutation::Status::Errored, filename: "subject.cr"),
          result(status: Mutation::Status::Errored, filename: "subject.cr"),
          result(status: Mutation::Status::Errored, filename: "subject.cr"),
          result(status: Mutation::Status::Uncovered, filename: "subject.cr"),
          result(status: Mutation::Status::Uncovered, filename: "subject.cr"),
          result(status: Mutation::Status::Uncovered, filename: "subject.cr"),
          result(status: Mutation::Status::Uncovered, filename: "subject.cr"),
        ])

        subject.report_summary(results)

        number_of_mutations = io.to_s.lines[3].gsub(" ", "").split("|")[3..-2]
        number_of_mutations[0].should eq "10"
        number_of_mutations[1].should eq "1"
        number_of_mutations[2].should eq "2"
        number_of_mutations[3].should eq "3"
        number_of_mutations[4].should eq "4"
      end

      it "shows the mutation score indicator per file" do
        io = IO::Memory.new
        subject = FileSummaryIoReporter.new(io)
        results = Mutation::ResultSet.new([
          result(status: Mutation::Status::Covered, filename: "subject.cr"),
          result(status: Mutation::Status::Timeout, filename: "subject.cr"),
          result(status: Mutation::Status::Uncovered, filename: "subject.cr"),
        ])

        subject.report_summary(results)

        msi = /(\d+\.\d+)%/.match(io.to_s.lines[3]).try(&.[1])
        msi.should eq "66.67"
      end

      it "pads to the max width" do
        io = IO::Memory.new
        subject = FileSummaryIoReporter.new(io)
        results = Mutation::ResultSet.new([
          result(filename: "subject.cr"),
          result(filename: "./some/long/friggin/path.cr"),
        ])

        subject.report_summary(results)
        line_widths = io.to_s.lines.map(&.size)
        line_widths.max.should eq line_widths.min
      end
    end
  end
end
