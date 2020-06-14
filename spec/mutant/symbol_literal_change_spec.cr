require "../spec_helper"

module Crytic::Mutant
  describe SymbolLiteralChange do
    it "prefixes the symbol" do
      ast = ast_from(":sym")

      ast.accept(SymbolLiteralChange.at(location_at(
        line_number: 1,
        column_number: 1
      )))

      ast.to_s.should eq ":__crytic__sym"
    end

    it "doesn't touch symbols at other locations" do
      ast = ast_from(":sym")

      ast.accept(SymbolLiteralChange.at(location_at(
        line_number: 2,
        column_number: 1
      )))

      ast.to_s.should eq ":sym"
    end
  end
end
