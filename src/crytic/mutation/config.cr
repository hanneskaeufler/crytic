require "../mutant/mutant"
require "../subject"

module Crytic::Mutation
  record Config,
    mutant : Mutant::Mutant,
    subject : Subject,
    specs : Array(String),
    preamble : String do
    def self.noop(src, specs, preamble)
      new(
        Mutant::Noop.at_irrelevant_location(src),
        Subject.from_filepath(src),
        specs,
        preamble)
    end
  end
end
