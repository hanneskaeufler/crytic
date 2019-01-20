require "../../src/crytic/mutant/number_literal_change"
require "../src/crytic/mutant/full_location"
require "compiler/crystal/syntax/*"
require "spec"

def location_at(line_number, column_number, name_column_number : Int32? = nil, filename = "some_filename.cr")
  Crytic::Mutant::FullLocation.new(Crystal::Location.new(
    filename: filename,
    line_number: line_number,
    column_number: column_number), name_column_number)
end

def fake_mutant(mutated_file : String = "some_filename.cr")
  Crytic::Mutant::NumberLiteralChange.at(location_at(0, 0, filename: mutated_file))
end

def ast_from(code)
  Crystal::Parser.parse(code)
end

def result(status = Crytic::Mutation::Status::Covered, filename = "some_filename.cr")
  Crytic::Mutation::Result.new(
    status: status,
    mutant: fake_mutant(filename),
    diff: "diff")
end
