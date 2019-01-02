require "../../src/crytic/mutant/regex_literal_change"
require "../spec_helper"

module Crytic
  describe Mutant::RegexLiteralChange do
    it "changes the regexp to something constant" do
      ast = Crystal::Parser.parse("/.*/")
      ast.accept(Mutant::RegexLiteralChange.at(location_at(
        line_number: 1,
        column_number: 1)))
      ast.to_s.should eq "/a^/"
    end

    it "only applies to location" do
      ast = Crystal::Parser.parse("/a/")
      ast.accept(Mutant::RegexLiteralChange.at(location_at(
        line_number: 100,
        column_number: 100)))
      ast.to_s.should eq "/a/"
    end
  end
end
