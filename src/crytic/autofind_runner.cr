require "./generator"
require "./mutant/**"
require "./mutation/mutation"
require "./mutation/no_mutation"
require "./reporter/io_reporter"
require "./source"

module Crytic
  class AutofindRunner
    private SRC = "./src/**/*.cr"
    private SPEC = "./spec/**/*_spec.cr"

    def initialize(
      @generator : Generator = InMemoryMutationsGenerator.new,
      @reporter : Reporter::Reporter = Reporter::IoReporter.new(STDOUT)
    )
    end

    def run : Bool
      specs = Dir[SPEC]
      puts specs
      sources = Dir[SRC]
      puts sources

      original_result = Mutation::NoMutation.with(specs: specs).run

      @reporter.report_original_result(original_result)

      return false unless original_result.successful?

      results = sources.map do |source|
        @generator.mutations_for(source: source, specs: specs)
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
