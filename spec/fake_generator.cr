require "../src/crytic/generator/generator"
require "../src/crytic/mutation/mutation"

class FakeGenerator < Crytic::Generator
  def mutations_for(source : Array(String), specs : Array(String))
    [] of Crytic::Mutation::Mutation
  end
end
