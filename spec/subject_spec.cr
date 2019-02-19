require "../src/crytic/mutant/and_or_swap"
require "../src/crytic/mutant/number_literal_change"
require "../src/crytic/subject"
require "./spec_helper"

module Crytic
  def self.number_literal_change
    Mutant::NumberLiteralChange.at(location_at(
      line_number: 1,
      column_number: 1))
  end

  describe Subject do
    describe "#mutated" do
      it "returns the mutated source for transformer mutants" do
        mutant = Mutant::AndOrSwap.at(location_at(
          line_number: 1,
          column_number: 1))

        mutated = Subject.new(source: "1 && 2").mutated(mutant)
        mutated.source_code.should eq "1 || 2"
      end

      it "returns the mutated source code for visitor mutants" do
        mutated = Subject.new(source: "1").mutated(number_literal_change)
        mutated.source_code.should eq "0"
      end

      it "forwards the original code" do
        mutated = Subject.new(source: "1").mutated(number_literal_change)
        mutated.diff.should eq Crytic::Diff.unified_diff("1", "0")
      end

      it "doesn't mutate the original ast for visitor mutants" do
        subject = Subject.new(source: "1")
        subject.mutated(number_literal_change)
        applied_mutant_twice = subject.mutated(number_literal_change)
        applied_mutant_twice.source_code.should eq "0"
      end
    end
  end
end
