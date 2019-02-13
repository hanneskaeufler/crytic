require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class StringLiteralChange < VisitorMutant
    def visit(node : Crystal::StringLiteral)
      if @location.matches?(node)
        node.value = if node.value.empty?
                       "__crytic__"
                     else
                       ""
                     end
      end
      true
    end
  end
end
