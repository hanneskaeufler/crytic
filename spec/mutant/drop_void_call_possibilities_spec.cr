require "../../src/crytic/mutant/drop_void_call_possibilities"
require "../spec_helper.cr"

module Crytic
  describe Mutant::DropVoidCallPossibilities do
    it "marks calls in a nil returning method" do
      ast = ast_from(<<-CODE
        def voidfn : Nil
          markme
        end
        CODE
      )
      possibilities = Mutant::DropVoidCallPossibilities.new

      ast.accept(possibilities)

      possibilities.any?.should eq true
      possibilities.locations.size.should eq 1
      possibilities.locations.first.line_number.should eq 2
    end

    it "doesn't mark calls inside non-void defs" do
      ast = ast_from(<<-CODE
        def intreturning; 1; end
        def notvoid : Int
          intreturning
        end
        CODE
      )
      possibilities = Mutant::DropVoidCallPossibilities.new

      ast.accept(possibilities)

      possibilities.any?.should eq false
      possibilities.locations.size.should eq 0
    end
  end
end
