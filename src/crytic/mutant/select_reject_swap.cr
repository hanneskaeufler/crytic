require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class SelectRejectSwap < TransformerMutant
    def transform(node : Crystal::Call)
      super
      return node unless SelectRejectSwapPossibilities::SELECT_REJECT.includes?(node.name) &&
                         @location.matches?(node)
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
