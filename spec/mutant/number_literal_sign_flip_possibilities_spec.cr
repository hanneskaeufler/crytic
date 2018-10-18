require "spec"
require "../../src/crytic/mutant/number_literal_sign_flip_possibilities"

module Crytic
  describe Mutant::NumberLiteralSignFlipPossibilities do
    it "returns no possibilities if there are no num literals" do
      ast = Crystal::Parser.parse("true")
      possibilities = Mutant::NumberLiteralSignFlipPossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq false
    end

    it "returns locations for every possible mutation" do
      ast = Crystal::Parser.parse("1; puts 2")
      possibilities = Mutant::NumberLiteralSignFlipPossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq true
      possibilities.locations.size.should eq 2
    end

    it "doesn't consider 0, makes no sense to sign flip 0" do
      ast = Crystal::Parser.parse("0")
      possibilities = Mutant::NumberLiteralSignFlipPossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq false
      possibilities.locations.size.should eq 0
    end
  end
end
