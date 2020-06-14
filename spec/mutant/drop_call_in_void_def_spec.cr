require "../../src/crytic/mutant/drop_call_in_void_def"
require "../spec_helper.cr"

module Crytic
  describe Mutant::DropCallInVoidDef do
    it "simply replaces a void function call with a Nil literal" do
      ast = ast_from("dropme")

      transformed = ast.transform(Mutant::DropCallInVoidDef.at(location_at(
        line_number: 1,
        column_number: 1)))

      transformed.to_s.should eq "nil"
    end

    it "doesn't replace for the wrong possibility" do
      ast = ast_from("dontdropme")

      transformed = ast.transform(Mutant::DropCallInVoidDef.at(location_at(
        line_number: 2,
        column_number: 4)))

      transformed.to_s.should eq "dontdropme"
    end
  end
end
