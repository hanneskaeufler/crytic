require "./generator/generator"
require "./mutant/possibilities"
require "./reporter/*"
require "./side_effects"
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

    def initialize(@side_effects : SideEffects, @spec_files_glob : String)
      @reporters << Reporter::IoReporter.new(@side_effects.std_out)
    end

    def parse(args)
      OptionParser.parse(args) do |parser|
        parser.banner = "Usage: crytic [arguments]"

        parser.on("-h", "--help", "Show this help") do
          @side_effects.std_out.puts parser
          @side_effects.exit_fun.call(0)
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
          @side_effects.std_err.puts "ERROR: #{flag} is not a valid option."
          @side_effects.std_err.puts parser
          @side_effects.exit_fun.call(1)
        end
      end

      self
    end

    def spec_files : Array(String)
      files = if @spec_files.empty?
                Dir[@spec_files_glob]
              else
                @spec_files
              end

      raise ArgumentError.new("No spec files given or found.") if files.empty?

      files
    end

    def subject
      if @subject.empty?
        Dir["./src/**/*.cr"]
      else
        @subject
      end.map { |path| Subject.from_filepath(path) }
    end

    private def console_reporter
      Reporter::IoReporter.new(@side_effects.std_out)
    end

    private def stryker_reporter
      client = Reporter::DefaultHttpClient.new
      Reporter::StrykerBadgeReporter.new(client, @side_effects.env, @side_effects.std_out)
    end

    private def file_summary_reporter
      Reporter::FileSummaryIoReporter.new(@side_effects.std_out)
    end
  end
end
