require "./process_runner"

module Crytic
  class ProcessProcessRunner < ProcessRunner
    def run(cmd, args, output, error)
      Process.run(cmd, args, output: output, error: error).exit_code
    end
  end
end
