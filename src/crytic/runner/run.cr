require "../reporter/reporter"
require "../subject"

module Crytic::Runner
  record Run, msi_threshold : Float64, reporters : Array(Crytic::Reporter::Reporter), spec_files : Array(String), subjects : Array(Subject) do
    def self.from_options(options)
      new(options.msi_threshold, options.reporters, options.spec_files, options.subject)
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
