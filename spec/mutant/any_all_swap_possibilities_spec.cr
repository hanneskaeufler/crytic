require "../../src/crytic/mutant/any_all_swap_possibilities"
require "../spec_helper"

module Crytic
  describe Mutant::AnyAllSwapPossibilities do
    it "returns no possibilities if there is no all call" do
      ast = Crystal::Parser.parse("puts(\"hi\")")
      possibilities = Mutant::AnyAllSwapPossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq false
    end

    it "returns locations for every possible mutation" do
      ast = Crystal::Parser.parse("[1, 2].all?")
      possibilities = Mutant::AnyAllSwapPossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq true
      possibilities.locations.size.should eq 1
    end
  end
end

