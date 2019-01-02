require "../../src/crytic/mutant/any_all_swap"
require "../../src/crytic/mutant/any_all_swap_possibilities"
require "../spec_helper"

module Crytic
  describe Mutant::AnyAllSwap do
    it "switches all? calls for any? calls" do
      ast = Crystal::Parser.parse("[1].all?")
      transformed = ast.transform(Mutant::AnyAllSwap.at(location_at(
        line_number: 1,
        column_number: 1,
        name_column_number: 5)))
      transformed.to_s.should eq "[1].any?"
    end

    it "switches any? calls for all? calls" do
      ast = Crystal::Parser.parse("[1].any?")
      transformed = ast.transform(Mutant::AnyAllSwap.at(location_at(
        line_number: 1,
        column_number: 1,
        name_column_number: 5)))
      transformed.to_s.should eq "[1].all?"
    end

    it "doesn't apply for incorrect row + col" do
      ast = Crystal::Parser.parse("[1].all?")
      transformed = ast.transform(Mutant::AnyAllSwap.at(location_at(
        line_number: 100,
        column_number: 100,
        name_column_number: 5)))
      transformed.to_s.should eq "[1].all?"
    end

    it "doesn't apply for nil name column" do
      ast = Crystal::Parser.parse("[1].all?")
      transformed = ast.transform(Mutant::AnyAllSwap.at(location_at(
        line_number: 1,
        column_number: 1,
        name_column_number: nil)))
      transformed.to_s.should eq "[1].all?"
    end

    it "doesn't apply for other name column" do
      ast = Crystal::Parser.parse("[1].all?")
      transformed = ast.transform(Mutant::AnyAllSwap.at(location_at(
        line_number: 1,
        column_number: 1,
        name_column_number: 6)))
      transformed.to_s.should eq "[1].all?"
    end

    it "can work in chained calls" do
      ast = Crystal::Parser.parse("[1].not_nil!.all?")
      transformed = ast.transform(Mutant::AnyAllSwap.at(location_at(
        line_number: 1,
        column_number: 1,
        name_column_number: 14)))
      transformed.to_s.should eq "[1].not_nil!.any?"
    end
  end
end
