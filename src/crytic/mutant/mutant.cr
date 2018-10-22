require "compiler/crystal/syntax/*"

module Crytic::Mutant
  alias Mutant = VisitorMutant | TransformerMutant

  abstract class TransformerMutant < Crystal::Transformer
    getter location

    def self.at(location : Crystal::Location)
      new(location)
    end

    private def initialize(@location : Crystal::Location)
    end
  end

  abstract class VisitorMutant < Crystal::Visitor
    getter location

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
