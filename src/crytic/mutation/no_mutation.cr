require "../process_process_runner"
require "../process_runner"
require "./original_result"

module Crytic::Mutation
  class NoMutation
    def run
      io = IO::Memory.new
      args = ["spec"] + @specs_file_paths
      exit_code = @process_runner.run("crystal", args, output: io, error: io)
      OriginalResult.new(exit_code: exit_code, output: io.to_s)
    end

    def self.with(specs : Array(String), process_runner)
      new(specs, process_runner)
    end

    private def initialize(@specs_file_paths : Array(String),
                           @process_runner : ProcessRunner)
    end
  end
end
