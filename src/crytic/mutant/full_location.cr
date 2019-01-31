require "compiler/crystal/syntax/*"

module Crytic::Mutant
  # The name_column_number is relevant for Crystal::Call occurrences, while the
  # end_location is used for Crystal::And.
  record FullLocation,
    location : Crystal::Location,
    name_column_number : Int32? = nil,
    end_location : Crystal::Location? = nil do
    delegate line_number, column_number, to: location

    def self.at(filename, line_number, column_number, name_column_number = nil, end_location = nil)
      new(Crystal::Location.new(filename, line_number, column_number), name_column_number, end_location)
    end

    def matches?(node)
      node_location = node.location
      return false if node_location.nil?

      location_is_same = node_location.column_number == location.column_number &&
                         node_location.line_number == location.line_number

      return location_is_same if name_column_number.nil? && end_location.nil?
      return location_is_same && node.name_column_number == name_column_number unless name_column_number.nil?

      location_is_same &&
        node.end_location.try &.line_number == end_location.try &.line_number &&
        node.end_location.try &.column_number == end_location.try &.column_number
    end
  end
end
