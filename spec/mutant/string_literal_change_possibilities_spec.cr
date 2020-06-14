require "../../src/crytic/mutant/string_literal_change_possibilities"
require "../spec_helper"

module Crytic
  describe Mutant::StringLiteralChangePossibilities do
    it "returns no possibilities if there are no string literals" do
      possibilities = Mutant::StringLiteralChangePossibilities.new

      ast_from("1").accept(possibilities)

      possibilities.any?.should eq false
    end

    it "returns locations for every possible mutation" do
      ast = ast_from("\"hi\"; \"there\";")
      possibilities = Mutant::StringLiteralChangePossibilities.new

      ast.accept(possibilities)

      possibilities.any?.should eq true
      possibilities.locations.size.should eq 2
    end
  end
end
