require "compiler/crystal/syntax/*"

module Crytic::Mutant
  record FullLocation,
    location : Crystal::Location,
    name_location : Crystal::Location? = nil do
    delegate line_number, column_number, to: location

    def self.at(filename, line_number, column_number, name_location = nil)
      new(Crystal::Location.new(filename, line_number, column_number), name_location)
    end

    def matches?(node : Crystal::And | Crystal::Or)
      node_location = node.location
      return false if node_location.nil?
      return same?(node_location, location) if name_location.nil?

      same?(node_location, location) && same?(node.end_location, name_location)
    end

    def matches?(node : Crystal::ASTNode)
      node_location = node.location
      return false if node_location.nil?
      return same?(node_location, location) if name_location.nil?

      same?(node_location, location) && same?(node.name_location, name_location)
    end

    private def same?(location : Crystal::Location, other : Crystal::Location) : Bool
      location.line_number == other.line_number && location.column_number == other.column_number
    end

    private def same?(location : Nil, other : Nil) : Bool
      false
    end

    private def same?(location : Crystal::Location, other : Nil) : Bool
      false
    end

    private def same?(location : Nil, other : Crystal::Location) : Bool
      false
    end
  end
end
