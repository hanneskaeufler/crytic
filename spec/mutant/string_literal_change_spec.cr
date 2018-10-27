require "../../src/crytic/mutant/string_literal_change"
require "../spec_helper"

module Crytic
  describe Mutant::StringLiteralChange do
    it "appends to string litereals" do
      ast = Crystal::Parser.parse("\"hi there\"")
      ast.accept(Mutant::StringLiteralChange.at(Crystal::Location.new(
        filename: nil,
        line_number: 1,
        column_number: 1)))
      ast.to_s.should eq "\"hi there__crytic__\""
    end

    it "only applies to location" do
      ast = Crystal::Parser.parse("\"hi there\"")
      ast.accept(Mutant::StringLiteralChange.at(Crystal::Location.new(
        filename: nil,
        line_number: 100,
        column_number: 100)))
      ast.to_s.should eq "\"hi there\""
    end
  end
end
