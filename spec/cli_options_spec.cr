require "./spec_helper"
require "option_parser"

noop_exit_fun = ->(code : Int32) { }

module Crytic
  class CliOptions

    getter spec_files = [] of String
    @subject = [] of String

    def initialize(@std_out : IO, @exit_fun : (Int32)->)
    end

    def parse(args)
      OptionParser.parse(args) do |parser|
        parser.banner = "Usage: crytic [arguments]"

        parser.on("-h", "--help", "Show this help") do
          @std_out.puts parser
          @exit_fun.call(0)
        end

        parser.on("-s SOURCE", "--subject=SOURCE", "Specifies the source file for the subject") do |source|
          @subject = [source]
        end

        parser.unknown_args do |args|
          @spec_files = args
        end
      end

      self
    end

    def subject : Array(String)
      return Dir["./src/**/*.cr"] if @subject.empty?

      @subject
    end
  end
end

module Crytic
  describe CliOptions do
    describe "#parse" do
      it "shows help for -h" do
        std_out = IO::Memory.new

        CliOptions
          .new(std_out, noop_exit_fun)
          .parse(["-h"])

        std_out.to_s.lines.first.should eq "Usage: crytic [arguments]"
      end

      {% for flag in ["-h", "--help"] %}
      it "shows help for {{ flag.id }}" do
        std_out = IO::Memory.new

        CliOptions
          .new(std_out, noop_exit_fun)
          .parse([{{ flag }}])

        std_out.to_s.lines.first.should eq "Usage: crytic [arguments]"
        std_out.to_s.lines[1].strip.should eq "-h, --help                       Show this help"
      end
      {% end %}

      it "exits when showing the help" do
        exit_code : Int32? = nil

        CliOptions
          .new(IO::Memory.new, ->(code : Int32){ exit_code = code })
          .parse(["--help"])

        exit_code.should eq 0
      end

      it "adds every positional argument as a spec file" do
        opts = CliOptions
          .new(IO::Memory.new, noop_exit_fun)
          .parse(["a_file.cr", "another_file.cr"])

        opts.spec_files.should eq ["a_file.cr", "another_file.cr"]
      end

      {% for flag in ["-s", "--subject"] %}
      it "accepts a subject with {{ flag.id }}" do
        opts = CliOptions
          .new(IO::Memory.new, noop_exit_fun)
          .parse([{{ flag }}, "subject.cr"])

        opts.subject.should eq ["subject.cr"]
      end
      {% end %}

      it "defaults to a glob in src for the subject" do
        opts = CliOptions
          .new(IO::Memory.new, noop_exit_fun)
          .parse([] of String)

        opts.subject.should eq Dir["./src/**/*.cr"]
      end
    end
  end
end

