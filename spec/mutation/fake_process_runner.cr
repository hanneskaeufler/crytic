require "../../src/crytic/process_runner"

module Crytic
  class FakeProcessRunner < ProcessRunner
    getter cmd
    getter args
    property exit_code
    @args : String = ""
    @output_io = IO::Memory.new

    def initialize
      @exit_code = 0
    end

    def run(cmd : String, args : Array(String), output, error)
      @cmd = cmd
      @args = args.join(" ")
      output << @output_io.to_s
      @exit_code
    end

    def run(cmd : String, args : Array(String), output, error, timeout)
      run(cmd, args, output, error)
    end

    def fill_output_with(text : String)
      @output_io << text
    end
  end
end
