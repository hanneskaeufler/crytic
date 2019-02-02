require "./mutation/result"
require "./mutation/result_set"

module Crytic
  record MutationScoreIndicator, value : Float64 do
    def to_s
      if value.finite?
        "#{value.round(2)}%"
      else
        "N/A"
      end
    end

    # Returns true or false depending on whether the msi is higher than or
    # equal to the given threshold
    def passes?(threshold)
      if value.finite?
        value >= threshold
      else
        true
      end
    end
  end

  # Calculates a score based on
  # https://infection.github.io/guide/#Mutation-Score-Indicator-MSI
  class MsiCalculator
    private getter results : Mutation::ResultSet

    def initialize(@results)
    end

    # Returns the mutation score indicator for the mutation results of this
    # instance
    def msi : MutationScoreIndicator
      total_defeated = results.covered_count + results.timeout_count + results.errored_count
      MutationScoreIndicator.new(total_defeated.to_f / results.total_count * 100)
    end
  end
end
