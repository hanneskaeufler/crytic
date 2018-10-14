require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class ConditionFlip < Mutant
    def visit(node : Crystal::If)
      location = node.location
      return if location.nil?
      if location.line_number == @location.line_number &&
          location.column_number == @location.column_number
        tmp = node.else
        node.else = node.then
        node.then = tmp
      end
      true
      end
  end
end
