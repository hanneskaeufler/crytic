require "./possibilities"

module Crytic::Mutant
  class DropCallInVoidDefPossibilities < Possibilities
    def visit(node : Crystal::Def)
      location = node.location
      unless location.nil?
        if def_is_return_void(node)
          node_body = node.body
          case node_body
          when Crystal::Expressions
            mark_calls_in_body_expression(node_body)
          when Crystal::Call
            mark_single_call_in_body(node_body)
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

    private def mark_single_call_in_body(node_body) : Nil
      body_location = node_body.location
      if body_location
        @locations << FullLocation.new(body_location)
      end
    end

    private def mark_calls_in_body_expression(node_body) : Nil
      node_body.expressions.each do |ex|
        ex_location = ex.location
        if ex_location && ex.is_a?(Crystal::Call)
          @locations << FullLocation.new(ex_location)
        end
      end
    end
  end
end
