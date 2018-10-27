require "./process_runner"
require "timeout"

module Crytic
  class ProcessProcessRunner < ProcessRunner
    def run(cmd, args, output, error) : Int32
      Process.run(cmd, args, output: output, error: error).exit_code
    end

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
