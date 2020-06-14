require "./possibilities.cr"

module Crytic::Mutant
  class SymbolLiteralChangePossibilities < Possibilities
    def visit(node : Crystal::SymbolLiteral)
      location = node.location
      if location
        @locations << FullLocation.new(location)
      end
      true
    end
  end
end
