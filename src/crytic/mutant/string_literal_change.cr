require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class StringLiteralChange < VisitorMutant
    def visit(node : Crystal::StringLiteral)
      location = node.location
      return if location.nil?
      if location.line_number == @location.line_number &&
         location.column_number == @location.column_number
        node.value = "#{node.value}__crytic__"
      end
      true
    end
  end
end
