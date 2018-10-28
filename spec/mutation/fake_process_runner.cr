require "../../src/crytic/process_runner"

module Crytic
  class FakeProcessRunner < ProcessRunner
    private getter cmd
    private getter args
    property exit_code
    property timeout
    @timeout = [] of Time::Span
    @cmd = [] of String
    @args = [] of String
    @output_io = IO::Memory.new

    def cmd_with_args
      cmd.zip(args).map { |c, a| "#{c} #{a}".strip }
    end

    def initialize
      @exit_code = 0
    end

    def run(cmd : String, args : Array(String), output, error)
      @cmd << cmd
      @args << args.join(" ")
      output << @output_io.to_s
      @exit_code
    end

    def run(cmd : String, args : Array(String), output, error, timeout)
      @timeout << timeout
      run(cmd, args, output, error)
    end

    def fill_output_with(text : String)
      @output_io << text
    end
  end
end
