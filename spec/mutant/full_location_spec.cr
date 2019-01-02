require "../spec_helper.cr"
require "compiler/crystal/syntax/*"

module Crytic::Mutant
  describe FullLocation do
    it "delegates line_number and column_number" do
      location = Crystal::Location.new(nil, 1, 2)
      full = FullLocation.new(location)

      full.line_number.should eq 1
      full.column_number.should eq 2
    end

    describe "#name_column_number" do
      it "is nil by default" do
        location = Crystal::Location.new(nil, 1, 2)
        full = FullLocation.new(location)

        full.name_column_number.should be_nil
      end
    end
  end
end
