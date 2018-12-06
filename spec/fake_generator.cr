require "../src/crytic/generator/generator"

class FakeGenerator < Crytic::Generator
  def mutations_for(source : String, specs : Array(String))
    [] of Crytic::Mutation::Mutation
  end
end
