require "./process_runner"
require "timeout"

module Crytic
  # Runs processes using crystals `Process` class
  class ProcessProcessRunner < ProcessRunner
    # Run the given command with args and save output to given io
    def run(cmd, args, output, error) : Int32
      Process.run(cmd, args, output: output, error: error).exit_code
    end

    # Run the given command with args and save output to given io
    # Times out and kills the provess after given period.
    def run(cmd, args, output, error, timeout) : Int32
      channel = Channel(Int32).new
      process = Process.new(cmd, args, output: output, error: error)
      spawn do
        channel.send process.wait.exit_code
      end
      select
      when value = channel.receive
        value
      when Timeout.after(timeout)
        process.kill(Signal::KILL)
        28
      end
    end
  end
end
