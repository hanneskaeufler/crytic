require "compiler/crystal/syntax/*"
require "./mutant"

module Crytic::Mutant
  class DropCallInVoidDef < TransformerMutant
    def transform(node : Crystal::Call)
      super
      return node unless @location.matches?(node)
      Crystal::NilLiteral.new
    end
  end
end
