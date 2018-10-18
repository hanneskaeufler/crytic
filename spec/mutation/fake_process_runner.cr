require "../../src/crytic/process_runner"

module Crytic
  class FakeProcessRunner < ProcessRunner
    getter cmd
    getter args
    property exit_code
    @args : String = ""

    def initialize
      @exit_code = 0
    end

    def run(cmd : String, args : Array(String), output, error)
      @cmd = cmd
      @args = args.join(" ")
      @exit_code
    end
  end
end
