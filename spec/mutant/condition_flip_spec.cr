require "spec"
require "../../src/crytic/mutant/condition_flip"

module Crytic
  describe Mutant::ConditionFlip do
    it "flips the branches" do
      ast = Crystal::Parser.parse("if true 1; else 2; end")
      ast.accept(Mutant::ConditionFlip.at(Crystal::Location.new(
        filename: nil,
        line_number: 1,
        column_number: 1)))
      ast.to_s.should eq <<-AST
      if true
        2
      else
        1
      end
      AST
    end

    it "only applies to location" do
      ast = Crystal::Parser.parse("if true 1; else 2; end")
      ast.accept(Mutant::ConditionFlip.at(Crystal::Location.new(
        filename: nil,
        line_number: 100,
        column_number: 100)))
      ast.to_s.should eq <<-AST
      if true
        1
      else
        2
      end
      AST
    end
  end
end
