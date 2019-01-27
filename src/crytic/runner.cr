require "./generator/**"
require "./msi_calculator"
require "./mutation/no_mutation"
require "./mutation/result"
require "./reporter/**"
require "./runner_argument_validator"
require "./subject"

module Crytic
  class Runner
    include RunnerArgumentValidator

    alias Threshold = Float64
    alias NoMutationFactory = (Array(String)) -> Mutation::NoMutation

    def initialize(
      @threshold : Threshold,
      @reporters : Array(Reporter::Reporter),
      @generator : Generator,
      @no_mutation_factory : NoMutationFactory = ->(specs : Array(String)) {
        Mutation::NoMutation.with(specs)
      }
    )
    end

    def run(source : Array(String), specs : Array(String)) : Bool
      validate_args!(source, specs)

      original_result = @no_mutation_factory.call(specs).run
      @reporters.each(&.report_original_result(original_result))

      return false unless original_result.successful?

      mutations = @generator.mutations_for(source, specs)

      @reporters.each(&.report_mutations(mutations))

      results = Mutation::ResultSet.new(mutations.map do |mutation_set|
        neutral_result = mutation_set.neutral.run
        raise Exception.new("dude that failed") if neutral_result.errored?

        mutation_set.mutated.map do |mutation|
          result = mutation.run
          @reporters.each(&.report_result(result))
          result
        end
      end.flatten)

      @reporters.each(&.report_summary(results))
      @reporters.each(&.report_msi(results))

      MsiCalculator.new(results).msi.passes?(@threshold)
    end

    def run(source : String, specs : Array(String)) : Bool
      run([source], specs)
    end
  end
end
