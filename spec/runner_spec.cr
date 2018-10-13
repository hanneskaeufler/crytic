require "spec"
require "../src/crytic/runner"

describe Crytic::Runner do
  describe "with a fully covered subject" do
    it "passes the mutation specs" do
      io = IO::Memory.new
      Crytic::Runner.new(io).run(
        "./fixtures/simple/bar.cr",
        [
          "./fixtures/simple/bar_spec.cr"
        ]
      ).should eq true
      io.to_s.should contain("✅ ConditionFlip")
      io.to_s.should contain("✅ BoolLiteralFlip")
    end
  end

  describe "with an insufficiently covered subject" do
    it "fails the mutation specs" do
      io = IO::Memory.new
      Crytic::Runner.new(io).run(
        "./fixtures/conditionals/fully_covered.cr",
        [
          "./fixtures/conditionals/uncovered_spec.cr"
        ]
      ).should eq false
      io.to_s.should contain("❌ BoolLiteralFlip")
      io.to_s.should contain("❌ ConditionFlip")
    end
  end

  describe "subject without any coverage" do
    it "fails all mutants" do
      io = IO::Memory.new
      Crytic::Runner.new(io).run(
        "./fixtures/uncovered/without.cr",
        [
          "./fixtures/uncovered/without_spec.cr"
        ]
      ).should eq false
      io.to_s.should contain("❌ BoolLiteralFlip")
      io.to_s.should contain("❌ ConditionFlip")
      io.to_s.should contain("❌ NumberLiteralSignFlip")
      io.to_s.should contain("❌ NumberLiteralChange")
    end
  end
end
