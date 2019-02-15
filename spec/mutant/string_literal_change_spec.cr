require "../../src/crytic/mutant/string_literal_change"
require "../spec_helper"

module Crytic
  describe Mutant::StringLiteralChange do
    it "changes to the empty string for non-empty strings" do
      ast = Crystal::Parser.parse("\"hi there\"")
      ast.accept(Mutant::StringLiteralChange.at(location_at(
        line_number: 1,
        column_number: 1)))
      ast.to_s.should eq "\"\""
    end

    it "changes empty strings to __crytic__" do
      ast = Crystal::Parser.parse("\"\"")
      ast.accept(Mutant::StringLiteralChange.at(location_at(
        line_number: 1,
        column_number: 1)))
      ast.to_s.should eq "\"__crytic__\""
    end

    it "only applies to location" do
      ast = Crystal::Parser.parse("\"hi there\"")
      ast.accept(Mutant::StringLiteralChange.at(location_at(
        line_number: 100,
        column_number: 100)))
      ast.to_s.should eq "\"hi there\""
    end
  end
end
