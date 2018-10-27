require "../../src/crytic/mutant/and_or_swap"
require "../spec_helper"

module Crytic
  describe Mutant::AndOrSwap do
    it "swaps and for or" do
      ast = Crystal::Parser.parse("1 && 2")
      transformed = ast.transform(Mutant::AndOrSwap.at(Crystal::Location.new(
        filename: nil,
        line_number: 1,
        column_number: 1)))
      transformed.to_s.should eq "1 || 2"
    end

    it "only applies to location" do
      ast = Crystal::Parser.parse("1 && 2")
      transformed = ast.transform(Mutant::AndOrSwap.at(Crystal::Location.new(
        filename: nil,
        line_number: 100,
        column_number: 100)))
      transformed.to_s.should eq "1 && 2"
    end
  end
end
