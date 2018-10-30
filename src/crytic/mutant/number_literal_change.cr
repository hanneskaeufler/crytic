require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class NumberLiteralChange < VisitorMutant
    def visit(node : Crystal::NumberLiteral)
      location = node.location
      return if location.nil?
      if location.line_number == @location.line_number &&
         location.column_number == @location.column_number
        node.value = if node.value == "0"
                       "1"
                     else
                       "0"
                     end
      end
      true
    end
  end
end
