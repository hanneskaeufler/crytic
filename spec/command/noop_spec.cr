require "../../src/crytic/command/noop"
require "../spec_helper"

module Crytic::Command
  def self.subject(
    stdout = IO::Memory.new,
    stderr = IO::Memory.new,
    exit_fun = ->(_code : Int32) { },
    spec_files_glob = Noop::DEFAULT_SPEC_FILES_GLOB,
  )
    Noop.new(side_effects(stdout, stderr, exit_fun), spec_files_glob)
  end

  describe Noop do
    describe "#execute" do
      it "outputs to stdout" do
        stdout = IO::Memory.new

        subject(stdout: stdout).execute(["./fixtures/simple/bar_spec.cr"])

        stdout.to_s.should contain File.read("./fixtures/simple/bar.cr")
      end

      it "uses the default glob when not passing any spec files" do
        stdout = IO::Memory.new

        subject(stdout: stdout, spec_files_glob: "./fixtures/simple/*_spec.cr")
          .execute([] of String)

        stdout.to_s.should contain File.read("./fixtures/simple/bar.cr")
      end

      it "errors when no spec files where given and none found with the glob" do
        stderr = IO::Memory.new
        exit_code : Int32? = nil

        subject(
          stderr: stderr,
          exit_fun: ->(code : Int32) { exit_code = code; nil },
          spec_files_glob: "")
          .execute([] of String)

        exit_code.should eq 1
        stderr.to_s.should eq "No spec files given or found.\n"
      end

      it "errors when a non existing spec file was given" do
        stderr = IO::Memory.new
        exit_code : Int32? = nil

        noop = subject(
          stderr: stderr,
          exit_fun: ->(code : Int32) { exit_code = code; nil })

        begin
          noop.execute(["doesnt_exist.cr"])
        rescue
        end

        exit_code.should eq 1
        stderr.to_s.should eq "Spec file doesnt_exist.cr doesn't exist.\n"
      end
    end
  end
end
