require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class NumberLiteralChange < Mutant
    def self.at(location : Crystal::Location)
      new(location)
    end

    def visit(node : Crystal::NumberLiteral)
      location = node.location
      return if location.nil?
      if location.line_number == @location.line_number &&
          location.column_number == @location.column_number
        node.value = "#{node.value}1"
      end
      true
    end

    # Ignore other nodes for now
    def visit(node : Crystal::ASTNode)
      true
    end

    private def initialize(@location : Crystal::Location)
    end
  end
end
