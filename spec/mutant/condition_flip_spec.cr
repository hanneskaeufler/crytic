require "spec"
require "../../src/crytic/mutant/condition_flip"

module Crytic
  describe Mutant::ConditionFlip do
    it "flips the branches" do
      ast = Crystal::Parser.parse("if true 1; else 2; end")
      ast.accept(Mutant::ConditionFlip.new)
      ast.to_s.should eq <<-AST
      if true
        2
      else
        1
      end
      AST
    end

    it "doesn't apply when no conditional occurs" do
      ast = Crystal::Parser.parse("puts 1")
      mutant = Mutant::ConditionFlip.new
      ast.accept(mutant)
      mutant.did_apply?.should eq false
      ast.to_s.should eq "puts(1)"
    end

    it "only applies one mutation at a time" do
      ast = Crystal::Parser.parse("if true 1; else 2; end; if false 1; else 2; end")
      ast.accept(Mutant::ConditionFlip.new)
      ast.to_s.should eq <<-AST
      if true
        2
      else
        1
      end
      if false
        1
      else
        2
      end

      AST
    end
  end
end
