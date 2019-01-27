require "../mutant/**"
require "../mutation/mutation"
require "./generator"
require "compiler/crystal/syntax/*"

module Crytic
  # Determines all possible mutations for the given source files.
  class InMemoryMutationsGenerator < Generator
    alias MutationFactory = (Mutant::Mutant, String, Array(String), String) -> Mutation::MutationInterface

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

    property mutation_factory : MutationFactory = ->(mutant : Mutant::Mutant, original : String, specs : Array(String), preamble : String) {
      Mutation::Mutation
        .with(mutant, original, specs, preamble)
        .as(Mutation::MutationInterface)
    }

    def initialize(@possibilities : Array(Mutant::Possibilities), @preamble : String)
    end

    def mutations_for(sources : Array(String), specs : Array(String))
      sources
        .map do |src|
          MutationSet.new(
            neutral: noop_mutation_for(src, specs),
            mutated: mutations_for(src, specs)
          )
        end
        .reject(&.mutated.empty?)
    end

    private def noop_mutation_for(src, specs) : Mutation::MutationInterface
      mutation_factory.call(noop_mutant_for(src), src, specs, @preamble)
    end

    private def noop_mutant_for(src)
      Mutant::Noop.at(Mutant::FullLocation.new(Crystal::Location.new(src, 0, 0)))
    end

    private def mutations_for(source : String, specs : Array(String)) : Array(Mutation::MutationInterface)
      ast = ast_for(source: source)

      @possibilities
        .map(&.reset)
        .map do |inspector|
          ast.accept(inspector)
          inspector
        end
        .select(&.any?)
        .map do |inspector|
          inspector.locations.map do |location|
            mutation_factory.call(
              inspector.mutant_class.at(location), source, specs, @preamble)
          end
        end
        .flatten
    end

    private def ast_for(source)
      Crystal::Parser
        .new(File.read(source))
        .tap { |parser| parser.filename = source }
        .parse
    end
  end
end
