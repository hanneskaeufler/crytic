require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class SelectRejectSwap < TransformerMutant
    def transform(node : Crystal::Call)
      super
      location = node.location
      return node if location.nil?
      puts "node name: #{node.name}"
      puts "current location:"
      pp location
      puts "desired location:"
      pp @location
      puts "name col: #{node.name_column_number}"
      return node unless node.name == "select" && @location.is_a?(FullLocation) &&
                         location.column_number == @location.column_number &&
                         location.line_number == @location.line_number &&
                         node.name_column_number == @location.as(FullLocation).name_column_number
      puts "apply"
      Crystal::Call.new(
        node.obj,
        "reject",
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
