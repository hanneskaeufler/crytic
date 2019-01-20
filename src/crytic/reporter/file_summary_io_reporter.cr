module Crytic::Reporter
  class FileSummaryIoReporter
    private MUTANTS = "Mutants"

    def initialize(@io : IO)
    end

    def report_summary(results)
      width = results.map(&.mutated_file.size).max? || 0
      header = header(width)

      @io.puts header
      @io.puts "-".rjust(header.size, '-')

      results
        .group_by(&.mutated_file)
        .each do |filename, results|
        @io.puts "| #{filename.ljust(width)} | #{results.size.to_s.rjust(MUTANTS.size)} |"
        end
      @io.puts "-".rjust(header.size, '-')
    end

    private def header(width)
      "|#{" File ".ljust(width + 2)}| #{MUTANTS} |"
    end
  end
end
