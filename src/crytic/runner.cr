require "./source"
require "./mutant/**"
require "./mutation/mutation"
require "./mutation/no_mutation"

module Crytic
  class Runner
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
      @io << "Mutations covered by tests:\n"
      @io << "#{results.map { |res| res.is_covered ? "\n✅ #{res.mutant_name}" : "\n❌ #{res.mutant_name}" }.join("")}"

      return results.map(&.is_covered).all?
    end
  end
end
