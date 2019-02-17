require "../mutation/config"
require "./generator"
require "compiler/crystal/syntax/*"

module Crytic::Generator
  # Determines all possible mutations for the given source files.
  class InMemoryMutationsGenerator < Generator
    alias MutationFactory = Mutation::Config -> Mutation::Mutation

    def initialize(
      @possibilities : Array(Mutant::Possibilities),
      @preamble : String,
      @mutation_factory : MutationFactory
    )
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

    private def noop_mutation_for(src, specs) : Mutation::Mutation
      @mutation_factory.call(Mutation::Config.new(noop_mutant_for(src), src, specs, @preamble))
    end

    private def noop_mutant_for(src)
      Mutant::Noop.at(Mutant::FullLocation.at(src, 0, 0))
    end

    private def mutations_for(source : String, specs : Array(String)) : Array(Mutation::Mutation)
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
            @mutation_factory.call(Mutation::Config.new(
              inspector.mutant_class.at(location), source, specs, @preamble))
          end
        end
        .flatten
    end

    private def ast_for(source)
      Crystal::Parser
        .new(File.read(source))
        .tap(&.filename = source)
        .parse
    end
  end
end
