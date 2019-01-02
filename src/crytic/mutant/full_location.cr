require "compiler/crystal/syntax/*"

module Crytic::Mutant
  record FullLocation, location : Crystal::Location, name_column_number : Int32? = nil do
    delegate line_number, column_number, to: location

    #     def ==(other : Crystal::Location)
    #       location.line_number == other.line_number &&
    #         location.column_number == other.column_number
    #     end

    #     def ==(other : FullLocation)
    #       location == other.location &&
    #         name_column_number == other.name_column_number
    #     end
  end
end
