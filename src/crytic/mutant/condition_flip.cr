require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic
  module Mutant
    class ConditionFlip < Mutant
      def visit(node : Crystal::If)
        return false if @did_apply
        tmp = node.else
        node.else = node.then
        node.then = tmp

        @did_apply = true

        true
      end

       # Ignore other nodes for now
      def visit(node : Crystal::ASTNode)
        true
      end
    end
  end
end
