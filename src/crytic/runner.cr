require "./source"
require "./mutant/**"
require "./mutation/mutation"
require "./mutation/no_mutation"

module Crytic
  class Runner
    MUTANTS = [
      Mutant::ConditionFlip.new,
      Mutant::NumberLiteralChange.new,
      Mutant::NumberLiteralSignFlip.new
    ]

    def initialize(@io = IO::Memory.new)
    end

    def run(source : String, specs : Array(String)) : Bool
      original_result = NoMutation.with(original: source, specs: specs).run
      # return original_result.exit_code == 0
      # pp original_result

      results = MUTANTS.map do |mutant|
        Mutation.with(mutant: mutant, original: source, specs: specs).run
      end

      @io << "Ran original suite: #{original_result.exit_code == 0 ? "Passed" : "Failed"}\n Mutations covered by tests:\n    #{results.map { |res| res.exit_code == 0 ? "F" : "." }.join("")}"

      return results.map(&.exit_code).sum > 0
    end
  end
end
