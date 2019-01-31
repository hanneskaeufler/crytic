require "../../src/crytic/mutant/noop"
require "../spec_helper"

module Crytic::Mutant
  describe Noop do
    it "doesn't mutate the code at all" do
      ast = Crystal::Parser.parse("1")

      ast.accept(Noop.at(location_at(0, 0)))

      ast.to_s.should eq "1"
    end
  end
end
