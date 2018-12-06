require "../src/crytic/autofind_runner"
require "./fake_reporter"
require "./fake_generator"
require "./spec_helper"

describe Crytic::AutofindRunner do
  describe "#run" do
    it "reports events in order" do
      reporter = FakeReporter.new
      runner = Crytic::AutofindRunner.new(
        generator: FakeGenerator.new,
        reporter: reporter)

      runner.run

      reporter.events.should eq ["report_original_result", "report_summary", "report_msi"]
    end
  end
end
