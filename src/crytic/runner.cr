require "./generator/**"
require "./msi_calculator"
require "./mutant/**"
require "./mutation/mutation"
require "./mutation/no_mutation"
require "./reporter/**"
require "./source"

module Crytic
  class Runner
    alias Threshold = Float64

    def initialize(
      @threshold : Threshold = 100.0,
      @reporters = [Reporter::IoReporter.new(STDOUT)] of Reporter::Reporter,
      @generator : Generator = InMemoryMutationsGenerator.new
    )
    end

    def run(source : String, specs : Array(String)) : Bool
      validate_args!(source, specs)

      original_result = Mutation::NoMutation.with(specs).run
      @reporters.each(&.report_original_result(original_result))

      return false unless original_result.successful?

      results = @generator
        .mutations_for(source: source, specs: specs)
        .map do |mutation|
          result = mutation.run
          @reporters.each(&.report_result(result))
          result
        end

      @reporters.each(&.report_summary(results))
      @reporters.each(&.report_msi(results))

      return MsiCalculator.new(results).passes?(@threshold)
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
