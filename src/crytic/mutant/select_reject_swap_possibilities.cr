require "./possibilities"

module Crytic::Mutant
  class SelectRejectSwapPossibilities < Possibilities
    def visit(node : Crystal::Call)
      return true if node.name != "select"
      location = node.location
      unless location.nil?
        pp node.name_column_number
        @locations << FullLocation.new(location, name_column_number: node.name_column_number)
      end
      true
    end
  end
end
