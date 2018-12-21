require "../../src/crytic/mutant/any_all_swap"
require "../../src/crytic/mutant/any_all_swap_possibilities"
require "../spec_helper"

module Crytic
  describe Mutant::AnyAllSwap do
    it "switches all? calls for any? calls" do
      ast = Crystal::Parser.parse("[1].all?")
      transformed = ast.transform(Mutant::AnyAllSwap.at(Crystal::Location.new(
        filename: nil,
        line_number: 1,
        column_number: 5)))
      transformed.to_s.should eq "[1].any?"
    end

    it "only applies to location" do
      ast = Crystal::Parser.parse("[1].all?")
      transformed = ast.transform(Mutant::AnyAllSwap.at(Crystal::Location.new(
        filename: nil,
        line_number: 100,
        column_number: 100)))
      transformed.to_s.should eq "[1].all?"
    end

    # pending "works together with the possibility" do
    #   ast = Crystal::Parser.parse(<<-CODE
    #   MUTANT_POSSIBILITIES.map do |inspector|
    #     ast.accept(inspector)
    #     inspector
    #   end.select(&.any?).map do |inspector|
    #     inspector.locations.map do |location|
    #       Mutation::Mutation.with(mutant: inspector.mutant_class.at(location: location), original: source, specs: specs)
    #     end
    #   end.flatten
    #   CODE
    #   )
    #   possibilities = Mutant::SelectRejectSwapPossibilities.new
    #   ast.accept(possibilities)
    #   mutant = Mutant::SelectRejectSwap.at(possibilities.locations.first)
    #   transformed = ast.transform(mutant)
    #   transformed.to_s.should eq <<-CODE
    #   MUTANT_POSSIBILITIES.map do |inspector|
    #     ast.accept(inspector)
    #     inspector
    #   end.reject(&.any?).map do |inspector|
    #     inspector.locations.map do |location|
    #       Mutation::Mutation.with(mutant: inspector.mutant_class.at(location: location), original: source, specs: specs)
    #     end
    #   end.flatten
    #   CODE
    # end
  end
end
