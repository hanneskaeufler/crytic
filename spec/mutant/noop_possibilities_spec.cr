require "../../src/crytic/mutant/noop"
require "../../src/crytic/mutant/noop_possibilities"
require "../spec_helper"

module Crytic::Mutant
  describe NoopPossibilities do
    it "returns 1 possibility per subject" do
      ast = Crystal::Parser.parse("1")
      subject = NoopPossibilities.new

      ast.accept(subject)

      subject.locations.size.should eq 1
      subject.any?.should eq true
    end

    describe "#mutant_class" do
      it "returns the noop mutant" do
        NoopPossibilities.new.mutant_class.should eq Noop
      end
    end
  end
end
