require "../mutant/mutant"

module Crytic::Mutation
  record Config,
    mutant : Mutant::Mutant,
    original : String,
    specs : Array(String),
    preamble : String
end
