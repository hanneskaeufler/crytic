require "./process_runner"
require "./timeout"

module Crytic
  # Runs processes using crystals `Process` class
  class ProcessProcessRunner < ProcessRunner
    # Run the given command with args and save output to given io
    def run(cmd, args, output, error)
      Process.run(cmd, args, output: output, error: error).exit_code
    end

    # Run the given command with args and save output to given io
    # Times out and kills the provess after given period.
    def run(cmd, args, output, error, timeout)
      channel = Channel(Int32).new
      process = Process.new(cmd, args, output: output, error: error)
      spawn { channel.send process.wait.exit_code }
      select
      when value = channel.receive
        value
      when Timeout.after(timeout)
        process.signal(Signal::KILL)
        ProcessRunner::TIMEOUT
      end
    end
  end
end
