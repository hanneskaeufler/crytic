require "./mutation/result"

module Crytic
  # Calculates a score based on
  # https://infection.github.io/guide/#Mutation-Score-Indicator-MSI
  class MsiCalculator
    private getter results : Array(Mutation::Result)

    def initialize(@results)
    end

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

    def passes?(threshold)
      msi >= threshold
    end
  end
end
