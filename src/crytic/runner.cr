require "./generator/**"
require "./msi_calculator"
require "./mutation/no_mutation"
require "./reporter/**"
require "./runner_argument_validator"
require "./subject"

module Crytic
  class SequentialRunner
    include RunnerArgumentValidator

    alias Threshold = Float64

    def initialize(
      @threshold : Threshold,
      @reporters : Array(Reporter::Reporter),
      @generator : Generator
    )
    end

    def run(source : Array(String), specs : Array(String)) : Bool
      validate_args!(source, specs)

      original_result = Mutation::NoMutation.with(specs).run
      @reporters.each(&.report_original_result(original_result))

      return false unless original_result.successful?

      mutations = @generator.mutations_for(source, specs)

      @reporters.each(&.report_mutations(mutations))

      results = mutations.map do |mutation|
        result = mutation.run
        @reporters.each(&.report_result(result))
        result
      end

      @reporters.each(&.report_summary(results))
      @reporters.each(&.report_msi(results))

      return MsiCalculator.new(results).passes?(@threshold)
    end

    def run(source : String, specs : Array(String)) : Bool
      run([source], specs)
    end
  end
end
