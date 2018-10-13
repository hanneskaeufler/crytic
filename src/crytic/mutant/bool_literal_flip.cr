require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class BoolLiteralFlip < Mutant
    def visit(node : Crystal::BoolLiteral)
      return false if @did_apply
      node.value = !node.value
      @did_apply = true
      true
    end

    # Ignore other nodes for now
    def visit(node : Crystal::ASTNode)
      true
    end
  end
end
