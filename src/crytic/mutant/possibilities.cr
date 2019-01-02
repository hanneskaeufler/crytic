require "./full_location"
require "compiler/crystal/syntax/*"

module Crytic::Mutant
  abstract class Possibilities < Crystal::Visitor
    macro inherited
      def mutant_class
        {{ @type.id.gsub(/Possibilities/, "") }}
      end
    end

    getter locations
    @locations = [] of FullLocation

    def any?
      @locations.size > 0
    end

    def reset
      @locations = [] of FullLocation
    end

    def visit(node : Crystal::ASTNode)
      true
    end
  end

  macro generate_possibilities_subclass(name, node)
    class {{ name.id }} < Possibilities
      def visit(node : {{ node }})
        location = node.location
        unless location.nil?
          @locations << FullLocation.new(location)
        end
        true
      end
    end
  end
end
