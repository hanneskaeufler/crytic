require "spec"
require "../../src/crytic/mutant/select_reject_swap"

module Crytic
  describe Mutant::SelectRejectSwap do
    it "switches select calls for reject calls" do
      ast = Crystal::Parser.parse("[1].select(&.nil?)")
      transformed = ast.transform(Mutant::SelectRejectSwap.at(Crystal::Location.new(
        filename: nil,
        line_number: 1,
        column_number: 1)))
      transformed.to_s.should eq "[1].reject do |__arg0|\n  __arg0.nil?\nend"
    end

    it "only applies to location" do
      ast = Crystal::Parser.parse("[1].select(&.nil?)")
      transformed = ast.transform(Mutant::SelectRejectSwap.at(Crystal::Location.new(
        filename: nil,
        line_number: 100,
        column_number: 100)))
      transformed.to_s.should eq "[1].select do |__arg0|\n  __arg0.nil?\nend"
    end
  end
end

