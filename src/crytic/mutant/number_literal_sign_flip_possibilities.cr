require "./possibilities"

module Crytic::Mutant
  class NumberLiteralSignFlipPossibilities < Possibilities
    def visit(node : Crystal::NumberLiteral)
      return true if node.value == "0"
      return true if is_unsigned_type(node)

      location = node.location
      unless location.nil?
        @locations << FullLocation.new(location)
      end
      true
    end

    private def is_unsigned_type(node)
      node.kind
      case node.kind
      when :u8, :u16, :u32, :u64
        true
      else
        false
      end
    end
  end
end
