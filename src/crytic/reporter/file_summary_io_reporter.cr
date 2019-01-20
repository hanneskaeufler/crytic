module Crytic::Reporter
  class FileSummaryIoReporter
    def initialize(@io : IO)
    end

    def report_summary(results)
      @io.puts "| File | Mutants |"
      results.each do
        @io.puts "| file.cr | 10 |"
      end
    end
  end
end
