require "../mutant/mutant"
require "../process_process_runner"
require "../process_runner"
require "../subject"
require "./config"
require "./inject_mutated_subject_into_specs"
require "./mutation"
require "./result"

module Crytic::Mutation
  # Represents a single mutation to a single source file
  class IsolatedMutation < Mutation
    alias Preamble = String

    private getter process_runner : Crytic::ProcessRunner
    private getter file_remover : (String -> Void)
    private getter tempfile_writer : (String, String, String) -> String

    # Compiles the mutated source code into a binary and runs this binary,
    # recording exit code, stderr and stdout output.
    def run
      subject = Subject.from_filepath(@config.original)
      process_result = run(subject.mutate_source!(@config.mutant))
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

      Result.new(status, @config.mutant, subject.diff)
    end

    def self.with(config, process_runner, file_remover, tempfile_writer)
      new(config, process_runner, file_remover, tempfile_writer)
    end

    private def initialize(
      @config : Config,
      @process_runner,
      @file_remover,
      @tempfile_writer
    )
    end

    private def run(mutated_source : SourceCode)
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
      full_source = @config.preamble + mutated_specs_source(mutated_source)
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
      @config.specs.map do |spec_file|
        InjectMutatedSubjectIntoSpecs
          .new(
          subject_path: @config.original,
          mutated_subject_source: mutated_source,
          path: spec_file,
          source: File.read(spec_file))
          .to_mutated_source
      end.join("\n")
    end
  end
end
