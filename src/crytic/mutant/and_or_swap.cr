require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class AndOrSwap < TransformerMutant
    def transform(node : Crystal::And | Crystal::Or)
      super
      if @location.matches?(node)
        return case node
        when Crystal::And
          Crystal::Or.new(node.left, node.right)
        else
          Crystal::And.new(node.left, node.right)
        end
      end
      node
    end
  end
end
