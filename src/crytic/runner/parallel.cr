module Crytic::Runner
  class Parallel
    def run(run, side_effects)
      original_result = run.execute_original_test_suite(side_effects)

      return false unless original_result.successful?

      mutation_sets = run.generate_mutations
      channels = mutation_sets.map { Channel(Array(Mutation::Result)).new }
      run_all_mutations(mutation_sets, channels, run)
      results = wait_for_all_jobs_to_finish(channels)
      run.report_final(Mutation::ResultSet.new(results))
    end

    private def discard_further_mutations_for_single_subject
      [] of Mutation::Result
    end

    private def wait_for_all_jobs_to_finish(channels)
      channels.map(&.receive).flatten
    end

    private def run_all_mutations(mutation_sets, channels, run)
      mutation_sets.each_with_index do |set, idx|
        channel = channels[idx]
        spawn do
          neutral_result = set.run_neutral(run)

          if neutral_result.errored?
            channel.send(discard_further_mutations_for_single_subject)
          else
            channel.send(set.run_mutated(run))
          end
        end
      end
    end
  end
end
