require "./reporter"

module Crytic::Reporter
  class FileSummaryIoReporter < Reporter
    private MUTANTS = "Mutants"
    private KILLED = "Killed"
    private TIMEOUT = "Timeout"
    private ERRORED = "Errored"
    private UNCOVERED = "Uncovered"

    def initialize(@io : IO)
    end

    def report_original_result(original_result)
    end

    def report_mutations(mutations)
    end

    def report_result(result)
    end

    def report_summary(results)
      longest_width = longest_filename_width(results)
      total_width = header(longest_width)

      results
        .group_by(&.mutated_file)
        .each do |filename, by_filename|
          table_row(filename, by_filename, longest_width)
        end

      footer(total_width)
    end

    def report_msi(results)
    end

    private def table_row(filename, by_filename, longest_width)
      file = filename.ljust(longest_width)
      total = by_filename.size.to_s.rjust(MUTANTS.size)
      covered = by_filename.select(&.status.covered?).size.to_s.rjust(KILLED.size)
      timeout = by_filename.select(&.status.timeout?).size.to_s.rjust(TIMEOUT.size)
      errored = by_filename.select(&.status.errored?).size.to_s.rjust(ERRORED.size)
      uncovered = by_filename.select(&.status.uncovered?).size.to_s.rjust(UNCOVERED.size)
      @io.puts "| #{file} | #{total} | #{covered} | #{timeout} | #{errored} | #{uncovered} |"
    end

    private def longest_filename_width(results)
      results.map(&.mutated_file.size).max? || 0
    end

    private def header(longest_filename_width)
      column_names = column_names(longest_filename_width)
      @io.puts ruler(column_names.size)
      @io.puts column_names
      @io.puts ruler(column_names.size)
      column_names.size
    end

    private def footer(width)
      @io.puts ruler(width)
    end

    private def ruler(width)
      "-".rjust(width, '-')
    end

    private def column_names(width)
      "|#{" File ".ljust(width + 2)}| " +
      [MUTANTS, KILLED, TIMEOUT, ERRORED, UNCOVERED].join(" | ") + " |"
    end
  end
end
