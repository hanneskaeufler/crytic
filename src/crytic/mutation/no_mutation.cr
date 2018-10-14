require "./adapt_local_require_paths_to_current_working_dir"
require "./mutation"

module Crytic::Mutation
  class NoMutation
    property process_runner
    @process_runner : ProcessRunner

    def run
      io = IO::Memory.new
      exit_code = process_runner.run("crystal", ["spec", @specs_file_paths.join(" ")],
        output: io,
        error: io)
      OriginalResult.new(exit_code: exit_code, output: io.to_s)
    end

    def self.with(specs : Array(String))
      new(specs)
    end

    private def initialize(@specs_file_paths : Array(String))
      @process_runner = ProcessProcessRunner.new
    end
  end

  record OriginalResult, exit_code : Int32, output : String
end
