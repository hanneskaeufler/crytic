require "../src/crytic/cli_options"
require "./spec_helper"

module Crytic
  describe CliOptions do
    describe "#parse" do
      it "fails early for unknown flags" do
        std_err = IO::Memory.new
        exit_code : Int32? = nil

        CliOptions
          .new(IO::Memory.new, std_err, ->(code : Int32) { exit_code = code })
          .parse(["-unknown"])

        std_err.to_s.lines.first.should eq "ERROR: -unknown is not a valid option."
        exit_code.should eq 1
      end

      it "shows help for -h" do
        std_out = IO::Memory.new

        CliOptions
          .new(std_out, IO::Memory.new, noop_exit_fun)
          .parse(["-h"])

        std_out.to_s.lines.first.should eq "Usage: crytic [arguments]"
      end

      {% for flag in ["-h", "--help"] %}
      it "shows help for {{ flag.id }}" do
        std_out = IO::Memory.new

        CliOptions
          .new(std_out, IO::Memory.new, noop_exit_fun)
          .parse([{{ flag }}])

        std_out.to_s.lines.first.should eq "Usage: crytic [arguments]"
        std_out.to_s.lines[1].strip.should eq "-h, --help                       Show this help"
      end
      {% end %}

      it "exits when showing the help" do
        exit_code : Int32? = nil

        CliOptions
          .new(IO::Memory.new, IO::Memory.new, ->(code : Int32) { exit_code = code })
          .parse(["--help"])

        exit_code.should eq 0
      end

      it "adds every positional argument as a spec file" do
        opts = cli_options_parser.parse(["a_file.cr", "another_file.cr"])

        opts.spec_files.should eq ["a_file.cr", "another_file.cr"]
      end

      it "defaults to a glob in spec for the spec files" do
        opts = cli_options_parser.parse([] of String)

        opts.spec_files.should eq Dir["./spec/**/*_spec.cr"]
      end

      {% for flag in ["-s", "--subject"] %}
      it "accepts a subject with {{ flag.id }}" do
        opts = cli_options_parser.parse([{{ flag }}, "subject.cr"])

        opts.subject.should eq ["subject.cr"]
      end
      {% end %}

      it "defaults to a glob in src for the subject" do
        opts = cli_options_parser.parse([] of String)

        opts.subject.should eq Dir["./src/**/*.cr"]
      end

      {% for flag in ["-p", "--preamble"] %}
      it "accepts a preamble with {{ flag.id }}" do
        opts = cli_options_parser.parse([{{ flag }}, "custom"])

        opts.preamble.should eq "custom"
      end
      {% end %}

      it "defaults to a fail fast preamble" do
        opts = cli_options_parser.parse([] of String)

        opts.preamble.should eq Generator::Generator::DEFAULT_PREAMBLE
      end

      {% for flag in ["-m", "--min-msi"] %}
      it "accepts a msi threshold with {{ flag.id }}" do
        opts = cli_options_parser.parse([{{ flag }}, "12.0"])

        opts.msi_threshold.should eq 12.0
      end
      {% end %}

      it "defaults to a threshold of 100.0" do
        cli_options_parser.msi_threshold.should eq 100.0
      end
    end
  end
end

private def noop_exit_fun
  ->(code : Int32) {}
end

private def cli_options_parser
  Crytic::CliOptions.new(IO::Memory.new, IO::Memory.new, noop_exit_fun)
end
