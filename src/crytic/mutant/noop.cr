require "./mutant"
require "./full_location"

module Crytic::Mutant
  class Noop < VisitorMutant
    def self.at_irrelevant_location(src)
      at(FullLocation.at(src, 0, 0))
    end
  end
end
