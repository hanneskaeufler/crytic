require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic
  module Mutant
    class NumberLiteralChange < Mutant
      def visit(node : Crystal::NumberLiteral)
        return false if @did_apply
        node.value = "#{node.value}1"
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
