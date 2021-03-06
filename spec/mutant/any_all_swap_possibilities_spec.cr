require "../../src/crytic/mutant/any_all_swap_possibilities"
require "../spec_helper"

module Crytic
  describe Mutant::AnyAllSwapPossibilities do
    it "returns no possibilities if there is no all call" do
      ast = ast_from("puts(\"hi\")")
      possibilities = Mutant::AnyAllSwapPossibilities.new
      ast.accept(possibilities)
      possibilities.empty?.should be_true
    end

    it "returns locations for every possible mutation" do
      ast = ast_from("[1, 2].all?; [1].any?;")
      possibilities = Mutant::AnyAllSwapPossibilities.new
      ast.accept(possibilities)
      possibilities.empty?.should be_false
      possibilities.locations.size.should eq 2
    end
  end
end
