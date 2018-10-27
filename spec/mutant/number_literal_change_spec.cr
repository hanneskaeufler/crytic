require "../../src/crytic/mutant/number_literal_change"
require "../spec_helper"

module Crytic
  describe Mutant::NumberLiteralChange do
    it "changes the value of a number literal at the given location" do
      ast = Crystal::Parser.parse("1; 2;")
      ast.accept(Mutant::NumberLiteralChange.at(Crystal::Location.new(
        filename: nil,
        line_number: 1,
        column_number: 4)))
      ast.to_s.should eq "1\n12\n"
    end

    it "only applies to location" do
      ast = Crystal::Parser.parse("1; 2;")
      ast.accept(Mutant::NumberLiteralChange.at(Crystal::Location.new(
        filename: nil,
        line_number: 100,
        column_number: 100)))
      ast.to_s.should eq "1\n2\n"
    end
  end
end
