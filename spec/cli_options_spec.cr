require "../src/crytic/cli_options"
require "./spec_helper"

module Crytic
  describe CliOptions do
    describe "#parse" do
      it "fails early for unknown flags" do
        std_err = IO::Memory.new
        exit_code : Int32? = nil

        cli_options_parser(
          std_err: std_err,
          exit_fun: ->(code : Int32) { exit_code = code })
          .parse(["-unknown"])

        std_err.to_s.lines.first.should eq "ERROR: -unknown is not a valid option."
        exit_code.should eq 1
      end

      {% for flag in ["-h", "--help"] %}
      it "shows help for {{ flag.id }}" do
        std_out = IO::Memory.new

        cli_options_parser(std_out: std_out).parse([{{ flag }}])

        std_out.to_s.lines.first.should eq "Usage: crytic [arguments]"
        std_out.to_s.lines[1].strip.should eq "-h, --help                       Show this help"
      end
      {% end %}

      it "exits when showing the help" do
        exit_code : Int32? = nil

        cli_options_parser(exit_fun: ->(code : Int32) { exit_code = code })
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

      it "throws when no spec files were given" do
        expect_raises(ArgumentError) do
          cli_options_parser(spec_files_glob: "").spec_files
        end
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

      it "defaults to the console reporter being enabled" do
        opts = cli_options_parser

        opts.reporters.size.should eq 1
        opts.reporters.first.should be_a(Reporter::IoReporter)
      end

      {% for flag in ["-r", "--reporters"] %}
      it "accepts reporters to be used with {{ flag.id }}" do
        opts = cli_options_parser.parse([{{ flag }}, "Console"])

        opts.reporters.size.should eq 1
        opts.reporters.first.should be_a(Reporter::IoReporter)
      end
      {% end %}

      it "accepts a comma separated list for multiple" do
        opts = cli_options_parser.parse(["--reporters", "Console,Stryker,ConsoleFileSummary"])

        opts.reporters.size.should eq 3
        opts.reporters.first.should be_a(Reporter::IoReporter)
        opts.reporters[1].should be_a(Reporter::StrykerBadgeReporter)
        opts.reporters.last.should be_a(Reporter::FileSummaryIoReporter)
      end
    end

    describe "#mutants" do
      it "returns all mutants" do
        cli_options_parser.mutants.should eq Generator::Generator::ALL_MUTANTS
      end
    end
  end
end

private def noop_exit_fun
  ->(_code : Int32) {}
end

private def cli_options_parser(
  std_out = IO::Memory.new,
  std_err = IO::Memory.new,
  exit_fun = noop_exit_fun,
  env = fake_env,
  spec_files_glob = Crytic::CliOptions::DEFAULT_SPEC_FILES_GLOB
)
  Crytic::CliOptions.new(std_out, std_err, exit_fun, env, spec_files_glob)
end
