require "compiler/crystal/syntax/*"
require "./possibilities"

module Crytic::Mutant
  generate_possibilities_subclass(
    NumberLiteralChangePossibilities, Crystal::NumberLiteral)
end
