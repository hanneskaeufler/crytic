require "./source"
require "./mutant/**"
require "./mutation/mutation"
require "./mutation/no_mutation"

module Crytic
  class Runner
    INDENT = "    "
    MUTANTS = [
      Mutant::ConditionFlip.new,
      Mutant::NumberLiteralChange.new,
      Mutant::NumberLiteralSignFlip.new,
      Mutant::BoolLiteralFlip.new,
    ]

    def initialize(@io = IO::Memory.new)
    end

    def run(source : String, specs : Array(String)) : Bool
      original_result = NoMutation.with(original: source, specs: specs).run
      # return original_result.exit_code == 0
      # pp original_result

      results = MUTANTS.map do |mutant|
        Mutation.with(mutant: mutant, original: source, specs: specs).run
      end.select(&.applicable)

      @io << "Original suite: "
      @io << "#{original_result.exit_code == 0 ? "✅" : "❌"}\n"
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

      return results.map(&.is_covered).all?
    end
  end
end
