require "../../src/crytic/mutant/symbol_literal_change_possibilities"
require "../spec_helper"

module Crytic::Mutant
  describe SymbolLiteralChangePossibilities do
    it "returns no possibilities if there are no symbol literals" do
      possibilities = SymbolLiteralChangePossibilities.new

      ast_from("a = 1; a.to_s").accept(possibilities)

      possibilities.empty?.should be_true
    end

    it "marks any and all symbol literals" do
      possibilities = SymbolLiteralChangePossibilities.new

      ast_from(<<-CODE
        :foo
        :bar.to_s
        method(:baz)
      CODE
      ).accept(possibilities)

      possibilities.empty?.should be_false
      possibilities.locations.size.should eq 3
      possibilities.locations.last.line_number.should eq 3
      possibilities.locations.last.column_number.should eq 10
    end
  end
end
