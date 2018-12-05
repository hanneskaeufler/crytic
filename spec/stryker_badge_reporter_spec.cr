require "../src/crytic/mutant/number_literal_change"
require "../src/crytic/mutation/result"
require "../src/crytic/reporter/http_client"
require "../src/crytic/stryker_badge_reporter"
require "./spec_helper"
require "json"

module Crytic::Reporter
  describe StrykerBadgeReporter do
    describe "#report_msi" do
      it "posts to the stryker dashboard" do
        client = FakeClient.new

        StrykerBadgeReporter.new(client).report_msi(results)

        client.path.should eq "https://dashboard.stryker-mutator.io/api/reports"
        client.body.should eq({
          "apiKey" => "apikey",
          "repositorySlug" => "repo",
          "branch" => "branch",
          "mutationScore" => 75.9
        })
      end
    end
  end
end

class FakeClient < Crytic::Reporter::HttpClient
  getter! path : String
  getter! body : Hash(String, String | Float64)

  def post(url, body)
    @path = url
    @body = body
  end
end

private def fake_mutant
  Crytic::Mutant::NumberLiteralChange.at(
    Crystal::Location.new(filename: nil, line_number: 0, column_number: 0))
end

private def results
  [Crytic::Mutation::Result.new(
    status: Crytic::Mutation::Status::Covered,
    mutant: fake_mutant,
    diff: "")]
end
