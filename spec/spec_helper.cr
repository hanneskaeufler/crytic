require "../../src/crytic/mutant/number_literal_change"
require "../src/crytic/mutant/full_location"
require "compiler/crystal/syntax/*"
require "spec"

def location_at(line_number, column_number, name_column_number : Int32? = nil, filename : String? = nil)
  Crytic::Mutant::FullLocation.new(Crystal::Location.new(
    filename: filename || "some_filename.cr",
    line_number: line_number,
    column_number: column_number), name_column_number)
end

def fake_mutant(filename : String? = nil)
  Crytic::Mutant::NumberLiteralChange.at(location_at(0, 0, filename: filename))
end

def ast_from(code)
  Crystal::Parser.parse(code)
end
