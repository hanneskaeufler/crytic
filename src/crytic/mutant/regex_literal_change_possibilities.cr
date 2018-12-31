require "compiler/crystal/syntax/*"
require "./possibilities"

module Crytic::Mutant
  generate_possibilities_subclass(
    RegexLiteralChangePossibilities, Crystal::RegexLiteral)
end
