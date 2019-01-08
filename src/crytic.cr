require "./crytic/generator/in_memory_generator"
require "./crytic/reporter/http_client"
require "./crytic/reporter/io_reporter"
require "./crytic/reporter/stryker_badge_reporter"
require "./crytic/runner"
require "option_parser"

subject_source = ""
msi_threshold = 100.0
spec_files = [] of String

OptionParser.parse! do |parser|
  parser.banner = "Usage: crytic [arguments]"
  parser.on("-s SOURCE", "--subject=SOURCE", "Specifies the source file for the subject") do |source|
    subject_source = source
  end
  parser.on("-m", "--min-msi=THRESHOLD", "Crytic will exit with zero if this threshold is reached.") do |threshold|
    msi_threshold = threshold.to_f
  end
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit(0)
  end
  parser.unknown_args { |args| spec_files = args }
  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

reporters = [Crytic::Reporter::IoReporter.new(STDOUT)] of Crytic::Reporter::Reporter

if ENV["STRYKER_DASHBOARD_API_KEY"]?
  client = Crytic::Reporter::DefaultHttpClient.new
  reporters << Crytic::Reporter::StrykerBadgeReporter.new(client, {
    # manually map from ENV to a Hash because I am unable to conform ENV
    # to anything that I can replace with a stub in the tests
    "CIRCLE_BRANCH"             => ENV["CIRCLE_BRANCH"],
    "CIRCLE_PROJECT_REPONAME"   => ENV["CIRCLE_PROJECT_REPONAME"],
    "CIRCLE_PROJECT_USERNAME"   => ENV["CIRCLE_PROJECT_USERNAME"],
    "STRYKER_DASHBOARD_API_KEY" => ENV["STRYKER_DASHBOARD_API_KEY"],
  }, STDOUT)
end

if subject_source.empty?
  subject_source = Dir["./src/**/*.cr"]
end

if spec_files.empty?
  spec_files = Dir["./spec/**/*_spec.cr"]
end

success = Crytic::Runner
  .new(msi_threshold, reporters, Crytic::InMemoryMutationsGenerator.new)
  .run(subject_source, spec_files)

exit(success ? 0 : 1)
