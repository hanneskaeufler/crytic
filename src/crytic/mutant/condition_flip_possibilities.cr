require "compiler/crystal/syntax/*"
require "./possibilities"

module Crytic::Mutant
  class ConditionFlipPossibilities < Possibilities
    def visit(node : Crystal::If)
      location = node.location
      unless location.nil?
        @locations << location
      end
      true
    end
  end
end
