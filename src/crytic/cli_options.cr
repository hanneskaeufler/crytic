require "./generator/generator"
require "option_parser"

module Crytic
  class CliOptions
    getter preamble = Crytic::Generator::Generator::DEFAULT_PREAMBLE
    getter msi_threshold = 100.0
    @spec_files = [] of String
    @subject = [] of String

    def initialize(@std_out : IO, @std_err : IO, @exit_fun : (Int32) ->)
    end

    def parse(args)
      OptionParser.parse(args) do |parser|
        parser.banner = "Usage: crytic [arguments]"

        parser.on("-h", "--help", "Show this help") do
          @std_out.puts parser
          @exit_fun.call(0)
        end

        parser.on("-m", "--min-msi=THRESHOLD", "Crytic will exit with zero if this threshold is reached.") do |threshold|
          @msi_threshold = threshold.to_f
        end

        parser.on("-p PREAMBLE", "--preamble=PREAMBLE", "Specifies the source code that is prepended to every full mutation source code. Will enable the fail_fast option of crystal spec by default.") do |code|
          @preamble = code
        end

        parser.on("-s SOURCE", "--subject=SOURCE", "Specifies the source file for the subject") do |source|
          @subject = [source]
        end

        parser.unknown_args do |args|
          @spec_files = args
        end

        parser.invalid_option do |flag|
          @std_err.puts "ERROR: #{flag} is not a valid option."
          @std_err.puts parser
          @exit_fun.call(1)
        end
      end

      self
    end

    def spec_files : Array(String)
      return Dir["./spec/**/*_spec.cr"] if @spec_files.empty?

      @spec_files
    end

    def subject : Array(String)
      return Dir["./src/**/*.cr"] if @subject.empty?

      @subject
    end
  end
end
