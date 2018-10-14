require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class NumberLiteralChangePossibilities < Mutant
    getter locations
    @locations = [] of Crystal::Location

    def visit(node : Crystal::NumberLiteral)
      if node.location != nil
        @locations << node.location.not_nil!
      end
      true
    end

    def visit(node : Crystal::ASTNode)
      true
    end

    def any?
      @locations.size > 0
    end
  end
end
