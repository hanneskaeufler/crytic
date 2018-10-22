require "./generator"
require "./io_reporter"
require "./mutant/**"
require "./mutation/mutation"
require "./mutation/no_mutation"
require "./source"

module Crytic
  class Runner
    def initialize(@reporter = IoReporter.new(STDOUT))
    end

    def run(source : String, specs : Array(String)) : Bool
      validate_args!(source, specs)

      original_result = Mutation::NoMutation
        .with(specs: specs)
        .run

      @reporter.report_original_result(original_result)

      return false unless original_result.successful?

      results = Generator
        .new
        .mutations_for(source: source, specs: specs)
        .map do |mutation|
          result = mutation.run
          @reporter.report_result(result)
          result
        end

      @reporter.report_summary(results)

      return results.map(&.status.covered?).all?
    end

    private def validate_args!(source, specs)
      if specs.empty?
        raise ArgumentError.new("No spec files given.")
      end

      unless File.exists?(source)
        raise ArgumentError.new("Source file for subject doesn't exist.")
      end

      specs.each do |spec_file|
        unless File.exists?(spec_file)
          raise ArgumentError.new("Spec file #{spec_file} doesn't exist.")
        end
      end
    end
  end
end
