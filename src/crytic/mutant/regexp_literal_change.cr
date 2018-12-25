require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class RegexpLiteralChange < VisitorMutant
    def visit(node : Crystal::RegexLiteral)
      location = node.location
      return if location.nil?
      if location.line_number == @location.line_number &&
         location.column_number == @location.column_number
        node.value = Crystal::StringLiteral.new("a^")
      end
      true
    end
  end
end
