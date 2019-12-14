require "../mutation/isolated_mutation"

module Crytic::Generator
  extend self

  def isolated_mutation_factory(environment : Crytic::Mutation::Environment)
    Mutation::IsolatedMutation.with(environment).as(Mutation::Mutation)
  end
end
