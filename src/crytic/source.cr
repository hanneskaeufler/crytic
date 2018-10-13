require "./mutant/mutant"

module Crytic
  class Source
    private getter source

    def initialize(@source : String, @mutant : Mutant::Mutant)
    end

    def original_source
      source
    end

    def mutated_source
      abstract_syntax_tree = Crystal::Parser.parse(source)
      abstract_syntax_tree.accept(@mutant)
      abstract_syntax_tree.to_s
    end
  end
end
