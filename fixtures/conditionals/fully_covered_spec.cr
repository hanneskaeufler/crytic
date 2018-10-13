require "spec"
require "./fully_covered"

describe "fully_covered" do
  it "is fully covered" do
    fully_covered(true).should eq(true)
    fully_covered(false).should eq(false)
  end
end
