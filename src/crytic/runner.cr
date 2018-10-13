require "./io_reporter"
require "./mutant/**"
require "./mutation/mutation"
require "./mutation/no_mutation"
require "./source"

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

      IoReporter.new(@io).report(original_result, results)

      return results.map(&.is_covered).all?
    end
  end
end
