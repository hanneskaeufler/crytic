require "./mutation/mutation"

module Crytic
  # Reports crytics output into an IO. Useful for e.g. the console output
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
          all_mutants_successful = results_per_mutant.map(&.successful?).all?

          @io << (all_mutants_successful ? "✅" : "❌")
          @io << " #{mutant_name} (x#{results_per_mutant.size})"

          results_per_mutant.each do |result|
            if result.did_error
              @io << "\n#{INDENT + INDENT}The following change broke the code:\n"
              @io << "#{INDENT + INDENT + INDENT}"
              @io << result.diff.lines.join("\n#{INDENT + INDENT + INDENT}")
              @io << "\n"
            elsif !result.is_covered
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
