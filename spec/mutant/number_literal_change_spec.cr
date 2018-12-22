require "../../src/crytic/mutant/number_literal_change"
require "../spec_helper"

module Crytic
  describe Mutant::NumberLiteralChange do
    {% for mute in [
                     {code: "1; 2;", expected: "1\n0\n"},
                     {code: "1; 1;", expected: "1\n0\n"},
                     {code: "1; -10;", expected: "1\n0\n"},
                     {code: "1; 1337;", expected: "1\n0\n"},
                   ] %}
      it "changes anything to zero: {{ mute[:code].id }}" do
        ast = Crystal::Parser.parse({{ mute[:code] }})
        ast.accept(Mutant::NumberLiteralChange.at(Crystal::Location.new(
          filename: nil,
          line_number: 1,
          column_number: 4)))
        ast.to_s.should eq {{ mute[:expected] }}
      end
    {% end %}

    it "changes zero to 1" do
      ast = Crystal::Parser.parse("0")
      ast.accept(Mutant::NumberLiteralChange.at(Crystal::Location.new(
        filename: nil,
        line_number: 1,
        column_number: 1)))
      ast.to_s.should eq "1"
    end

    it "only applies to location" do
      ast = Crystal::Parser.parse("1; 2;")
      ast.accept(Mutant::NumberLiteralChange.at(Crystal::Location.new(
        filename: nil,
        line_number: 100,
        column_number: 100)))
      ast.to_s.should eq "1\n2\n"
    end
  end
end
