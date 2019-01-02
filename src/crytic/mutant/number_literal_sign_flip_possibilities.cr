require "./possibilities"

module Crytic::Mutant
  class NumberLiteralSignFlipPossibilities < Possibilities
    def visit(node : Crystal::NumberLiteral)
      return true if node.value == "0"
      location = node.location
      unless location.nil?
        @locations << FullLocation.new(location)
      end
      true
    end
  end
end
