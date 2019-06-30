require "compiler/crystal/syntax/*"

module Crytic::Mutant
  record FullLocation,
    location : Crystal::Location,
    name_location : Crystal::Location? = nil do
    delegate line_number, column_number, to: location

    def self.at(filename, line_number, column_number, name_location = nil)
      new(Crystal::Location.new(filename, line_number, column_number), name_location)
    end

    def matches?(node)
      node_location = node.location
      return false if node_location.nil?
      return is_same(node_location, location) if name_location.nil?

      case node
      when Crystal::And | Crystal::Or
        is_same(node_location, location) && is_same(node.end_location, name_location)
      else
        is_same(node_location, location) && is_same(node.name_location, name_location)
      end
    end

    private def is_same(location : Crystal::Location, other : Crystal::Location) : Bool
      location.line_number == other.line_number && location.column_number == other.column_number
    end

    private def is_same(location : Nil, other : Nil) : Bool
      false
    end

    private def is_same(location : Crystal::Location, other : Nil) : Bool
      false
    end

    private def is_same(location : Nil, other : Crystal::Location) : Bool
      false
    end
  end
end
