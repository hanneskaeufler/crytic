require "spec"
require "../../src/crytic/mutant/number_literal_sign_flip"

module Crytic
  describe Mutant::NumberLiteralSignFlip do
    it "flips the sign of a literal" do
      ast = Crystal::Parser.parse("1")
      ast.accept(Mutant::NumberLiteralSignFlip.new)
      ast.to_s.should eq "-1"
    end

    it "doesn't apply when no number literal occurs" do
      ast = Crystal::Parser.parse("puts \"hello\"")
      mutant = Mutant::NumberLiteralSignFlip.new
      ast.accept(mutant)
      mutant.did_apply?.should eq false
      ast.to_s.should eq "puts(\"hello\")"
    end

    it "only applies one mutation at a time" do
      ast = Crystal::Parser.parse("1; 2;")
      ast.accept(Mutant::NumberLiteralSignFlip.new)
      ast.to_s.should eq <<-AST
      -1
      2

      AST
    end
  end
end
