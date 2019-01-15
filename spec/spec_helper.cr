require "../src/crytic/mutant/full_location"
require "compiler/crystal/syntax/*"
require "spec"

def location_at(line_number, column_number, name_column_number : Int32? = nil)
  Crytic::Mutant::FullLocation.new(Crystal::Location.new(
    filename: "some_filename.cr",
    line_number: line_number,
    column_number: column_number), name_column_number)
end

def fake_mutant
  Crytic::Mutant::NumberLiteralChange.at(location_at(0, 0))
end
