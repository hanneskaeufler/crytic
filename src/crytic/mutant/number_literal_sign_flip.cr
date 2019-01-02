require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class NumberLiteralSignFlip < VisitorMutant
    def visit(node : Crystal::NumberLiteral)
      if @location.matches?(node)
        node.value = "(-1*#{node.value})"
      end
      true
    end
  end
end
