require "./possibilities"

module Crytic::Mutant
  class SelectRejectSwapPossibilities < Possibilities
      def visit(node : Crystal::Call)
        return true if node.name != "select"
        location = node.location
        unless location.nil?
          @locations << location
        end
        true
      end
  end
end
