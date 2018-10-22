require "compiler/crystal/syntax/*"
require "./possibilities"

module Crytic::Mutant
  generate_possibilities_subclass(
    ConditionFlipPossibilities, Crystal::If)
end
