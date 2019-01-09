require "../diff"
require "../mutant/mutant"
require "../process_process_runner"
require "../process_runner"
require "../source"
require "./inject_mutated_subject_into_specs"
require "./result"

module Crytic::Mutation
  # Represents a single mutation to a single source file
  class Mutation
    alias Preamble = String

    property process_runner : Crytic::ProcessRunner
    property file_remover : (String -> Void)
    property tempfile_writer : (String, String, String) -> String

    # Compiles the mutated source code into a binary and runs this binary,
    # recording exit code, stderr and stdout output.
    def run
      subject_source = File.read(@subject_file_path)
      source = Source.new(subject_source)
      mutated_source = source.mutated_source(@mutant)
      source_diff = Crytic::Diff.unified_diff(source.original_source, mutated_source).to_s

      process_result = run_mutation(mutated_source)
      success_messages_in_output = /Finished/ =~ process_result[:output]
      status = if process_result[:exit_code] == ProcessRunner::SUCCESS
                 Status::Uncovered
               elsif process_result[:exit_code] == ProcessRunner::TIMEOUT
                 Status::Timeout
               elsif success_messages_in_output == nil
                 Status::Errored
               else
                 Status::Covered
               end

      Result.new(status, @mutant, source_diff)
    end

    def self.with(
      mutant : Mutant::Mutant,
      original : String,
      specs : Array(String),
      preamble : Preamble
    )
      new(mutant, original, specs, preamble)
    end

    private def initialize(
      @mutant : Crytic::Mutant::Mutant,
      @subject_file_path : String,
      @specs_file_paths : Array(String),
      @preamble : String
    )
      @process_runner = ProcessProcessRunner.new
      @file_remover = ->File.delete(String)
      @tempfile_writer = ->(name : String, extension : String, content : String) {
        File.tempfile(name, extension) { |file| file.print(content) }.path
      }
    end

    private def run_mutation(mutated_source)
      io = IO::Memory.new
      tempfile_path = write_full_source_into_tempfile(mutated_source)
      res = compile_tempfile_into_binary(tempfile_path)

      if res[:exit_code] != 0
        @file_remover.call(tempfile_path)
        return {exit_code: res[:exit_code], output: res[:output]}
      end

      binary = res[:binary]
      exit_code = execute_binary(binary, io)
      remove_artifacts(tempfile_path, binary)

      {exit_code: exit_code, output: io.to_s}
    end

    private def write_full_source_into_tempfile(mutated_source)
      full_source = @preamble + mutated_specs_source(mutated_source)
      @tempfile_writer.call("crytic", ".cr", full_source)
    end

    private def compile_tempfile_into_binary(tempfile_path)
      io = IO::Memory.new
      binary = "#{File.dirname(tempfile_path)}/#{File.basename(tempfile_path, ".cr")}"
      exit_code = process_runner.run(
        "crystal",
        ["build", "-o", binary, "--no-debug", tempfile_path],
        output: io,
        error: io)
      {exit_code: exit_code, binary: binary, output: io.to_s}
    end

    private def execute_binary(binary, io)
      process_runner
        .run(binary, [] of String, output: io, error: STDERR, timeout: 10.seconds)
    end

    private def remove_artifacts(tempfile_path, binary)
      @file_remover.call(tempfile_path)
      @file_remover.call(binary)
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
