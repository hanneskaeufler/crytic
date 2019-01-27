require "../src/crytic/mutation/mutation"
require "../src/crytic/generator/generator"

class FakeGenerator < Crytic::Generator
  def initialize(@mutations = [] of Crytic::Mutation::MutationInterface,
                 @neutral = FakeMutation.new.as(Crytic::Mutation::MutationInterface))
  end

  def mutations_for(source : Array(String), specs : Array(String))
    [Crytic::MutationSet.new(
      neutral: @neutral,
      mutated: @mutations)]
  end
end
