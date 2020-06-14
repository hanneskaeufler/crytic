require "../../src/crytic/mutant/and_or_swap_possibilities"
require "../spec_helper"

module Crytic
  describe Mutant::AndOrSwapPossibilities do
    it "returns no possibilities if there is no and binary operator" do
      ast = ast_from("1")
      possibilities = Mutant::AndOrSwapPossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq false
    end

    it "returns locations for every possible mutation" do
      ast = ast_from("1 && 2; true && false")
      possibilities = Mutant::AndOrSwapPossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq true
      possibilities.locations.size.should eq 2
    end

    it "treats a compound conditional as multiple possibilities" do
      ast = ast_from("1 && 2 && 3")
      possibilities = Mutant::AndOrSwapPossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq true
      possibilities.locations.size.should eq 2
      possibilities.locations.first.name_location.should_not be_nil
      possibilities.locations.last.name_location.should_not be_nil
    end

    it "finds || as well" do
      ast = ast_from("1 || 2")
      possibilities = Mutant::AndOrSwapPossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq true
      possibilities.locations.size.should eq 1
      possibilities.locations.first.name_location.should_not be_nil
    end
  end
end
