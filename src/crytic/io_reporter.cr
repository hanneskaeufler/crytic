require "./mutation/mutation"

module Crytic
  class IoReporter
    INDENT = "    "

    def initialize(@io : IO)
    end

    def report(original_result, results)
      @io << "Original suite: ✅\n"
      @io << "Mutations covered by tests:\n\n"
      results
        .group_by(&.mutant_name)
        .map do |mutant_name, results_per_mutant|
          @io << INDENT
          all_mutants_covered = results_per_mutant.map(&.is_covered).all?

          @io << (all_mutants_covered ? "✅" : "❌")
          @io << " #{mutant_name} (x#{results_per_mutant.size})"

          results_per_mutant.each do |result|
            unless result.is_covered
              @io << "\n#{INDENT + INDENT}The following change didn't fail the test-suite:\n"
              @io << "#{INDENT + INDENT + INDENT}"
              @io << result.diff.lines.join("\n#{INDENT + INDENT + INDENT}")
              @io << "\n"
            end
          end

          @io << "\n"
        end
    end
  end
end
