require "../src/crytic/mutant/and_or_swap"
require "../src/crytic/mutant/number_literal_change"
require "../src/crytic/source"
require "./spec_helper"

module Crytic
  describe Source do
    describe "#original_source" do
      it "returns the original, but parsed source" do
        source = Source.new(source: "puts \"hi\"")
        source.original_source.should eq "puts(\"hi\")"
      end
    end

    describe "#mutated_source" do
      it "returns the mutated source for transformer mutants" do
        mutant = Mutant::AndOrSwap.at(location_at(
          line_number: 1,
          column_number: 1))

        source = Source.new(source: "1 && 2")
        source.mutated_source(mutant).should eq "1 || 2"
      end

      it "returns the mutated source code for visitor mutants" do
        mutant = Mutant::NumberLiteralChange.at(location_at(
          line_number: 1,
          column_number: 1))

        source = Source.new(source: "1")
        source.mutated_source(mutant).should eq "0"
      end
    end
  end
end
