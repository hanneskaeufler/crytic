require "./possibilities"

module Crytic::Mutant
  class NoopPossibilities < Possibilities
    def visit(node : Crystal::ASTNode)
      false
    end

    def locations
      [FullLocation.new(Crystal::Location.new(nil, 0, 0))]
    end

    def any?
      true
    end
  end
end
