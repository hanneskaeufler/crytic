require "../src/crytic/mutant/full_location"
require "../src/crytic/mutant/number_literal_change"
require "./fake_generator"
require "./fake_mutation"
require "./fake_process_runner"
require "./fake_reporter"
require "compiler/crystal/syntax/*"
require "spec"

def location_at(line_number, column_number,
                name_column_number : Int32? = nil,
                end_location : Crystal::Location? = nil,
                filename = "some_filename.cr")
  Crytic::Mutant::FullLocation.at(
    filename: filename,
    line_number: line_number,
    column_number: column_number,
    name_column_number: name_column_number,
    end_location: end_location)
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

def erroring_mutation
  FakeMutation.new(reported_status: Crytic::Mutation::Status::Errored).as(Crytic::Mutation::Mutation)
end

def fake_mutation
  FakeMutation.new.as(Crytic::Mutation::Mutation)
end
