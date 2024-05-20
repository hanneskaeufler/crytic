require "./possibilities"

module Crytic::Mutant
  class NumberLiteralSignFlipPossibilities < Possibilities
    def visit(node : Crystal::NumberLiteral)
      return true if node.value == "0"
      return true if unsigned_type?(node)

      location = node.location
      unless location.nil?
        @locations << FullLocation.new(location)
      end
      true
    end

    private def unsigned_type?(node)
      node.kind.to_s.starts_with?("u")
    end
  end
end
