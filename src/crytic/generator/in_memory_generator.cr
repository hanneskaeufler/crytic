require "../mutation/config"
require "../subject"
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
      @mutation_factory.call(Mutation::Config.noop(src, specs, @preamble))
    end

    private def mutations_for(source : String, specs : Array(String))
      subject = Subject.from_filepath(source)

      subject
        .inspect(@possibilities)
        .map do |possibilities|
          possibilities.locations.map do |location|
            @mutation_factory.call(Mutation::Config.new(
              possibilities.mutant_class.at(location), subject, specs, @preamble))
          end
        end
        .flatten
    end
  end
end
