require "../mutant/**"
require "../mutation/mutation"
require "../subject"

module Crytic::Generator
  record MutationSet, neutral : Mutation::Mutation, mutated : Array(Mutation::Mutation) do
    def number_of_mutations
      mutated.size
    end

    def run_neutral(run)
      result = neutral.run
      run.report_neutral_result(result)
      result
    end

    def run_mutated(run)
      mutated.map do |mutation|
        result = mutation.run
        run.report_result(result)
        result
      end
    end
  end

  abstract class Generator
    ALL_MUTANTS = [
      Mutant::AndOrSwapPossibilities.new,
      Mutant::AnyAllSwapPossibilities.new,
      Mutant::BoolLiteralFlipPossibilities.new,
      Mutant::ConditionFlipPossibilities.new,
      Mutant::NumberLiteralChangePossibilities.new,
      Mutant::NumberLiteralSignFlipPossibilities.new,
      Mutant::RegexLiteralChangePossibilities.new,
      Mutant::SelectRejectSwapPossibilities.new,
      Mutant::StringLiteralChangePossibilities.new,
    ] of Mutant::Possibilities

    DEFAULT_PREAMBLE = <<-CODE
    require "spec"
    Spec.fail_fast = true

    CODE

    abstract def mutations_for(
      subject : Array(Subject),
      specs : Array(String)
    ) : Array(MutationSet)
  end
end
