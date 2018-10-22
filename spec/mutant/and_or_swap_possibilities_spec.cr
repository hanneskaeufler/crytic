require "spec"
require "../../src/crytic/mutant/and_or_swap_possibilities"

module Crytic
  describe Mutant::AndOrSwapPossibilities do
    it "returns no possibilities if there is no and binary operator" do
      ast = Crystal::Parser.parse("1")
      possibilities = Mutant::AndOrSwapPossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq false
    end

    it "returns locations for every possible mutation" do
      ast = Crystal::Parser.parse("1 && 2; true && false")
      possibilities = Mutant::AndOrSwapPossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq true
      possibilities.locations.size.should eq 2
    end
  end
end
