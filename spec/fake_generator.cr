# ameba:disable Lint/SpecFilename
require "../src/crytic/generator/generator"
require "../src/crytic/mutation/mutation"

class FakeGenerator < Crytic::Generator::Generator
  def initialize(@mutations = [] of Crytic::Mutation::Mutation,
                 @neutral = FakeMutation.new.as(Crytic::Mutation::Mutation))
  end

  def mutations_for(subject : Array(Crytic::Subject), specs : Array(String)) : Array(Crytic::Generator::MutationSet)
    [Crytic::Generator::MutationSet.new(
      neutral: @neutral,
      mutated: @mutations)]
  end
end
