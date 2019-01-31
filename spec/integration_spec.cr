require "../src/crytic/runner"
require "./fake_generator"
require "./fake_reporter"
require "./spec_helper"

{% unless flag?("skip-integration") %}
describe Crytic do
  describe "--help/-h" do
    it "prints usage info" do
      result = run_crytic("--help")
      result.output.should contain("Usage: crytic [arguments]")
      result.exit_code.should eq 0
      result = run_crytic("-h")
      result.output.should contain("Usage: crytic [arguments]")
      result.exit_code.should eq 0
    end
  end

  describe "--preamble/-p" do
    it "injects the given custom preamble, failing=covering all mutants that would otherwise be uncovered" do
      result = run_crytic("-s ./fixtures/conditionals/fully_covered.cr ./fixtures/conditionals/uncovered_spec.cr -p 'exit 1'")
      result.output.should contain("✅ ConditionFlip")
      result.output.should contain("✅ BoolLiteralFlip")
      result.exit_code.should eq 0
    end
  end

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

    it "exits successfully when the msi threshold is set sufficiently" do
      result = run_crytic("--min-msi=0.0 -s ./fixtures/conditionals/fully_covered.cr ./fixtures/conditionals/uncovered_spec.cr")
      result.exit_code.should eq 0
    end
  end

  describe "without passing a subject or tests" do
    it "mutates all sources and runs all tests" do
      result = run_crytic_in_dir("./fixtures/autofind")
      result.output.should contain("✅ ConditionFlip")
      result.output.should contain("✅ BoolLiteralFlip")
      result.output.should contain("✅ NumberLiteralSignFlip")
      result.output.should contain("✅ NumberLiteralChange")
      result.output.should contain("❌ NumberLiteralSignFlip")
      result.output.should contain("❌ NumberLiteralChange")
      result.output.should contain("2 uncovered")
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

  describe "a subject that is mutated into an endless loop" do
    it "finishes and reports a timed out spec" do
      result = run_crytic("-s ./fixtures/timeout/timeout.cr ./fixtures/timeout/timeout_spec.cr")
      result.output.should contain "✅ Original test suite passed.\n"
      result.output.should contain "1 timeout"
      result.exit_code.should be > 0
    end
  end
end
{% end %}

def run_crytic_in_dir(dir : String)
  io = IO::Memory.new
  result = Process.run("cd #{dir} && crystal run ../../src/crytic.cr",
    output: io,
    error: io,
    shell: true,
    env: clean_env)
  CryticResult.new(exit_code: result.exit_code, output: io.to_s)
end

def run_crytic(args : String)
  io = IO::Memory.new
  result = Process.run("crystal run src/crytic.cr -- #{args}",
    output: io,
    error: io,
    shell: true,
    env: clean_env)
  CryticResult.new(exit_code: result.exit_code, output: io.to_s)
end

# Because our own CI sets the stryker dashboard api key and then runs those specs,
# this would lead to a wrong mutation score being submitted when running the integration
# specs. However, only the actual _mutation-test_ job must submit the score.
# Pass an empty api key to avoid overriding.
def clean_env
  {"STRYKER_DASHBOARD_API_KEY" => ""}
end

record CryticResult, exit_code : Int32, output : String
