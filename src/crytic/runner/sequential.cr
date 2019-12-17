require "../mutation/result"
require "../mutation/result_set"
require "./run"
require "./runner"

module Crytic::Runner
  class Sequential < Runner
    def run(run, side_effects) : Bool
      original_result = run.execute_original_test_suite(side_effects)

      return false unless original_result.successful?

      mutations = run.generate_mutations
      results = Mutation::ResultSet.new(run_all_mutations(mutations, run))

      run.report_final(results)
    end

    private def discard_further_mutations_for_single_subject
      [] of Mutation::Result
    end

    private def run_all_mutations(mutations, run)
      mutations.map do |mutation_set|
        neutral_result = mutation_set.run_neutral(run)

        if neutral_result.errored?
          discard_further_mutations_for_single_subject
        else
          mutation_set.run_mutated(run)
        end
      end.flatten
    end
  end
end
