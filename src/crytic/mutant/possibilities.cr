require "compiler/crystal/syntax/*"

module Crytic::Mutant
  abstract class Possibilities < Crystal::Visitor
    getter locations
    @locations = [] of Crystal::Location

    def any?
      @locations.size > 0
    end
  end
end
