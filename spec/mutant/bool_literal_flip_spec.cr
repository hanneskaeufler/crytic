require "../../src/crytic/mutant/bool_literal_flip"
require "../spec_helper"

module Crytic
  describe Mutant::BoolLiteralFlip do
    it "flips a boolean" do
      ast = ast_from("true")
      ast.accept(Mutant::BoolLiteralFlip.at(location_at(
        line_number: 1,
        column_number: 1)))
      ast.to_s.should eq "false"
    end

    it "only applies to location" do
      ast = ast_from("true")
      ast.accept(Mutant::BoolLiteralFlip.at(location_at(
        line_number: 100,
        column_number: 100)))
      ast.to_s.should eq "true"
    end
  end
end
