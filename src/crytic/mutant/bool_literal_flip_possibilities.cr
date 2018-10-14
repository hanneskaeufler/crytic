require "compiler/crystal/syntax/*"
require "./possibilities"

module Crytic::Mutant
  class BoolLiteralFlipPossibilities < Possibilities
    def visit(node : Crystal::BoolLiteral)
      location = node.location
      unless location.nil?
        @locations << location
      end
      true
    end
  end
end
