require "./possibilities"

module Crytic::Mutant
  generate_possibilities_subclass(
    StringLiteralChangePossibilities, Crystal::StringLiteral)
end
