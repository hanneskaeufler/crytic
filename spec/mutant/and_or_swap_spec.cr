require "../../src/crytic/mutant/and_or_swap"
require "../spec_helper"

module Crytic
  describe Mutant::AndOrSwap do
    it "swaps and for or" do
      ast = Crystal::Parser.parse("1 && 2")
      transformed = ast.transform(Mutant::AndOrSwap.at(location_at(
        line_number: 1,
        column_number: 1,
        name_location: Crystal::Location.new(nil, 1, 6))))
      transformed.to_s.should eq "1 || 2"
    end

    it "swaps or for and" do
      ast = Crystal::Parser.parse("1 || 2")
      transformed = ast.transform(Mutant::AndOrSwap.at(location_at(
        line_number: 1,
        column_number: 1,
        name_location: Crystal::Location.new(nil, 1, 6))))
      transformed.to_s.should eq "1 && 2"
    end

    it "only applies to location" do
      ast = Crystal::Parser.parse("1 && 2")
      transformed = ast.transform(Mutant::AndOrSwap.at(location_at(
        line_number: 100,
        column_number: 100,
        name_location: Crystal::Location.new(nil, 1, 6))))
      transformed.to_s.should eq "1 && 2"
    end

    it "only flips one at a time" do
      ast = Crystal::Parser.parse("1 && 2 && 3")
      transformed = ast.transform(Mutant::AndOrSwap.at(location_at(
        line_number: 1,
        column_number: 1,
        name_location: Crystal::Location.new(nil, 1, 6))))
      transformed.to_s.should eq "(1 || 2) && 3"
    end
  end
end
