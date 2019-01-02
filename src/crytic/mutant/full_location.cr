require "compiler/crystal/syntax/*"

module Crytic::Mutant
  record FullLocation, location : Crystal::Location, name_column_number : Int32? = nil do
    delegate line_number, column_number, to: location

    def matches?(node)
      node_location = node.location
      return false if node_location.nil?

      location_is_same = node_location.column_number == location.column_number &&
                         node_location.line_number == location.line_number

      return location_is_same if name_column_number.nil?
      return location_is_same && node.name_column_number == name_column_number
    end
  end
end
