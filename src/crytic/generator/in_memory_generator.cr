require "../mutant/**"
require "../mutation/mutation"
require "./generator"
require "compiler/crystal/syntax/*"

module Crytic
  class InMemoryMutationsGenerator < Generator
    def initialize(@possibilities = [
                     Mutant::AndOrSwapPossibilities.new,
                     Mutant::AnyAllSwapPossibilities.new,
                     Mutant::BoolLiteralFlipPossibilities.new,
                     Mutant::ConditionFlipPossibilities.new,
                     Mutant::NumberLiteralChangePossibilities.new,
                     Mutant::NumberLiteralSignFlipPossibilities.new,
                     Mutant::StringLiteralChangePossibilities.new,
                   ] of Mutant::Possibilities)
    end

    def mutations_for(sources : Array(String), specs : Array(String))
      sources.map do |src|
        mutations_for(source: src, specs: specs)
      end.flatten
    end

    private def mutations_for(source : String, specs : Array(String))
      ast = Crystal::Parser.parse(File.read(source))

      @possibilities.each(&.reset)
      @possibilities
        .map do |inspector|
          ast.accept(inspector)
          inspector
        end
        .select(&.any?)
        .map do |inspector|
          inspector.locations.map do |location|
            Mutation::Mutation
              .with(inspector.mutant_class.at(location), source, specs)
          end
        end
        .flatten
    end
  end
end
