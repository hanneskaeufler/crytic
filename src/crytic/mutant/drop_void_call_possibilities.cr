require "./possibilities"

module Crytic::Mutant
  class DropVoidCallPossibilities < Possibilities
    def visit(node : Crystal::Def)
      location = node.location
      unless location.nil?
        if def_is_return_void(node)
          case node.body
          when Crystal::Call
            body_location = node.body.location
            if body_location
              @locations << FullLocation.new(body_location)
            end
          end
        end
      end
      true
    end

    private def def_is_return_void(node) : Bool
      # This took a while to figure out:
      # https://gitter.im/crystal-lang/crystal?at=5ee54f6d30401c1f24556328
      ret = node.return_type
      ret.is_a?(Crystal::Path) && ret.names == ["Nil"]
    end
  end
end
