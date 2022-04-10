require "../../src/crytic/mutant/number_literal_sign_flip_possibilities"
require "../spec_helper"

module Crytic
  describe Mutant::NumberLiteralSignFlipPossibilities do
    it "returns no possibilities if there are no num literals" do
      ast = ast_from("true")
      possibilities = Mutant::NumberLiteralSignFlipPossibilities.new
      ast.accept(possibilities)
      possibilities.empty?.should be_true
    end

    it "returns locations for every possible mutation" do
      ast = ast_from("1; puts 2")
      possibilities = Mutant::NumberLiteralSignFlipPossibilities.new
      ast.accept(possibilities)
      possibilities.empty?.should be_false
      possibilities.locations.size.should eq 2
    end

    it "doesn't consider 0, makes no sense to sign flip 0" do
      ast = ast_from("0")
      possibilities = Mutant::NumberLiteralSignFlipPossibilities.new
      ast.accept(possibilities)
      possibilities.empty?.should be_true
      possibilities.locations.size.should eq 0
    end

    it "doesn't consider unsigned integer types" do
      ast = ast_from("1_u8; 1_u16; 1_u32; 1_u64; 1_u128;")
      possibilities = Mutant::NumberLiteralSignFlipPossibilities.new
      ast.accept(possibilities)
      possibilities.empty?.should be_true
      possibilities.locations.size.should eq 0
    end
  end
end
