require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic
  module Mutant
    class NumberLiteralSignFlip < Mutant
      def visit(node : Crystal::NumberLiteral)
        node.value = "-#{node.value}"
        true
      end

       # Ignore other nodes for now
      def visit(node : Crystal::ASTNode)
        true
      end
    end

    class NumberLiteralChange < Mutant
      def visit(node : Crystal::NumberLiteral)
        node.value = "#{node.value}1"
        true
      end

       # Ignore other nodes for now
      def visit(node : Crystal::ASTNode)
        true
      end
    end

    class ConditionFlip < Mutant
      def visit(node : Crystal::If)
        tmp = node.else
        node.else = node.then
        node.then = tmp
        node

        true
      end

       # Ignore other nodes for now
      def visit(node : Crystal::ASTNode)
        true
      end
    end
  end
end
