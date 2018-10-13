require "spec"
require "../../src/crytic/mutant/number_literal_change"

module Crytic
  describe Mutant::NumberLiteralChange do
    it "changes the value of a number literal" do
      ast = Crystal::Parser.parse("1")
      ast.accept(Mutant::NumberLiteralChange.new)
      ast.to_s.should eq "11"
    end

    it "doesn't apply when no number literal occurs" do
      ast = Crystal::Parser.parse("puts \"hello\"")
      mutant = Mutant::NumberLiteralChange.new
      ast.accept(mutant)
      mutant.did_apply?.should eq false
      ast.to_s.should eq "puts(\"hello\")"
    end

    it "only applies one mutation at a time" do
      ast = Crystal::Parser.parse("1; 2;")
      ast.accept(Mutant::NumberLiteralChange.new)
      ast.to_s.should eq <<-AST
      11
      2

      AST
    end
  end
end
