require "../mutation/no_mutation"
require "../reporter/reporter"
require "../subject"

module Crytic::Runner
  alias NoMutationFactory = (Array(String)) -> Mutation::NoMutation

  class Run
    def initialize(
      @msi_threshold : Float64,
      @reporters : Crytic::Reporter::Reporters,
      @spec_files : Array(String),
      @subjects : Array(Subject),
      @generator : Generator::Generator,
      @no_mutation_factory : NoMutationFactory,
    )
    end

    def self.from_options(options, generator, no_mutation_factory)
      new(options.msi_threshold, options.reporters, options.spec_files, options.subject, generator, no_mutation_factory)
    end

    def execute_original_test_suite(side_effects)
      original_result = @no_mutation_factory.call(@spec_files).run(side_effects)
      report_original_result(original_result)
      original_result
    end

    def generate_mutations
      @generator.mutations_for(@subjects, @spec_files).tap do |mutations|
        report_mutations(mutations)
      end
    end

    {% for method in [:original_result, :mutations, :neutral_result, :result, :msi, :summary] %}
    def report_{{ method.id }}(result) : Nil
      @reporters.each(&.report_{{ method.id }}(result))
    end
    {% end %}

    def report_final(results)
      report_summary(results)
      report_msi(results)

      !results.empty? && MsiCalculator.new(results).msi.passes?(@msi_threshold)
    end
  end
end
