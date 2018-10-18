require "./number_literal_change_possibilities"

module Crytic::Mutant
  class NumberLiteralSignFlipPossibilities < Possibilities
    def visit(node : Crystal::NumberLiteral)
      return true if node.value == "0"
      location = node.location
      unless location.nil?
        @locations << location
      end
      true
    end
  end
end
