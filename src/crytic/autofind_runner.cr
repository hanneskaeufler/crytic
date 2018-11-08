require "./generator"
require "./io_reporter"
require "./mutant/**"
require "./mutation/mutation"
require "./mutation/no_mutation"
require "./source"

module Crytic
  class AutofindRunner
    def initialize(@reporter = IoReporter.new(STDOUT))
    end

    def run : Bool
      specs = Dir["./spec/**/*_spec.cr"]
      puts specs
      sources = Dir["./src/**/*.cr"]
      puts sources

      original_result = Mutation::NoMutation
        .with(specs: specs)
        .run

      @reporter.report_original_result(original_result)

      return false unless original_result.successful?

      results = sources.map do |source|
        Generator.new.mutations_for(source: source, specs: specs)
      end
        .flatten
        .map do |mutation|
          result = mutation.run
          @reporter.report_result(result)
          result
        end

      @reporter.report_summary(results)

      return results.map(&.status.covered?).all?
    end
  end
end
