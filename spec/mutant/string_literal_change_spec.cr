require "../../src/crytic/mutant/string_literal_change"
require "../spec_helper"

module Crytic
  describe Mutant::StringLiteralChange do
    it "changes to the empty string for non-empty strings" do
      ast = ast_from("\"hi there\"")
      ast.accept(Mutant::StringLiteralChange.at(location_at(
        line_number: 1,
        column_number: 1)))
      ast.to_s.should eq "\"\""
    end

    it "changes empty strings to __crytic__" do
      ast = ast_from("\"\"")
      ast.accept(Mutant::StringLiteralChange.at(location_at(
        line_number: 1,
        column_number: 1)))
      ast.to_s.should eq "\"__crytic__\""
    end

    it "only applies to location" do
      ast = ast_from("\"hi there\"")
      ast.accept(Mutant::StringLiteralChange.at(location_at(
        line_number: 100,
        column_number: 100)))
      ast.to_s.should eq "\"hi there\""
    end
  end
end
