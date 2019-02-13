require "./crytic/cli_options"
require "./crytic/generator/in_memory_generator"
require "./crytic/reporter/http_client"
require "./crytic/reporter/io_reporter"
require "./crytic/reporter/stryker_badge_reporter"
require "./crytic/runner"

options = Crytic::CliOptions
  .new(STDOUT, STDERR, ->(code : Int32) { exit(code) })
  .parse(ARGV)

reporters = [Crytic::Reporter::IoReporter.new(STDOUT)] of Crytic::Reporter::Reporter

if (key = ENV["STRYKER_DASHBOARD_API_KEY"]?) && !key.empty?
  client = Crytic::Reporter::DefaultHttpClient.new
  reporters << Crytic::Reporter::StrykerBadgeReporter.new(client, {
    # manually map from ENV to a Hash because I am unable to conform ENV
    # to anything that I can replace with a stub in the tests
    "CIRCLE_BRANCH"             => ENV["CIRCLE_BRANCH"],
    "CIRCLE_PROJECT_REPONAME"   => ENV["CIRCLE_PROJECT_REPONAME"],
    "CIRCLE_PROJECT_USERNAME"   => ENV["CIRCLE_PROJECT_USERNAME"],
    "STRYKER_DASHBOARD_API_KEY" => key,
  }, STDOUT)
end

generator = Crytic::Generator::InMemoryMutationsGenerator.new(
  Crytic::Generator::InMemoryMutationsGenerator::ALL_MUTANTS,
  options.preamble)

success = !Crytic::Runner
  .new(options.msi_threshold, reporters, generator)
  .run(options.subject, options.spec_files)

exit(success.to_unsafe)
