require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class AnyAllSwap < TransformerMutant
    def transform(node : Crystal::Call)
      location = node.location
      return node if location.nil?
      return node unless location.line_number == @location.line_number &&
                         location.column_number == @location.column_number &&
                         node.name_column_number == @location.name_column_number
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
