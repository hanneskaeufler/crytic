require "../mutation/result"

module Crytic::Reporter
  abstract class Reporter
    abstract def report_original_result(original_result)
    abstract def report_mutations(mutations)
    abstract def report_neutral_result(result)
    abstract def report_result(result)
    abstract def report_summary(results : Mutation::ResultSet)
    abstract def report_msi(results : Mutation::ResultSet)
  end
end
