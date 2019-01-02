require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class NumberLiteralChange < VisitorMutant
    def visit(node : Crystal::NumberLiteral)
      if @location.matches?(node)
        node.value = if node.value == "0"
                       "1"
                     else
                       "0"
                     end
      end
      true
    end
  end
end
