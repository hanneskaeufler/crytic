require "../generator/generator"
require "../msi_calculator"
require "../mutation/no_mutation"
require "../mutation/result"
require "../mutation/result_set"
require "../reporter/reporter"
require "./run"

module Crytic::Runner
  class Sequential
    alias NoMutationFactory = (Array(String)) -> Mutation::NoMutation

    def initialize(
      @run : Run,
      @generator : Generator::Generator,
      @no_mutation_factory : NoMutationFactory = ->(specs : Array(String)) {
        Mutation::NoMutation.with(specs, ProcessProcessRunner.new)
      }
    )
    end

    def run : Bool
      original_result = run_original_test_suite(@run.spec_files)

      return false unless original_result.successful?

      mutations = determine_possible_mutations(@run.subjects, @run.spec_files)
      results = Mutation::ResultSet.new(run_all_mutations(mutations))

      @run.report_final(results)
    end

    private def run_original_test_suite(specs)
      original_result = @no_mutation_factory.call(specs).run
      @run.report_original_result(original_result)
      original_result
    end

    private def determine_possible_mutations(subject, specs)
      mutations = @generator.mutations_for(subject, specs)
      @run.report_mutations(mutations)
      mutations
    end

    private def run_mutations_for_single_subject(mutation_set)
      mutation_set.mutated.map do |mutation|
        result = mutation.run
        @run.report_result(result)
        result
      end
    end

    private def discard_further_mutations_for_single_subject
      [] of Mutation::Result
    end

    private def run_all_mutations(mutations)
      mutations.map do |mutation_set|
        neutral_result = mutation_set.neutral.run
        @run.report_neutral_result(neutral_result)

        if neutral_result.errored?
          discard_further_mutations_for_single_subject
        else
          run_mutations_for_single_subject(mutation_set)
        end
      end.flatten
    end
  end
end
