require "../../src/crytic/mutant/any_all_swap"
require "../../src/crytic/mutant/any_all_swap_possibilities"
require "../spec_helper"

module Crytic
  describe Mutant::AnyAllSwap do
    it "switches all? calls for any? calls" do
      ast = Crystal::Parser.parse("[1].all?")
      transformed = ast.transform(Mutant::AnyAllSwap.at(Crystal::Location.new(
        filename: nil,
        line_number: 1,
        column_number: 5)))
      transformed.to_s.should eq "[1].any?"
    end

    it "switches any? calls for all? calls" do
      ast = Crystal::Parser.parse("[1].any?")
      transformed = ast.transform(Mutant::AnyAllSwap.at(Crystal::Location.new(
        filename: nil,
        line_number: 1,
        column_number: 5)))
      transformed.to_s.should eq "[1].all?"
    end

    it "only applies to location" do
      ast = Crystal::Parser.parse("[1].all?")
      transformed = ast.transform(Mutant::AnyAllSwap.at(Crystal::Location.new(
        filename: nil,
        line_number: 100,
        column_number: 100)))
      transformed.to_s.should eq "[1].all?"
    end
  end
end
