require "./msi_calculator"
require "./reporter/http_client"

module Crytic::Reporter
  # Sends a MSI score to the stryker dashboard
  # See also https://infection.github.io/guide/mutation-badge.html
  class StrykerBadgeReporter
    private DASHBOARD_URL = "https://dashboard.stryker-mutator.io/api/reports"

    def initialize(@client : HttpClient, @env : Hash(String, String) = ENV)
    end

    def report_msi(results)
      @client.post(DASHBOARD_URL, {
        "apiKey"         => @env["STRYKER_DASHBOARD_API_KEY"],
        "repositorySlug" => slug,
        "branch"         => "master",
        "mutationScore"  => score(results),
      })
    end

    private def slug
      "github.com/#{@env["CIRCLE_PROJECT_USERNAME"]}/#{@env["CIRCLE_PROJECT_REPONAME"]}"
    end

    private def score(results)
      MsiCalculator.new(results).msi
    end
  end
end
