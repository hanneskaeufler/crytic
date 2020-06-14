require "./mutant"

module Crytic::Mutant
  class SymbolLiteralChange < VisitorMutant
    def visit(node : Crystal::SymbolLiteral)
      if @location.matches?(node)
        node.value = "__crytic__#{node.value}"
      end
      true
    end
  end
end
