require "../mutant/mutant"

module Crytic::Mutation
  record Config,
    mutant : Mutant::Mutant,
    original : String,
    specs : Array(String),
    preamble : String do
    def self.noop(src, specs, preamble)
      new(Mutant::Noop.at_irrelevant_location(src), src, specs, preamble)
    end
  end
end
