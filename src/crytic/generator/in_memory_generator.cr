require "../mutant/**"
require "../mutation/mutation"
require "./generator"
require "compiler/crystal/syntax/*"

module Crytic
  # Determines all possible mutations for the given source files.
  class InMemoryMutationsGenerator < Generator
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

    def initialize(@possibilities : Array(Mutant::Possibilities), @preamble : String)
    end

    def mutations_for(sources : Array(String), specs : Array(String))
      sources.map do |src|
        mutations_for(source: src, specs: specs)
      end.flatten
    end

    private def mutations_for(source : String, specs : Array(String))
      ast = Crystal::Parser.parse(File.read(source))

      @possibilities
        .map(&.reset)
        .map do |inspector|
          ast.accept(inspector)
          inspector
        end
        .select(&.any?)
        .map do |inspector|
          inspector.locations.map do |location|
            Mutation::Mutation.with(
              mutant: inspector.mutant_class.at(location),
              original: source,
              specs: specs,
              preamble: DEFAULT_PREAMBLE)
          end
        end
        .flatten
    end
  end
end
