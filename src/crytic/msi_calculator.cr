require "./mutation/result"

module Crytic
  # Calculates a score based on
  # https://infection.github.io/guide/#Mutation-Score-Indicator-MSI
  class MsiCalculator
    private getter results : Array(Mutation::Result)

    def initialize(@results)
    end

    # Returns the mutation score indicator for the mutation results of this
    # instance
    def msi
      return 100.0 if results.empty?
      total = results.size
      killed = results.count(&.covered?)
      timed_out = results.count(&.timeout?)
      errored = results.count(&.errored?)
      total_defeated = killed + timed_out + errored
      msi = total_defeated.to_f / total * 100
      msi.round(2)
    end

    # Returns true or false depending on whether the msi is higher than or
    # equal to the given threshold
    def passes?(threshold)
      msi >= threshold
    end
  end
end
