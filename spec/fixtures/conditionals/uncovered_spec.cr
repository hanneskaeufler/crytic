require "spec"
require "./fully_covered"

describe "uncovered" do
  it "does not fully cover the code" do
    fully_covered(true).should eq(true)
  end
end
