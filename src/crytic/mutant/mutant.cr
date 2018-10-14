require "compiler/crystal/syntax/*"

module Crytic::Mutant
  abstract class Mutant < Crystal::Visitor
    @did_apply = false

    def did_apply? : Bool
      @did_apply
    end
  end
end