require "../src/crytic/runner"
require "./spec_helper"

describe Crytic do
  describe "with a fully covered subject" do
    it "passes the mutation specs" do
      result = run_crytic("-s ./fixtures/conditionals/fully_covered.cr ./fixtures/conditionals/fully_covered_spec.cr")
      result.output.should contain("✅ ConditionFlip")
      result.output.should contain("✅ BoolLiteralFlip")
      result.output.should contain("3 covered")
      result.exit_code.should eq 0
    end
  end

  describe "with an insufficiently covered subject" do
    it "fails the mutation specs" do
      result = run_crytic("-s ./fixtures/conditionals/fully_covered.cr ./fixtures/conditionals/uncovered_spec.cr")
      result.output.should contain("❌ ConditionFlip")
      result.output.should contain("❌ BoolLiteralFlip")
      result.output.should contain("3 uncovered")
      result.exit_code.should be > 0
    end
  end

  describe "subject without any coverage" do
    it "fails all mutants" do
      result = run_crytic("-s ./fixtures/uncovered/without.cr ./fixtures/uncovered/without_spec.cr")
      result.output.should contain("❌ BoolLiteralFlip")
      result.output.should contain("❌ ConditionFlip")
      result.output.should contain("❌ NumberLiteralSignFlip")
      result.output.should contain("❌ NumberLiteralChange")
      result.output.should contain("9 uncovered")
      result.exit_code.should be > 0
    end
  end

  describe "a failing initial test suite" do
    it "reports initial failure" do
      result = run_crytic("-s ./fixtures/uncovered/without.cr ./fixtures/failing/failing_spec.cr")
      result.output.should contain "❌ Original test suite failed.\n"
      result.output.should contain "no overload matches"
      result.exit_code.should be > 0
    end
  end

  describe "a subject that is be mutated into an endless loop" do
    it "finishes and reports a timed out spec" do
      result = run_crytic("-s ./fixtures/timeout/timeout.cr ./fixtures/timeout/timeout_spec.cr")
      result.output.should contain "✅ Original test suite passed.\n"
      result.output.should contain "1 timeout"
      result.exit_code.should be > 0
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
