require "../msi_calculator"
require "./http_client"
require "./reporter"
require "http/status"

module Crytic::Reporter
  # Sends a MSI score to the stryker dashboard
  # See also https://infection.github.io/guide/mutation-badge.html
  class StrykerBadgeReporter < Reporter
    private DASHBOARD_URL = "https://dashboard.stryker-mutator.io/api/reports"

    def initialize(@client : HttpClient, @env : Hash(String, String), @io : IO)
    end

    def report_msi(results)
      if results.empty?
        @io << "Mutation score wasn't uploaded to stryker dashboard. No results found.\n"
        return
      end

      response = @client.post(DASHBOARD_URL, {
        "apiKey"         => @env["STRYKER_DASHBOARD_API_KEY"],
        "repositorySlug" => slug,
        "branch"         => @env["CIRCLE_BRANCH"],
        "mutationScore"  => score(results),
      })

      print_status(response)
    end

    def report_original_result(original_result)
    end

    def report_mutations(mutations)
    end

    def report_neutral_result(result)
    end

    def report_result(result)
    end

    def report_summary(results)
    end

    private def slug
      "github.com/#{@env["CIRCLE_PROJECT_USERNAME"]}/#{@env["CIRCLE_PROJECT_REPONAME"]}"
    end

    private def score(results)
      MsiCalculator.new(results).msi.value
    end

    private def print_status(response)
      if response.status == HTTP::Status::CREATED
        @io << "Mutation score uploaded to stryker dashboard.\n"
      else
        @io << "Mutation score wasn't uploaded to stryker dashboard. Response status encountered: #{response.status}\n"
      end
    end
  end
end
