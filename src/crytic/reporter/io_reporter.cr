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

    def report_mutations(mutations)
      @io << "No mutations to be run." if mutations.empty?
      @io << "Running 1 mutation." if mutations.size == 1
      @io << "Running #{mutations.size} mutations." if mutations.size > 1
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

    def report_summary(results)
      @io << "\n\nFinished in #{Spec.to_human(elapsed_time)}:\n"
      summary = "#{results.size} mutations, "
      summary += "#{results.map(&.status).count(&.covered?)} covered, "
      summary += "#{results.map(&.status).count(&.uncovered?)} uncovered, "
      summary += "#{results.map(&.status).count(&.errored?)} errored, "
      summary += "#{results.map(&.status).count(&.timeout?)} timeout."
      summary += " Mutation Score Indicator (MSI): #{score_in_percent(results)}"
      summary += "\n"
      @io << summary.colorize(results.map(&.status.covered?).all? ? :green : :red).to_s
    end

    # intentional noop
    def report_msi(results)
    end

    private def score_in_percent(results)
      return "N/A" if results.empty?
      "#{MsiCalculator.new(results).msi}%"
    end

    private def elapsed_time
      Time.now - @start_time
    end
  end
end
