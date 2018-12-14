require "../../src/crytic/mutant/number_literal_change"
require "../../src/crytic/mutation/result"
require "../../src/crytic/reporter/http_client"
require "../../src/crytic/reporter/stryker_badge_reporter"
require "../spec_helper"
require "json"

module Crytic::Reporter
  describe StrykerBadgeReporter do
    describe "#report_msi" do
      it "posts to the stryker dashboard" do
        client = FakeClient.new
        io = IO::Memory.new

        StrykerBadgeReporter.new(client, {
          "CIRCLE_BRANCH"             => "master",
          "CIRCLE_PROJECT_REPONAME"   => "crytic",
          "CIRCLE_PROJECT_USERNAME"   => "hanneskaeufler",
          "STRYKER_DASHBOARD_API_KEY" => "apikey",
        }, io).report_msi(results)

        client.path.should eq "https://dashboard.stryker-mutator.io/api/reports"
        client.body.should eq({
          "apiKey"         => "apikey",
          "branch"         => "master",
          "mutationScore"  => 100.0,
          "repositorySlug" => "github.com/hanneskaeufler/crytic",
        })
        io.to_s.should eq "Mutation score uploaded to stryker dashboard."
      end
    end
  end
end

private class FakeClient < Crytic::Reporter::HttpClient
  def post(url : String, bbody : Hash(String, String | Float64))
    @path = url
    @body = bbody
  end

  def path
    @path
  end

  def body
    @body
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
