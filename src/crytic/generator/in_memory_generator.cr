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

    def mutations_for(sources : Array(Subject), specs : Array(String)) : Array(MutationSet)
      sources
        .map do |src|
          MutationSet.new(
            neutral: noop_mutation_for(src, specs),
            mutated: mutations_for(src, specs)
          )
        end
        .reject(&.mutated.empty?)
    end

    private def noop_mutation_for(subject, specs) : Mutation::Mutation
      @mutation_factory.call(Mutation::Config.noop(subject.path, specs, @preamble))
    end

    private def mutations_for(subject : Subject, specs : Array(String))
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
