require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class AnyAllSwap < TransformerMutant
    def transform(node : Crystal::Call)
      return node unless @location.matches?(node)
      Crystal::Call.new(
        node.obj,
        node.name == "any?" ? "all?" : "any?",
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
