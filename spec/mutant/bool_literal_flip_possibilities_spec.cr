require "../../src/crytic/mutant/bool_literal_flip_possibilities"
require "../spec_helper"

module Crytic
  describe Mutant::BoolLiteralFlipPossibilities do
    it "returns no possibilities if there are no bool literals" do
      possibilities = Mutant::BoolLiteralFlipPossibilities.new

      ast_from("1").accept(possibilities)

      possibilities.empty?.should be_true
    end

    it "returns locations for every possible mutation" do
      possibilities = Mutant::BoolLiteralFlipPossibilities.new

      ast_from("true; false;").accept(possibilities)

      possibilities.empty?.should be_false
      possibilities.locations.size.should eq 2
    end
  end
end
