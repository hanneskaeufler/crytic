module Crytic::Reporter
  abstract class Reporter
    abstract def report_original_result(original_result)
    abstract def report_mutations(mutations)
    abstract def report_result(result)
    abstract def report_summary(results)
    abstract def report_msi(results)
  end
end
