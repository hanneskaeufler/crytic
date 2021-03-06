require "../../src/crytic/mutant/select_reject_swap_possibilities"
require "../spec_helper"

module Crytic
  describe Mutant::SelectRejectSwapPossibilities do
    it "returns no possibilities if there is no method call at all" do
      possibilities = Mutant::SelectRejectSwapPossibilities.new

      ast_from("1").accept(possibilities)

      possibilities.empty?.should be_true
    end

    it "returns no possibilities if there is no select call" do
      possibilities = Mutant::SelectRejectSwapPossibilities.new

      ast_from("puts 2").accept(possibilities)

      possibilities.empty?.should be_true
    end

    it "returns locations for every possible mutation" do
      ast = ast_from("[1].select(&.nil?); [1].reject(&.nil?)")
      possibilities = Mutant::SelectRejectSwapPossibilities.new
      ast.accept(possibilities)
      possibilities.empty?.should be_false
      possibilities.locations.size.should eq 2
      possibilities.locations.first.line_number.should eq 1
      possibilities.locations.first.column_number.should eq 1
      possibilities.locations.first.name_location.try(&.column_number).should eq 5
    end
  end
end
