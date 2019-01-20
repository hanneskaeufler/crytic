require "./reporter"

module Crytic::Reporter
  class FileSummaryIoReporter < Reporter
    private MUTANTS = "Mutants"

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
        .each do |filename, results|
          @io.puts "| #{filename.ljust(longest_width)} | #{results.size.to_s.rjust(MUTANTS.size)} |"
        end

      footer(total_width)
    end

    def report_msi(results)
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
      "|#{" File ".ljust(width + 2)}| #{MUTANTS} |"
    end
  end
end
