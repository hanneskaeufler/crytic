require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class AndOrSwap < TransformerMutant
    def transform(node : Crystal::And)
      location = node.location
      return node if location.nil?
      if location.line_number == @location.line_number &&
         location.column_number == @location.column_number
        return Crystal::Or.new(node.left, node.right)
      end
      node
    end
  end
end
