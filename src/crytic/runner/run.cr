require "../reporter/reporter"
require "../subject"

module Crytic::Runner
  alias NoMutationFactory = (Array(String)) -> Mutation::NoMutation

  record Run,
    msi_threshold : Float64,
    reporters : Array(Crytic::Reporter::Reporter),
    spec_files : Array(String),
    subjects : Array(Subject),
    generator : Generator::Generator,
    no_mutation_factory : NoMutationFactory do
    def self.from_options(options, generator, no_mutation_factory)
      new(options.msi_threshold, options.reporters, options.spec_files, options.subject, generator, no_mutation_factory)
    end

    def execute_original_test_suite(side_effects)
      no_mutation_factory.call(spec_files).run(side_effects)
    end

    def generate_mutations
      generator.mutations_for(subjects, spec_files)
    end

    {% for method in [:original_result, :mutations, :neutral_result, :result, :msi, :summary] %}
    def report_{{ method.id }}(result)
      reporters.each(&.report_{{ method.id }}(result))
    end
    {% end %}

    def report_final(results)
      report_summary(results)
      report_msi(results)

      !results.empty? && MsiCalculator.new(results).msi.passes?(msi_threshold)
    end
  end
end