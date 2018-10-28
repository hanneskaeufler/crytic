require "../diff"
require "../mutant/mutant"
require "../process_process_runner"
require "../process_runner"
require "../source"
require "./inject_mutated_subject_into_specs"
require "./result"
require "compiler/crystal/syntax/*"

module Crytic::Mutation
  # Represents a single mutation to a single source file
  class Mutation
    property process_runner
    @process_runner : Crytic::ProcessRunner

    def run
      subject_source = File.read(@subject_file_path)
      source = Source.new(subject_source)
      mutated_source = source.mutated_source(@mutant)
      source_diff = Crytic::Diff.unified_diff(source.original_source, mutated_source).to_s
      process_result = run_process(mutated_source)
      success_messages_in_output = /Finished/ =~ process_result[:output]
      status = if process_result[:exit_code] == 0
                 Status::Uncovered
               elsif process_result[:exit_code] == 28
                 Status::Timeout
               elsif success_messages_in_output == nil
                 Status::Error
               else
                 Status::Covered
               end

      Result.new(status, @mutant, source_diff)
    end

    def self.with(mutant : Mutant::Mutant, original : String, specs : Array(String))
      new(mutant, original, specs)
    end

    private def initialize(
      @mutant : Crytic::Mutant::Mutant,
      @subject_file_path : String,
      @specs_file_paths : Array(String)
    )
      @process_runner = ProcessProcessRunner.new
    end

    private def run_process(mutated_source)
      full = mutated_specs_source(mutated_source)
      io = IO::Memory.new
      exit_code = process_runner.run(
        "crystal", ["eval", full],
        output: io,
        error: STDERR,
        timeout: 10.seconds)
      {exit_code: exit_code, output: io.to_s}
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
