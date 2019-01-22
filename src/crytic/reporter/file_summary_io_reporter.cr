require "./reporter"
require "../msi_calculator"

module Crytic::Reporter
  class FileSummaryIoReporter < Reporter
    private ERRORED   = "Errored"
    private KILLED    = "Killed"
    private MSI       = "   MSI   "
    private MUTANTS   = "Mutants"
    private TIMEOUT   = "Timeout"
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
      total_width = header(results.longest_mutated_filename_length)

      results
        .grouped_by_mutated_file
        .each do |filename, by_filename|
          table_row(filename, by_filename, results.longest_mutated_filename_length)
        end

      footer(total_width)
    end

    def report_msi(results)
    end

    private def table_row(filename, by_filename, longest_width)
      file = filename.ljust(longest_width)
      total = by_filename.total_count.to_s.rjust(MUTANTS.size)
      msi = MsiCalculator.new(by_filename).msi.to_s.rjust(MSI.size)
      covered = by_filename.covered_count.to_s.rjust(KILLED.size)
      timeout = by_filename.timeout_count.to_s.rjust(TIMEOUT.size)
      errored = by_filename.errored_count.to_s.rjust(ERRORED.size)
      uncovered = by_filename.uncovered_count.to_s.rjust(UNCOVERED.size)
      @io.puts "| #{file} | #{msi} | #{total} | #{covered} | #{timeout} | #{errored} | #{uncovered} |"
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
        [MSI, MUTANTS, KILLED, TIMEOUT, ERRORED, UNCOVERED].join(" | ") + " |"
    end
  end
end
