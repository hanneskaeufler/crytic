require "../mutant/mutant"
require "../process_runner"
require "../subject"
require "./environment"
require "./inject_mutated_subject_into_specs"
require "./mutation"
require "./result"

module Crytic::Mutation
  # Represents a single mutation to a single source file
  class IsolatedMutation < Mutation
    alias Preamble = String

    # Compiles the mutated source code into a binary and runs this binary,
    # recording exit code, stderr and stdout output.
    def run : Result
      mutated = @environment.perform_mutation
      process_result = run(mutated)
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

      Result.new(status, @environment.mutant, mutated.diff, process_result[:output])
    end

    def self.with(environment : Environment)
      new(environment)
    end

    private def initialize(@environment : Environment)
    end

    private def run(mutated : MutatedSubject)
      tempfile_path = write_full_source_into_tempfile(mutated)
      res = compile_tempfile_into_binary(tempfile_path)

      if res[:exit_code] != 0
        @environment.remove_file(tempfile_path)
        return {exit_code: res[:exit_code], output: res[:output]}
      end

      binary = res[:binary]
      io = IO::Memory.new
      exit_code = execute_binary(binary, io)
      remove_artifacts(tempfile_path, binary)

      {exit_code: exit_code, output: io.to_s}
    end

    private def write_full_source_into_tempfile(mutated)
      full_source = @environment.preamble + mutated_specs_source(mutated)
      @environment.write_tempfile("crytic", ".cr", full_source)
    end

    private def compile_tempfile_into_binary(tempfile_path)
      io = IO::Memory.new
      binary = "#{File.dirname(tempfile_path)}/#{File.basename(tempfile_path, ".cr")}"
      exit_code = @environment.execute(
        "crystal",
        ["build", "-o", binary, "--no-debug", tempfile_path],
        output: io,
        error: io)
      {exit_code: exit_code, binary: binary, output: io.to_s}
    end

    private def execute_binary(binary, io)
      @environment
        .execute(binary, [] of String, output: io, error: io, timeout: 10.seconds)
    end

    private def remove_artifacts(tempfile_path, binary)
      @environment.remove_file(tempfile_path)
      @environment.remove_file(binary)
    end

    private def mutated_specs_source(mutated)
      tracker = Tracker.new
      @environment.spec_file_paths.map do |spec_file|
        InjectMutatedSubjectIntoSpecs
          .new(
            tracker: tracker,
            mutated_subject: mutated,
            path: spec_file,
            source: File.read(spec_file))
          .to_mutated_source
      end.join("\n")
    end
  end
end
