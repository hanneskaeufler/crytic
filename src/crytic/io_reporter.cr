require "./mutation/mutation"
require "spec/dsl"

module Crytic
  # Reports crytics output into an IO. Useful for e.g. the console output
  class IoReporter
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

    def report_result(result)
      @io << "\n#{INDENT}"
      case result.status
      when Mutation::Status::Errored
        @io << "❌ #{result.mutant_name}"
        @io << "\n#{INDENT + INDENT}The following change broke the code:\n"
        @io << "#{INDENT + INDENT + INDENT}"
        @io << result.diff.lines.join("\n#{INDENT + INDENT + INDENT}")
        @io << "\n"
      when Mutation::Status::Uncovered
        @io << "❌ #{result.mutant_name}"
        @io << "\n#{INDENT + INDENT}The following change didn't fail the test-suite:\n"
        @io << "#{INDENT + INDENT + INDENT}"
        @io << result.diff.lines.join("\n#{INDENT + INDENT + INDENT}")
        @io << "\n"
      when Mutation::Status::Covered
        @io << "✅ #{result.mutant_name} at line #{result.location.line_number}, column #{result.location.column_number}"
      when Mutation::Status::Timeout
        @io << "❌ #{result.mutant_name}"
        @io << "\n#{INDENT + INDENT}The following change timed out:\n"
        @io << "#{INDENT + INDENT + INDENT}"
        @io << result.diff.lines.join("\n#{INDENT + INDENT + INDENT}")
        @io << "\n"
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
      summary += " Mutation score: #{score_in_percent(results)}"
      summary += "\n"
      @io << summary.colorize(results.map(&.status.covered?).all? ? :green : :red).to_s
    end

    private def score_in_percent(results)
      return "N/A" if results.empty?
      "#{score(results)}%"
    end

    private def score(results)
      total = results.size
      killed = results.count(&.status.covered?)
      msi = killed.to_f / total * 100
      msi.round(2)
    end

    private def elapsed_time
      Time.now - @start_time
    end
  end
end
