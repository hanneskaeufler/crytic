require "../src/crytic/process_process_runner"
require "./spec_helper"

module Crytic
  describe ProcessProcessRunner do
    describe "#run" do
      it "runs arbitrary commands and returns the exit code" do
        io = IO::Memory.new
        code = ProcessProcessRunner.new.run("true", [] of String, io, io)
        code.should eq 0
      end

      it "can run commands with arguments" do
        io = IO::Memory.new
        code = ProcessProcessRunner.new.run("/bin/sh", ["-c", "exit 123"], io, io)
        code.should eq 123
      end

      it "times out after the given period" do
        io = IO::Memory.new
        code = ProcessProcessRunner.new.run("/bin/bash", ["-c", "while true; do echo hi; sleep 1; done"], io, io, timeout: 10.milliseconds)
        code.should eq 28
        io.to_s.should contain "hi"
      end
    end
  end
end
