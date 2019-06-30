require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class AnyAllSwap < TransformerMutant
    def transform(node : Crystal::Call)
      super
      return node unless @location.matches?(node)
      new_node = node.clone
      new_node.name = node.name == "any?" ? "all?" : "any?"
      new_node
    end
  end
end
