require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class AndOrSwap < TransformerMutant
    def transform(node : Crystal::And)
      super
      if @location.matches?(node)
        return Crystal::Or.new(node.left, node.right)
      end
      node
    end
  end
end
