module Crytic
  abstract class HttpClient
    abstract def post(url, body : Hash(String, String | Float64))
  end

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
