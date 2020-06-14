require "../../src/crytic/mutant/number_literal_change_possibilities"
require "../spec_helper"

module Crytic
  describe Mutant::NumberLiteralChangePossibilities do
    it "returns no possibilities if there are no num literals" do
      ast = ast_from("true")
      possibilities = Mutant::NumberLiteralChangePossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq false
    end

    it "returns locations for every possible mutation" do
      ast = ast_from("1; puts 2")
      possibilities = Mutant::NumberLiteralChangePossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq true
      possibilities.locations.size.should eq 2
    end
  end
end
