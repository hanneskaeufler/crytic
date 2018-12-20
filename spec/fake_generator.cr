require "../src/crytic/generator/generator"
require "../src/crytic/mutation/mutation"
require "./fake_mutation"

class FakeGenerator < Crytic::Generator
  def initialize(@mutations = [] of Crytic::Mutation::Mutation | FakeMutation)
  end

  def mutations_for(source : Array(String), specs : Array(String))
    @mutations
  end
end
