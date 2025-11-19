require "../mutation/environment"
require "../side_effects"
require "../subject"
require "./generator"
require "compiler/crystal/syntax/*"

module Crytic::Generator
  # Determines all possible mutations for the given source files.
  class InMemoryMutationsGenerator < Generator
    alias MutationFactory = Mutation::Environment -> Mutation::Mutation

    def initialize(
      @possibilities : Array(Mutant::Possibilities),
      @preamble : String,
      @mutation_factory : MutationFactory,
      @side_effects : SideEffects,
    )
    end

    def mutations_for(subject : Array(Subject), specs : Array(String)) : Array(MutationSet)
      subject
        .map do |src|
          MutationSet.new(
            neutral: noop_mutation_for(src, specs),
            mutated: mutations_for(src, specs)
          )
        end
        .reject(&.mutated.empty?)
    end

    private def noop_mutation_for(subject, specs) : Mutation::Mutation
      @mutation_factory.call(env(Mutation::Config.noop(subject.path, specs, @preamble)))
    end

    private def mutations_for(subject : Subject, specs : Array(String))
      subject
        .inspect(@possibilities)
        .flat_map do |possibilities|
          possibilities.locations.map do |location|
            @mutation_factory.call(env(Mutation::Config.new(
              possibilities.mutant_class.at(location), subject, specs, @preamble)))
          end
        end
    end

    private def env(config)
      Mutation::Environment.new(config, @side_effects)
    end
  end
end
