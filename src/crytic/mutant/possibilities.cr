require "compiler/crystal/syntax/*"

module Crytic::Mutant
  abstract class Possibilities < Crystal::Visitor
    macro inherited
      def mutant_class
        {{ @type.id.gsub(/Possibilities/, "") }}
      end
    end

    getter locations
    @locations = [] of Crystal::Location

    def any?
      @locations.size > 0
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
          @locations << location
        end
        true
      end
    end
  end
end
