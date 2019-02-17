require "./crytic/cli_options"
require "./crytic/generator/in_memory_generator"
require "./crytic/generator/isolated_mutation_factory"
require "./crytic/runner/sequential"

options = Crytic::CliOptions
  .new(STDOUT, STDERR, ->(code : Int32) { exit(code) }, {
  # manually map from ENV to a Hash because I am unable to conform ENV
  # to anything that I can replace with a stub in the tests
  "CIRCLE_BRANCH"             => ENV["CIRCLE_BRANCH"]? || "",
  "CIRCLE_PROJECT_REPONAME"   => ENV["CIRCLE_PROJECT_REPONAME"]? || "",
  "CIRCLE_PROJECT_USERNAME"   => ENV["CIRCLE_PROJECT_USERNAME"]? || "",
  "STRYKER_DASHBOARD_API_KEY" => ENV["STRYKER_DASHBOARD_API_KEY"]? || "",
})
  .parse(ARGV)

generator = Crytic::Generator::InMemoryMutationsGenerator.new(
  options.mutants,
  options.preamble,
  ->Crytic::Generator.isolated_mutation_factory(Crytic::Mutation::Config))

success = !Crytic::Runner::Sequential
  .new(options.msi_threshold, options.reporters, generator)
  .run(options.subject, options.spec_files)

exit(success.to_unsafe)
