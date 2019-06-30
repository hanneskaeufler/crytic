require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class SelectRejectSwap < TransformerMutant
    def transform(node : Crystal::Call)
      super
      return node unless SelectRejectSwapPossibilities::SELECT_REJECT.includes?(node.name) &&
                         @location.matches?(node)
      new_node = node.clone
      new_node.name = node.name == "reject" ? "select" : "reject"
      new_node
    end
  end
end
