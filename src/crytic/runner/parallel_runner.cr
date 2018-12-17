require "../generator/generator"
require "../msi_calculator"
require "../mutation/no_mutation"
require "../reporter/reporter"
require "../runner_argument_validator"
require "dispatch"

module Crytic
  module Runner
    class MutationJob
      include Dispatchable

      def perform(mutation, reporters, collector)
        result = mutation.run
        reporters.each(&.report_result(result))
        collector.results << result
      end
    end

    class ResultCollector
      property results : Array(Crytic::Mutation::Result) = [] of Crytic::Mutation::Result
    end
  end

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

      result_collector = start_to_run_mutations(mutations)
      wait_until_all_mutations_exited(mutations)

      reporters.each(&.report_summary(result_collector.results))
      reporters.each(&.report_msi(result_collector.results))

      return msi_passes_threshold?(result_collector)
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
      result_collector = Runner::ResultCollector.new

      mutations.map do |mutation|
        Runner::MutationJob.dispatch(mutation, reporters, result_collector)
      end

      result_collector
    end

    private def msi_passes_threshold?(result_collector)
      MsiCalculator.new(result_collector.results).passes?(@threshold)
    end
  end
end
