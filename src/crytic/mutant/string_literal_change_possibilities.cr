require "./possibilities"

module Crytic::Mutant
  class StringLiteralChangePossibilities < Possibilities
    def visit(node : Crystal::StringLiteral)
      location = node.location
      unless location.nil?
        @locations << location
      end
      true
    end
  end
end
