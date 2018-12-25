require "../../src/crytic/mutant/regexp_literal_change_possibilities"
require "../spec_helper"

module Crytic
  describe Mutant::RegexpLiteralChangePossibilities do
    it "returns no possibilities if there are no regexp literals" do
      ast = Crystal::Parser.parse("true")
      possibilities = Mutant::RegexpLiteralChangePossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq false
    end

    it "returns locations for every possible mutation" do
      ast = Crystal::Parser.parse("/.*/")
      possibilities = Mutant::RegexpLiteralChangePossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq true
      possibilities.locations.size.should eq 1
    end
  end
end
