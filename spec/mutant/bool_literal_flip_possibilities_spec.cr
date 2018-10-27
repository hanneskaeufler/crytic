require "../../src/crytic/mutant/bool_literal_flip_possibilities"
require "../spec_helper"

module Crytic
  describe Mutant::BoolLiteralFlipPossibilities do
    it "returns no possibilities if there are no bool literals" do
      ast = Crystal::Parser.parse("1")
      possibilities = Mutant::BoolLiteralFlipPossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq false
    end

    it "returns locations for every possible mutation" do
      ast = Crystal::Parser.parse("true; false;")
      possibilities = Mutant::BoolLiteralFlipPossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq true
      possibilities.locations.size.should eq 2
    end
  end
end
