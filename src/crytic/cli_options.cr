require "./generator/generator"
require "./mutant/possibilities"
require "./reporter/*"
require "option_parser"

module Crytic
  class CliOptions
    DEFAULT_SPEC_FILES_GLOB = "./spec/**/*_spec.cr"
    getter msi_threshold = 100.0
    getter mutants : Array(Mutant::Possibilities) = Generator::Generator::ALL_MUTANTS
    getter preamble = Generator::Generator::DEFAULT_PREAMBLE
    getter reporters = [] of Reporter::Reporter
    @spec_files = [] of String
    @subject = [] of String

    def initialize(
      @std_out : IO,
      @std_err : IO,
      @exit_fun : (Int32) ->,
      @env : Hash(String, String),
      @spec_files_glob : String
    )
      @reporters << Reporter::IoReporter.new(@std_out)
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

        parser.on("-r REPORTERS", "--reporters=REPORTERS", "Comma-separated list of reporters to be used.") do |list|
          list = list.split(",").map(&.strip.downcase)
          @reporters = [] of Reporter::Reporter
          @reporters << console_reporter if list.includes?("console")
          @reporters << stryker_reporter if list.includes?("stryker")
          @reporters << file_summary_reporter if list.includes?("consolefilesummary")
        end

        parser.unknown_args do |unknown|
          @spec_files = unknown
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
      files = unless @spec_files.empty?
        @spec_files
      else
        Dir[@spec_files_glob]
      end

      raise ArgumentError.new("No spec files given or found.") if files.empty?

      files
    end

    def subject : Array(String)
      return Dir["./src/**/*.cr"] if @subject.empty?

      @subject
    end

    private def console_reporter
      Reporter::IoReporter.new(@std_out)
    end

    private def stryker_reporter
      client = Reporter::DefaultHttpClient.new
      Reporter::StrykerBadgeReporter.new(client, @env, @std_out)
    end

    private def file_summary_reporter
      Reporter::FileSummaryIoReporter.new(@std_out)
    end
  end
end
