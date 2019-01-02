require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class SelectRejectSwap < TransformerMutant
    def transform(node : Crystal::Call)
      super
      location = node.location
      return node if location.nil?
      return node unless SelectRejectSwapPossibilities::SELECT_REJECT.includes?(node.name) &&
                         @location.is_a?(FullLocation) &&
                         location.column_number == @location.column_number &&
                         location.line_number == @location.line_number &&
                         node.name_column_number == @location.as(FullLocation).name_column_number
      Crystal::Call.new(
        node.obj,
        node.name == "reject" ? "select" : "reject",
        node.args,
        node.block,
        node.block_arg,
        node.named_args,
        node.global?,
        node.name_column_number,
        node.has_parentheses?)
    end
  end
end
