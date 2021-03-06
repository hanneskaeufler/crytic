require "../../src/crytic/mutant/number_literal_change"
require "../../src/crytic/mutation/result"
require "../../src/crytic/reporter/stryker_badge_reporter"
require "../spec_helper"
require "json"

module Crytic::Reporter
  describe StrykerBadgeReporter do
    describe "#report_msi" do
      it "posts to the stryker dashboard" do
        client = FakeHttpClient.new
        io = IO::Memory.new

        client.response.status = HTTP::Status::CREATED
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
        io.to_s.should eq "Mutation score uploaded to stryker dashboard.\n"
      end

      it "reports NaN score as " do
        client = FakeHttpClient.new
        io = IO::Memory.new
        subject = StrykerBadgeReporter.new(client, fake_env, io)

        subject.report_msi(Mutation::ResultSet.new([] of Mutation::Result))

        io.to_s.should eq "Mutation score wasn't uploaded to stryker dashboard. No results found.\n"
        client.path.should be_nil
      end

      it "reports a failed http request" do
        client = FakeHttpClient.new
        io = IO::Memory.new
        subject = StrykerBadgeReporter.new(client, fake_env, io)

        client.response.status = HTTP::Status::UNAUTHORIZED
        subject.report_msi(results)

        io.to_s.should eq "Mutation score wasn't uploaded to stryker dashboard. Response status encountered: UNAUTHORIZED\n"
      end
    end
  end
end

private def results
  Crytic::Mutation::ResultSet.new([result])
end
