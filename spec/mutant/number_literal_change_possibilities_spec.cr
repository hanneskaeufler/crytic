require "spec"
require "../../src/crytic/mutant/number_literal_change_possibilities"

module Crytic
  describe Mutant::NumberLiteralChangePossibilities do
    it "returns no possibilities if there are no num literals" do
      ast = Crystal::Parser.parse("true")
      possibilities = Mutant::NumberLiteralChangePossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq false
    end

    it "returns locations for every possible mutation" do
      ast = Crystal::Parser.parse("1; puts 2")
      possibilities = Mutant::NumberLiteralChangePossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq true
      possibilities.locations.size.should eq 2
    end
  end
end