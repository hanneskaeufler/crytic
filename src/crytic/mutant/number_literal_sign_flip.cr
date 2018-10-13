require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class NumberLiteralSignFlip < Mutant
    def visit(node : Crystal::NumberLiteral)
      return false if @did_apply
      node.value = "-#{node.value}"
      @did_apply = true
      true
    end

    # Ignore other nodes for now
    def visit(node : Crystal::ASTNode)
      true
    end
  end
end
