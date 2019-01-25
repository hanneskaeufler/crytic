require "./possibilities"

module Crytic::Mutant
  class AndOrSwapPossibilities < Possibilities
    def visit(node : Crystal::And)
      location = node.location
      unless location.nil?
        @locations << FullLocation.new(location, end_location: node.end_location)
      end
      true
    end
  end
end
