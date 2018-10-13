require "spec"
require "../../src/crytic/mutant/bool_literal_flip"

module Crytic
  describe Mutant::BoolLiteralFlip do
    it "flips a boolean" do
      ast = Crystal::Parser.parse("true")
      ast.accept(Mutant::BoolLiteralFlip.new)
      ast.to_s.should eq "false"
    end

    it "doesn't apply when no boolean literal occurs" do
      ast = Crystal::Parser.parse("puts \"hello\"")
      mutant = Mutant::BoolLiteralFlip.new
      ast.accept(mutant)
      mutant.did_apply?.should eq false
      ast.to_s.should eq "puts(\"hello\")"
    end

    it "only applies one mutation at a time" do
      ast = Crystal::Parser.parse("true; false;")
      ast.accept(Mutant::BoolLiteralFlip.new)
      ast.to_s.should eq <<-AST
      false
      false

      AST
    end
  end
end
