require "./reporter/http_client"

module Crytic::Reporter
  # Sends a MSI score to the stryker dashboard
  # See also https://infection.github.io/guide/mutation-badge.html
  class StrykerBadgeReporter
    private DASHBOARD_URL = "https://dashboard.stryker-mutator.io/api/reports"

    def initialize(@client : HttpClient)
    end

    def report_msi(results)
      @client.post(DASHBOARD_URL, {
        "apiKey" => "apikey",
        "repositorySlug" =>  "repo",
        "branch"=> "branch",
        "mutationScore"=> 75.9,
      })
    end
  end
end
