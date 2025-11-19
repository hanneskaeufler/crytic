require "../src/crytic/mutant/full_location"
require "../src/crytic/mutant/number_literal_change"
require "../src/crytic/subject"
require "./fake_file"
require "./fake_generator"
require "./fake_http_client"
require "./fake_mutation"
require "./fake_process_runner"
require "compiler/crystal/syntax/*"
require "spec"

def location_at(line_number, column_number,
                name_location : Crystal::Location? = nil,
                filename = "some_filename.cr")
  Crytic::Mutant::FullLocation.at(
    filename: filename,
    line_number: line_number,
    column_number: column_number,
    name_location: name_location)
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

def side_effects(
  stdout = IO::Memory.new,
  stderr = IO::Memory.new,
  exit_fun = noop_exit_fun,
  process_runner = Crytic::FakeProcessRunner.new,
  file_remover = ->FakeFile.delete(String),
  tempfile_writer = ->FakeFile.tempfile(String, String, String),
)
  Crytic::SideEffects.new(
    stdout,
    stderr,
    exit_fun,
    empty_env,
    process_runner,
    file_remover,
    tempfile_writer)
end

def environment(
  config,
  process_runner = Crytic::FakeProcessRunner.new,
  file_remover = ->FakeFile.delete(String),
  tempfile_writer = ->FakeFile.tempfile(String, String, String),
)
  Crytic::Mutation::Environment.new(config, side_effects(process_runner: process_runner, file_remover: file_remover, tempfile_writer: tempfile_writer))
end

def mutated_subject(path = "", original_source_code = "", source_code = "")
  Crytic::MutatedSubject.new(path, original_source_code, source_code)
end

def fake_mutation_factory
  ->(_env : Crytic::Mutation::Environment) { fake_mutation }
end

def empty_env
  {} of String => String
end

def fake_env
  {
    "CIRCLE_BRANCH"             => "master",
    "CIRCLE_PROJECT_REPONAME"   => "crytic",
    "CIRCLE_PROJECT_USERNAME"   => "hanneskaeufler",
    "STRYKER_DASHBOARD_API_KEY" => "apikey",
  }
end

def fake_no_mutation_factory
  ->(specs : Array(String)) {
    Crytic::Mutation::NoMutation.with(specs)
  }
end

def noop_exit_fun
  ->(_code : Int32) { }
end

def cli_options_parser(
  std_out = IO::Memory.new,
  std_err = IO::Memory.new,
  exit_fun = noop_exit_fun,
  env = fake_env,
  spec_files_glob = Crytic::CliOptions::DEFAULT_SPEC_FILES_GLOB,
)
  Crytic::CliOptions.new(Crytic::SideEffects.new(
    std_out, std_err, exit_fun, env,
    Crytic::FakeProcessRunner.new,
    ->FakeFile.delete(String),
    ->FakeFile.tempfile(String, String, String)
  ), spec_files_glob)
end
