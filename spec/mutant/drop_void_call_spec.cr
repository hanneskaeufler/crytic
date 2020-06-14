require "../../src/crytic/mutant/drop_void_call"
require "../spec_helper.cr"

module Crytic
  describe Mutant::DropVoidCall do
    it "simply replaces a void function call with a Nil literal" do
      ast = ast_from("dropme")

      transformed = ast.transform(Mutant::DropVoidCall.at(location_at(
        line_number: 1,
        column_number: 1)))

      transformed.to_s.should eq "nil"
    end

    it "doesn't replace for the wrong possibility" do
      ast = ast_from("dontdropme")

      transformed = ast.transform(Mutant::DropVoidCall.at(location_at(
        line_number: 2,
        column_number: 4)))

      transformed.to_s.should eq "dontdropme"
    end
  end
end
