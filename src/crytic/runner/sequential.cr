require "../generator/generator"
require "../msi_calculator"
require "../mutation/no_mutation"
require "../mutation/result"
require "../mutation/result_set"
require "../reporter/reporter"
require "./argument_validator"

module Crytic::Runner
  class Sequential
    include ArgumentValidator

    alias Threshold = Float64
    alias NoMutationFactory = (Array(String)) -> Mutation::NoMutation

    def initialize(
      @threshold : Threshold,
      @reporters : Array(Reporter::Reporter),
      @generator : Generator::Generator,
      @no_mutation_factory : NoMutationFactory = ->(specs : Array(String)) {
        Mutation::NoMutation.with(specs, ProcessProcessRunner.new)
      }
    )
    end

    def run(source : Array(String), specs : Array(String)) : Bool
      validate_args!(source, specs)

      original_result = run_original_test_suite(specs)

      return false unless original_result.successful?

      mutations = determine_possible_mutations(source, specs)
      results = Mutation::ResultSet.new(run_all_mutations(mutations))

      @reporters.each(&.report_summary(results))
      @reporters.each(&.report_msi(results))

      !results.empty? && MsiCalculator.new(results).msi.passes?(@threshold)
    end

    def run(source : String, specs : Array(String)) : Bool
      run([source], specs)
    end

    private def run_original_test_suite(specs)
      original_result = @no_mutation_factory.call(specs).run
      @reporters.each(&.report_original_result(original_result))
      original_result
    end

    private def determine_possible_mutations(source, specs)
      mutations = @generator.mutations_for(source, specs)
      @reporters.each(&.report_mutations(mutations))
      mutations
    end

    private def run_mutations_for_single_subject(mutation_set)
      mutation_set.mutated.map do |mutation|
        result = mutation.run
        @reporters.each(&.report_result(result))
        result
      end
    end

    private def discard_further_mutations_for_single_subject
      [] of Mutation::Result
    end

    private def run_all_mutations(mutations)
      mutations.map do |mutation_set|
        neutral_result = mutation_set.neutral.run
        @reporters.each(&.report_neutral_result(neutral_result))

        if neutral_result.errored?
          discard_further_mutations_for_single_subject
        else
          run_mutations_for_single_subject(mutation_set)
        end
      end.flatten
    end
  end
end
