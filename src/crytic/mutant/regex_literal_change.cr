require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class RegexLiteralChange < VisitorMutant
    def visit(node : Crystal::RegexLiteral)
      if @location.matches?(node)
        node.value = Crystal::StringLiteral.new("a^")
      end
      true
    end
  end
end
