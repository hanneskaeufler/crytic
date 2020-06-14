require "../../src/crytic/mutant/drop_call_in_void_def_possibilities"
require "../spec_helper.cr"

module Crytic
  describe Mutant::DropCallInVoidDefPossibilities do
    it "marks calls in a nil returning method" do
      ast = ast_from(<<-CODE
        def voidfn : Nil
          markme
        end
        CODE
      )
      possibilities = Mutant::DropCallInVoidDefPossibilities.new

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
      possibilities = Mutant::DropCallInVoidDefPossibilities.new

      ast.accept(possibilities)

      possibilities.any?.should eq false
    end

    it "marks a possibility for each method call in the void def" do
      ast = ast_from(<<-CODE
        def intreturning; 1; end
        def voidfn : Nil
          intreturning
          intreturning
        end
        CODE
      )
      possibilities = Mutant::DropCallInVoidDefPossibilities.new

      ast.accept(possibilities)

      possibilities.locations.size.should eq 2
    end

    it "doesn't mess with local variable declarations" do
      ast = ast_from(<<-CODE
        def generate(a); a; end
        def voidfn : Nil
          foo = 1
          bar = "2".to_i
          bar = [generate(2)].map(&.to_s)
        end
        CODE
      )
      possibilities = Mutant::DropCallInVoidDefPossibilities.new

      ast.accept(possibilities)

      possibilities.any?.should eq false
    end
  end
end
