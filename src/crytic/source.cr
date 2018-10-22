require "compiler/crystal/syntax/*"
require "./mutant/mutant"

module Crytic
  class Source
    getter original_source : String

    def initialize(@source : String)
      @ast = Crystal::Parser.parse(@source)
      @original_source = @ast.to_s
    end

    def mutated_source(mutant : Crystal::Transformer)
      @ast.transform(mutant).to_s
    end

    def mutated_source(mutant : Crystal::Visitor)
      @ast.accept(mutant)
      @ast.to_s
    end
  end
end
