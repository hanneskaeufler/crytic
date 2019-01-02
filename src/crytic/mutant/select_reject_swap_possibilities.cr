require "./possibilities"

module Crytic::Mutant
  class SelectRejectSwapPossibilities < Possibilities
    SELECT_REJECT = %w(select reject)

    def visit(node : Crystal::Call)
      return true unless SELECT_REJECT.includes?(node.name)
      location = node.location
      unless location.nil?
        @locations << FullLocation.new(location, node.name_column_number)
      end
      true
    end
  end
end
