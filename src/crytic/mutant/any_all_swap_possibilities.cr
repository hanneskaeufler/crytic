require "./possibilities"

module Crytic::Mutant
  class AnyAllSwapPossibilities < Possibilities
    private ANY_ALL = %w(all? any?)

    def visit(node : Crystal::Call)
      return true unless ANY_ALL.includes?(node.name)
      location = node.location
      unless location.nil?
        @locations << FullLocation.new(Crystal::Location.new(nil, location.line_number, node.name_column_number))
      end
      true
    end
  end
end
