require "../src/crytic/generator/generator"

class FakeGenerator < Crytic::Generator
  def mutations_for(source : Array(String), specs : Array(String))
    [] of Crytic::MutationSet
  end
end
