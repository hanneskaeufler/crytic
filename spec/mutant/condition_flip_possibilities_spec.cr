require "../../src/crytic/mutant/condition_flip_possibilities"
require "../spec_helper"

module Crytic
  describe Mutant::ConditionFlipPossibilities do
    it "returns no possibilities if there are no num literals" do
      ast = ast_from("true")
      possibilities = Mutant::ConditionFlipPossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq false
    end

    it "returns locations for every possible mutation" do
      ast = ast_from("if true; 1; else; 2; end; if true; 1; else; 2; end;")
      possibilities = Mutant::ConditionFlipPossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq true
      possibilities.locations.size.should eq 2
    end
  end
end
