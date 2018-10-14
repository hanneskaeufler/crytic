require "spec"
require "../src/crytic/runner"

describe Crytic do
  describe "with a fully covered subject" do
    it "passes the mutation specs" do
      result = run_crytic("-s ./fixtures/simple/bar.cr ./fixtures/simple/bar_spec.cr")
      result.exit_code.should eq 0
      result.output.should contain("✅ ConditionFlip")
      result.output.to_s.should contain("✅ BoolLiteralFlip")
    end
  end

  describe "with an insufficiently covered subject" do
    it "fails the mutation specs" do
      result = run_crytic("-s ./fixtures/conditionals/fully_covered.cr ./fixtures/conditionals/uncovered_spec.cr")
      result.exit_code.should be > 0
      result.output.should contain("❌ BoolLiteralFlip")
      result.output.should contain("❌ ConditionFlip")
    end
  end

  describe "subject without any coverage" do
    it "fails all mutants" do
      result = run_crytic("-s ./fixtures/uncovered/without.cr ./fixtures/uncovered/without_spec.cr")
      result.exit_code.should be > 0
      result.output.should contain("❌ BoolLiteralFlip")
      result.output.should contain("❌ ConditionFlip")
      result.output.should contain("❌ NumberLiteralSignFlip")
      result.output.should contain("❌ NumberLiteralChange")
    end
  end

  describe "a failing initial test suite" do
    it "reports initial failure" do
      result = run_crytic("-s ./fixtures/uncovered/without.cr ./fixtures/failing/failing_spec.cr")
      result.exit_code.should be > 0
      result.output.should eq "❌ Original test suite failed.\n"
    end
  end
end

def run_crytic(args : String)
  io = IO::Memory.new
  result = Process.run("crystal run src/crytic.cr -- #{args}",
                       output: io,
                       error: io,
                       shell: true)
  CryticResult.new(exit_code: result.exit_code, output: io.to_s)
end

record CryticResult, exit_code : Int32, output : String
