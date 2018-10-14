require "spec"
require "../../src/crytic/mutant/bool_literal_flip"

module Crytic
  describe Mutant::BoolLiteralFlip do
    it "flips a boolean" do
      ast = Crystal::Parser.parse("true")
      ast.accept(Mutant::BoolLiteralFlip.at(Crystal::Location.new(
        filename: nil,
        line_number: 1,
        column_number: 1)))
      ast.to_s.should eq "false"
    end

    it "only applies to location" do
      ast = Crystal::Parser.parse("true")
      ast.accept(Mutant::BoolLiteralFlip.at(Crystal::Location.new(
        filename: nil,
        line_number: 100,
        column_number: 100)))
      ast.to_s.should eq "true"
    end
  end
end
