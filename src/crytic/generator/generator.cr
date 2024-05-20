require "../mutant/**"
require "../mutation/mutation"
require "../subject"

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
      Mutant::DropCallInVoidDefPossibilities.new,
      Mutant::NumberLiteralChangePossibilities.new,
      Mutant::NumberLiteralSignFlipPossibilities.new,
      Mutant::RegexLiteralChangePossibilities.new,
      Mutant::SelectRejectSwapPossibilities.new,
      Mutant::StringLiteralChangePossibilities.new,
      Mutant::SymbolLiteralChangePossibilities.new,
    ] of Mutant::Possibilities

    DEFAULT_PREAMBLE = <<-CODE
    require "spec"
    class Spec::CLI
      def fail_fast!
        @fail_fast = true
      end
    end
    Spec.cli.fail_fast!

    CODE

    abstract def mutations_for(
      subject : Array(Subject),
      specs : Array(String)
    ) : Array(MutationSet)
  end
end
