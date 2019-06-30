require "../../src/crytic/mutant/any_all_swap"
require "../../src/crytic/mutant/any_all_swap_possibilities"
require "../spec_helper"

module Crytic
  describe Mutant::AnyAllSwap do
    it "switches all? calls for any? calls" do
      ast = ast_from("[1].all?")
      transformed = ast.transform(Mutant::AnyAllSwap.at(location_at(
        line_number: 1,
        column_number: 1,
        name_location: Crystal::Location.new(nil, 1, 5))))
      transformed.to_s.should eq "[1].any?"
    end

    it "switches any? calls for all? calls" do
      ast = ast_from("[1].any?")
      transformed = ast.transform(Mutant::AnyAllSwap.at(location_at(
        line_number: 1,
        column_number: 1,
        name_location: Crystal::Location.new(nil, 1, 5))))
      transformed.to_s.should eq "[1].all?"
    end

    it "doesn't apply for incorrect row + col" do
      ast = ast_from("[1].all?")
      transformed = ast.transform(Mutant::AnyAllSwap.at(location_at(
        line_number: 100,
        column_number: 100,
        name_location: Crystal::Location.new(nil, 1, 5))))
      transformed.to_s.should eq "[1].all?"
    end

    it "doesn't apply for other name column" do
      ast = ast_from("[1].all?")
      transformed = ast.transform(Mutant::AnyAllSwap.at(location_at(
        line_number: 1,
        column_number: 1,
        name_location: Crystal::Location.new(nil, 1, 6))))
      transformed.to_s.should eq "[1].all?"
    end

    it "can work in chained calls" do
      ast = ast_from("[1].not_nil!.all?")
      transformed = ast.transform(Mutant::AnyAllSwap.at(location_at(
        line_number: 1,
        column_number: 1,
        name_location: Crystal::Location.new(nil, 1, 14))))
      transformed.to_s.should eq "[1].not_nil!.any?"
    end

    it "works together with the possibility" do
      code = <<-CODE
      class Bar
        private def unfold_required(output)
          output.gsub(/require[ \t]+\"\$([0-9]+)\"/) do |_str, matcher|
            expansion_id = matcher[1].to_i
            file_list = InjectMutatedSubjectIntoSpecs.require_expanders[expansion_id]
            if file_list.any?
              String.build do |io|
                file_list.each do |file|
                  puts(file)
                end
              end
            else
              ""
            end
          end
        end
      end
      CODE
      ast = ast_from(code)

      possibilities = Mutant::AnyAllSwapPossibilities.new
      ast.accept(possibilities)
      mutant = Mutant::AnyAllSwap.at(possibilities.locations.first)
      mutated_code = ast_from(code).transform(mutant)
      expected = code.to_s.gsub("any?", "all?")
      mutated_code.to_s.should eq expected
    end
  end
end
