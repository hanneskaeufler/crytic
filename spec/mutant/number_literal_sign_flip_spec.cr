require "../../src/crytic/mutant/number_literal_sign_flip"
require "../spec_helper"

module Crytic
  describe Mutant::NumberLiteralSignFlip do
    it "flips the sign of a literal" do
      ast = Crystal::Parser.parse("1")
      ast.accept(Mutant::NumberLiteralSignFlip.at(Crystal::Location.new(
        filename: nil,
        line_number: 1,
        column_number: 1)))
      ast.to_s.should eq "-1"
    end

    it "only applies to location" do
      ast = Crystal::Parser.parse("1")
      ast.accept(Mutant::NumberLiteralSignFlip.at(Crystal::Location.new(
        filename: nil,
        line_number: 100,
        column_number: 100)))
      ast.to_s.should eq "1"
    end
  end
end
