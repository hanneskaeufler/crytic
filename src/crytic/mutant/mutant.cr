require "compiler/crystal/syntax/*"

module Crytic
  module Mutant
    abstract class Mutant < Crystal::Visitor
    end
  end
end
