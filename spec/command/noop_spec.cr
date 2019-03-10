require "../../src/crytic/command/noop"
require "../spec_helper"

module Crytic::Command
  def self.subject(
    stdout = IO::Memory.new,
    stderr = IO::Memory.new,
    spec_files_glob = Noop::DEFAULT_SPEC_FILES_GLOB
  )
    Noop.new(stdout, stderr, spec_files_glob)
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

        subject(stdout: stdout, spec_files_glob: "./fixtures/simple/*_spec.cr").execute([] of String)

        stdout.to_s.should contain File.read("./fixtures/simple/bar.cr")
      end

      it "errors when a non existing spec file was given" do
        expect_raises(ArgumentError, "Spec file doesnt_exist.cr doesn't exist.") do
          subject.execute(["doesnt_exist.cr"])
        end
      end
    end
  end
end
