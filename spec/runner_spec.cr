require "../src/crytic/runner"
require "./spec_helper"

describe Crytic::Runner do
  describe "#run" do
    it "raises for empty specs" do
      expect_raises(ArgumentError) do
        Crytic::Runner.new.run("", [] of String)
      end
    end

    it "raises for non-existent files" do
      expect_raises(ArgumentError) do
        Crytic::Runner.new.run("./nope.cr", ["./nope_spec.cr"])
      end
      expect_raises(ArgumentError) do
        Crytic::Runner.new.run("./fixtures/simple/bar.cr", ["./nope_spec.cr"])
      end
    end

    it "reports events in order" do
      reporter = FakeReporter.new
      runner = Crytic::Runner.new(
        generator: FakeGenerator.new,
        reporters: [reporter] of Crytic::Reporter::Reporter)

      runner.run("./fixtures/simple/bar.cr", ["./fixtures/simple/bar_spec.cr"])

      reporter.events.should eq ["report_original_result", "report_summary", "report_msi"]
    end
  end
end

private class FakeReporter < Crytic::Reporter::Reporter
  getter events
  @events = [] of String

  def report_original_result(original_result)
    @events << "report_original_result"
  end

  def report_result(result)
    @events << "report_result"
  end

  def report_summary(results)
    @events << "report_summary"
  end

  def report_msi(results)
    @events << "report_msi"
  end
end

private class FakeGenerator < Crytic::Generator
  def mutations_for(source : String, specs : Array(String))
    [] of Crytic::Mutation::Mutation
  end
end
