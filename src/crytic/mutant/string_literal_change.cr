require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class StringLiteralChange < VisitorMutant
    def visit(node : Crystal::StringLiteral)
      if @location.matches?(node)
        node.value = "#{node.value}__crytic__"
      end
      true
    end
  end
end
