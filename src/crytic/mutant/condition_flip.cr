require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class ConditionFlip < VisitorMutant
    def visit(node : Crystal::If)
      if @location.matches?(node)
        tmp = node.else
        node.else = node.then
        node.then = tmp
      end
      true
    end
  end
end
