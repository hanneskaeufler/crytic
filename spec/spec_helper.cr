require "../src/crytic/mutant/full_location"
require "../src/crytic/mutant/number_literal_change"
require "../src/crytic/subject"
require "./fake_file"
require "./fake_generator"
require "./fake_http_client"
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

def result(status = Crytic::Mutation::Status::Covered, filename = "some_filename.cr", output = "")
  Crytic::Mutation::Result.new(
    status: status,
    mutant: fake_mutant(filename),
    diff: "diff",
    output: output)
end

def erroring_mutation
  FakeMutation.new(reported_status: Crytic::Mutation::Status::Errored).as(Crytic::Mutation::Mutation)
end

def fake_mutation
  FakeMutation.new.as(Crytic::Mutation::Mutation)
end

def config(mutant, original, specs, preamble = "")
  Crytic::Mutation::Config.new(
    mutant, Crytic::Subject.from_filepath(original), specs, preamble)
end

def environment(
  config,
  process_runner = Crytic::FakeProcessRunner.new,
  file_remover = ->FakeFile.delete(String),
  tempfile_writer = ->FakeFile.tempfile(String, String, String)
)
  Crytic::Mutation::Environment.new(config, process_runner, file_remover, tempfile_writer)
end

def mutated_subject(path = "", original_source_code = "", source_code = "")
  Crytic::MutatedSubject.new(path, original_source_code, source_code)
end

def fake_mutation_factory
  ->(_config : Crytic::Mutation::Config) { fake_mutation }
end

def fake_env
  {
    "CIRCLE_BRANCH"             => "master",
    "CIRCLE_PROJECT_REPONAME"   => "crytic",
    "CIRCLE_PROJECT_USERNAME"   => "hanneskaeufler",
    "STRYKER_DASHBOARD_API_KEY" => "apikey",
  }
end
