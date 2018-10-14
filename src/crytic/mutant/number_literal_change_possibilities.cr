require "compiler/crystal/syntax/*"
require "./possibilities"

module Crytic::Mutant
  class NumberLiteralChangePossibilities < Possibilities
    def visit(node : Crystal::NumberLiteral)
      location = node.location
      unless location.nil?
        @locations << location
      end
      true
    end
  end
end
