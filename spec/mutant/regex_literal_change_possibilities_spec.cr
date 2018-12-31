require "../../src/crytic/mutant/regex_literal_change_possibilities"
require "../spec_helper"

module Crytic
  describe Mutant::RegexLiteralChangePossibilities do
    it "returns no possibilities if there are no regex literals" do
      ast = Crystal::Parser.parse("true")
      possibilities = Mutant::RegexLiteralChangePossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq false
    end

    it "returns locations for every possible mutation" do
      ast = Crystal::Parser.parse("/.*/")
      possibilities = Mutant::RegexLiteralChangePossibilities.new
      ast.accept(possibilities)
      possibilities.any?.should eq true
      possibilities.locations.size.should eq 1
    end
  end
end
