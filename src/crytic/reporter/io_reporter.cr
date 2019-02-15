require "../msi_calculator"
require "../mutation/mutation"
require "./reporter"
require "spec/dsl"

module Crytic::Reporter
  # Reports crytics output into an IO. Useful for e.g. the console output
  class IoReporter < Reporter
    INDENT = "    "

    def initialize(@io : IO, @start_time = Time.now)
    end

    def report_original_result(original_result)
      if original_result.exit_code != 0
        @io << "❌ Original test suite failed.\n"
        @io << original_result.output
      else
        @io << "✅ Original test suite passed.\n"
      end
    end

    def report_mutations(mutations : Array(Generator::MutationSet))
      number_of_mutations = mutations.sum(&.number_of_mutations)
      @io << "No mutations to be run." if number_of_mutations == 0
      @io << "Running 1 mutation." if number_of_mutations == 1
      @io << "Running #{number_of_mutations} mutations." if number_of_mutations > 1
    end

    def report_neutral_result(result)
      if result.errored?
        @io << "\n#{INDENT}🚧 #{result.mutant_name}"
        @io << "\n#{INDENT + INDENT}in #{result.location.filename}"
        @io << <<-HELP
        \n#{INDENT + INDENT}There was an error running the test-suite using crytic's infrastructure with the unmodified subject.\n#{INDENT + INDENT}This is very likely a bug in crytic, please go ahead and file an\n#{INDENT + INDENT}issue at https://github.com/hanneskaeufler/crytic/issues. There are a number of known limitations already which\n#{INDENT + INDENT}could be the reason for the error, see https://github.com/hanneskaeufler/crytic/issues/19.\n
        HELP
        @io << "#{INDENT + INDENT + INDENT} #{result.output}"
      end
    end

    def report_result(result)
      @io << "\n#{INDENT}"
      case result.status
      when Mutation::Status::Uncovered
        @io << "❌ #{result.mutant_name}"
        @io << "\n#{INDENT + INDENT}in #{result.location}"
        @io << "\n#{INDENT + INDENT}The following change didn't fail the test-suite:"
        @io << "\n#{INDENT + INDENT + INDENT}"
        @io << result.diff.lines.join("\n#{INDENT + INDENT + INDENT}")
        @io << "\n"
      when Mutation::Status::Covered, Mutation::Status::Timeout, Mutation::Status::Errored
        @io << "✅ #{result.mutant_name}"
        @io << "\n#{INDENT + INDENT}in #{result.location}"
      else
        raise "There were mutations of unreported type"
      end
    end

    def report_summary(results : Mutation::ResultSet)
      @io << "\n\nFinished in #{Spec.to_human(elapsed_time)}:\n"
      summary = "#{results.total_count} mutations, "
      summary += "#{results.covered_count} covered, "
      summary += "#{results.uncovered_count} uncovered, "
      summary += "#{results.errored_count} errored, "
      summary += "#{results.timeout_count} timeout."
      summary += " Mutation Score Indicator (MSI): #{score_in_percent(results)}"
      summary += "\n"
      @io << summary.colorize(results.all_covered? ? :green : :red).to_s
    end

    # intentional noop
    def report_msi(results)
    end

    private def score_in_percent(results)
      MsiCalculator.new(results).msi.to_s
    end

    private def elapsed_time
      Time.now - @start_time
    end
  end
end
