module Crytic::Runner
  class Parallel
    def run(run, side_effects)
      original_result = run.execute_original_test_suite(side_effects)

      return false unless original_result.successful?

      mutation_sets = run.generate_mutations
      channels = mutation_sets.map { Channel(Array(Mutation::Result)).new }

      results = [] of Mutation::Result

      mutation_sets.each_with_index do |set, idx|
        channel = channels[idx]
        spawn do
          neutral_result = set.run_neutral
          run.report_neutral_result(neutral_result)

          if neutral_result.errored?
            channel.send([] of Mutation::Result)
          else
            res = set.run_mutated
            run.report_result(res)
            channel.send(res)
          end
        end
      end

      results = wait_for_all_jobs_to_finish(channels)
      run.report_final(results)
    end

    private def wait_for_all_jobs_to_finish(channels)
      channels.map(&.receive).flatten
    end
  end
end
