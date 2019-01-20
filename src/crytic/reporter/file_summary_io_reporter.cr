module Crytic::Reporter
  class FileSummaryIoReporter
    def initialize(@io : IO)
    end

    def report_summary(results)
      @io.puts "| File | Mutants |"
      results
        .group_by(&.mutated_file)
        .each do |filename, results|
          @io.puts "| #{results.first.mutated_file} | 10 |"
        end
      @io.puts "-----------"
    end
  end
end
