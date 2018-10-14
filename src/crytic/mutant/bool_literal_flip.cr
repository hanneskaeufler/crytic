require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class BoolLiteralFlip < Mutant
    def visit(node : Crystal::BoolLiteral)
      location = node.location
      return if location.nil?
      if location.line_number == @location.line_number &&
         location.column_number == @location.column_number
        node.value = !node.value
      end
      true
    end
  end
end
