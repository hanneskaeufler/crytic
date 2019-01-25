require "./possibilities"

module Crytic::Mutant
  class NoopPossibilities < Possibilities
    private getter dummy_location : Crystal::Location? = nil

    def visit(node : Crystal::ASTNode)
      @dummy_location = node.location
      false
    end

    def locations
      [FullLocation.new(dummy_location.not_nil!)]
    end

    def any?
      true
    end
  end
end
