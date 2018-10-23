require "../../src/crytic/mutation/original_result"
require "../../src/crytic/mutation/result"
require "../../src/crytic/reporter/json_reporter"
require "spec"

module Crytic::Reporter
  describe JsonReporter do
    describe "#report_original_result" do
      it "saves an original result" do
        result = Mutation::OriginalResult.new(0, "output")
        reporter = JsonReporter.new

        reporter.report_original_result(result)

        reporter.to_json.should eq({
          "original" => { "success" => true, "output" => "output" }}.to_json)
      end
    end

    describe "#report_result" do
      it "appends to the result hash" do
        result = Mutation::Result.new(Mutation::Result::Status::COVERED
        reporter = JsonReporter.new

        reporter.report_original_result(result)

        reporter.to_json["results"].size.should eq 1
      end
    end
  end
end
