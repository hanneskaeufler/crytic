require "../mutation/result_set"
require "./runner"

module Crytic::Runner
  class Parallel < Runner
    private SLICE_SIZE = 2

    def run(run, side_effects) : Bool
      original_result = run.execute_original_test_suite(side_effects)

      return false unless original_result.successful?

      run.report_final(run_all_mutations(run.generate_mutations, run))
    end

    private def discard_further_mutations_for_single_subject
      [] of Mutation::Result
    end

    private def wait_for_all_jobs_to_finish(channel, actual_size)
      results = [] of Array(Mutation::Result)
      actual_size.times { results << channel.receive }
      results.flatten
    end

    private def run_all_mutations(mutation_sets, run)
      results = [] of Array(Mutation::Result)
      mutation_sets.each_slice(SLICE_SIZE) do |slice|
        channel = Channel(Array(Mutation::Result)).new(SLICE_SIZE)

        slice.each_with_index do |set, idx|
          STDOUT.puts "--- Mutant ##{idx}"
          spawn do
            STDOUT.puts "Run neutral mutant ##{idx}"
            neutral_result = set.run_neutral(run)
            STDOUT.puts "Finished neutral mutant ##{idx}"

            if neutral_result.errored?
              channel.send(discard_further_mutations_for_single_subject)
            else
              STDOUT.puts "Run mutant ##{idx}"
              channel.send(set.run_mutated(run))
              STDOUT.puts "Finished mutant ##{idx}"
            end
          rescue exc
            STDOUT.puts exc
            run.report_exception(exc)
            channel.send(discard_further_mutations_for_single_subject)
          end
        end
        results << wait_for_all_jobs_to_finish(channel, slice.size)
      end

      Mutation::ResultSet.new(results.flatten)
    end
  end
end
