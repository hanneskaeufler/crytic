require "../mutant/mutant"
require "../process_runner"
require "../source"
require "./adapt_local_require_paths_to_current_working_dir"
require "./diff"
require "./inject_mutated_subject_into_specs"
require "./result"
require "compiler/crystal/syntax/*"

module Crytic::Mutation
  # Represents a single mutation to a single source file
  class Mutation
    property process_runner
    @process_runner : ProcessRunner

    def run
      subject_source = File.read(@subject_file_path)
      mutated_source = Source.new(subject_source, @mutant).mutated_source
      source_diff = Diff.new(Crystal::Parser.parse(subject_source).to_s, mutated_source).to_s

      Result.new(
        is_covered: run_process(mutated_source) != 0,
        mutant: @mutant,
        diff: source_diff)
    end

    def self.with(mutant : Mutant::Mutant, original : String, specs : Array(String))
      new(mutant, original, specs)
    end

    private def initialize(
      @mutant : Crytic::Mutant::Mutant,
      @subject_file_path : String,
      @specs_file_paths : Array(String)
    )
      @io = IO::Memory.new
      @process_runner = ProcessProcessRunner.new
    end

    private def run_process(mutated_source)
      full = mutated_specs_source(mutated_source)
      process_runner.run(
        "crystal", ["eval", full],
        output: @io,
        error: STDERR)
    end

    private def mutated_specs_source(mutated_source)
      InjectMutatedSubjectIntoSpecs.reset
      @specs_file_paths.map do |spec_file|
        InjectMutatedSubjectIntoSpecs
          .new(
          subject_path: @subject_file_path,
          mutated_subject_source: mutated_source,
          path: spec_file,
          source: File.read(spec_file))
          .to_covered_source
      end.join("\n")
    end
  end
end
