require "../generator/generator"
require "../msi_calculator"
require "../mutation/no_mutation"
require "../reporter/reporter"
require "../runner_argument_validator"
require "./mutation_job"

module Crytic
  class ParallelRunner
    include RunnerArgumentValidator

    alias Threshold = Float64
    private TICK = 0.5
    private getter reporters

    def initialize(
      @threshold : Threshold,
      @reporters : Array(Reporter::Reporter),
      @generator : Generator
    )
    end

    def run(source : Array(String), specs : Array(String)) : Bool
      validate_args!(source, specs)

      return false unless run_original(specs).successful?

      mutations = generate_mutations(source, specs)

      results = start_to_run_mutations(mutations)
      wait_until_all_mutations_exited(mutations)

      reporters.each(&.report_summary(results))
      reporters.each(&.report_msi(results))

      return msi_passes_threshold?(results)
    end

    def run(source : String, specs : Array(String)) : Bool
      run([source], specs)
    end

    private def generate_mutations(source, specs)
      @generator.mutations_for(source, specs)
    end

    private def run_original(specs)
      original_result = Mutation::NoMutation.with(specs).run
      reporters.each(&.report_original_result(original_result))
      original_result
    end

    private def wait_until_all_mutations_exited(mutations)
      while (Dispatch.successes + Dispatch.failures) < mutations.size
        sleep TICK
      end
    end

    private def start_to_run_mutations(mutations)
      results = [] of Crytic::Mutation::Result

      mutations.map do |mutation|
        Runner::MutationJob.dispatch(mutation, reporters, results)
      end

      results
    end

    private def msi_passes_threshold?(results)
      MsiCalculator.new(results).passes?(@threshold)
    end
  end
end
