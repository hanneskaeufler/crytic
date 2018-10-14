require "./mutation/mutation"

module Crytic
  class IoReporter
    INDENT = "    "

    def initialize(@io : IO)
    end

    def report(original_result, results)
      @io << "Original suite: ✅\n"
      @io << "Mutations covered by tests:\n\n"
      results.map do |result|
        @io << INDENT
        @io << (result.is_covered ? "✅ #{result.mutant_name}" : "❌ #{result.mutant_name}")

        unless result.is_covered
          @io << "\n#{INDENT + INDENT}The following change didn't fail the test-suite:\n"
          @io << "#{INDENT + INDENT + INDENT}"
          @io << result.diff.lines.join("\n#{INDENT + INDENT + INDENT}")
          @io << "\n"
        end

        @io << "\n"
      end
    end
  end
end
