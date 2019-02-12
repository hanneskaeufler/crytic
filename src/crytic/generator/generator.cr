require "../mutation/mutation"

module Crytic::Generator
  record MutationSet, neutral : Mutation::Mutation, mutated : Array(Mutation::Mutation)

  abstract class Generator
    DEFAULT_PREAMBLE = <<-CODE
    require "spec"
    Spec.fail_fast = true

    CODE

    abstract def mutations_for(source : Array(String), specs : Array(String)) : Array(MutationSet)
  end
end
