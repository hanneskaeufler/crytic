require "../mutant/**"
require "../mutation/mutation"

module Crytic::Generator
  record MutationSet, neutral : Mutation::Mutation, mutated : Array(Mutation::Mutation) do
    def number_of_mutations
      mutated.size
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

    abstract def mutations_for(source : Array(String), specs : Array(String)) : Array(MutationSet)
  end
end
