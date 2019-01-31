require "../mutation/mutation"

module Crytic
  record MutationSet, neutral : Mutation::Mutation, mutated : Array(Mutation::Mutation)

  abstract class Generator
    abstract def mutations_for(source : Array(String), specs : Array(String)) : Array(MutationSet)
  end
end
