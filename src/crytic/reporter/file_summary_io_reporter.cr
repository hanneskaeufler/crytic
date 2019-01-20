module Crytic::Reporter
  class FileSummaryIoReporter
    def initialize(@io : IO)
    end

    def report_summary(results)
      @io.puts "| File | Mutants |"
      results.each do |result|
        @io.puts "| #{result.mutated_file} | 10 |"
      end
      @io.puts "-----------"
    end
  end
end
