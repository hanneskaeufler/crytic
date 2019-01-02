require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class BoolLiteralFlip < VisitorMutant
    def visit(node : Crystal::BoolLiteral)
      if @location.matches?(node)
        node.value = !node.value
      end
      true
    end
  end
end
