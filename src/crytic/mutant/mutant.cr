require "compiler/crystal/syntax/*"

module Crytic::Mutant
  abstract class Mutant < Crystal::Visitor
    def self.at(location : Crystal::Location)
      new(location)
    end

    def visit(node : Crystal::ASTNode)
      true
    end

    private def initialize(@location : Crystal::Location)
    end
  end
end
