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
      if result.did_error
        @io << "\n#{INDENT}"
        @io << "❌ #{result.mutant_name}"
        @io << "\n#{INDENT + INDENT}The following change broke the code:\n"
        @io << "#{INDENT + INDENT + INDENT}"
        @io << result.diff.lines.join("\n#{INDENT + INDENT + INDENT}")
        @io << "\n"
      elsif !result.is_covered
        @io << "\n#{INDENT}"
        @io << "❌ #{result.mutant_name}"
        @io << "\n#{INDENT + INDENT}The following change didn't fail the test-suite:\n"
        @io << "#{INDENT + INDENT + INDENT}"
        @io << result.diff.lines.join("\n#{INDENT + INDENT + INDENT}")
        @io << "\n"
      else
        @io << "\n#{INDENT}"
        @io << "✅ #{result.mutant_name}"
      end
    end

    def report_summary(results)
      @io << "\n\nFinished in #{Spec.to_human(elapsed_time)}:\n"
      summary = "#{results.size} mutations, "
      summary += "#{results.select(&.is_covered).size} covered, "
      summary += "#{results.reject(&.is_covered).reject(&.did_error).size} uncovered, "
      summary += "#{results.select(&.did_error).size} errored"
      summary += "\n"
      @io << summary.colorize(results.map(&.successful?).all? ? :green : :red).to_s
    end

    private def elapsed_time
      Time.now - @start_time
    end
  end
end
