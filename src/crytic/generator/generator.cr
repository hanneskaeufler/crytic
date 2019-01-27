require "../mutation/mutation"

module Crytic
  record MutationSet, neutral : Mutation::MutationInterface, mutated : Array(Mutation::MutationInterface)

  abstract class Generator
    abstract def mutations_for(source : Array(String), specs : Array(String)) : Array(MutationSet)
  end
end
