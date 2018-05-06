require "spec"
require "../src/fizz_buzz"

describe "#fizz_buzz" do
  it "returns the number" do
    fizz_buzz(99).should eq(99)
  end
end
