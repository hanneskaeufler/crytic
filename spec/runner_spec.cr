require "spec"
require "../src/crytic/runner"

describe Crytic::Runner do
  describe "with a fully covered subject" do
    it "passes the mutation specs" do
      io = IO::Memory.new
      Crytic::Runner.new(io).run(
        "./spec/fixtures/simple/bar.cr",
        [
          "./spec/fixtures/simple/bar_spec.cr"
        ]
      ).should eq true
      io.to_s.should contain("..")
    end
  end

  describe "with an insufficiently covered subject" do
    it "fails the mutation specs" do
      io = IO::Memory.new
      Crytic::Runner.new(io).run(
        "./spec/fixtures/conditionals/fully_covered.cr",
        [
          "./spec/fixtures/conditionals/uncovered_spec.cr"
        ]
      ).should eq true
      io.to_s.should contain("F")
    end
  end
end
