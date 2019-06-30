require "./possibilities"

module Crytic::Mutant
  class AndOrSwapPossibilities < Possibilities
    def visit(node : Crystal::And | Crystal::Or)
      location = node.location
      unless location.nil?
        @locations << FullLocation.new(location, node.end_location)
      end
      true
    end
  end
end
