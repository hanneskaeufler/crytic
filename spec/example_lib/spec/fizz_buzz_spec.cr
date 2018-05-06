require "spec"
require "../src/fizz_buzz"

describe FizzBuzz do
  it "returns the number" do
    FizzBuzz.new.call(99).should eq(99)
  end
end
