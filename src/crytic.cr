require "./crytic/cli"
require "./crytic/side_effects"
require "./crytic/process_process_runner"

success = !Crytic::Cli
  .new(Crytic::SideEffects.new(STDOUT, STDERR, ->(code : Int32) { exit(code) }, {
    # manually map from ENV to a Hash because I am unable to conform ENV
    # to anything that I can replace with a stub in the tests
    "CIRCLE_BRANCH"             => ENV["CIRCLE_BRANCH"]? || "",
    "CIRCLE_PROJECT_REPONAME"   => ENV["CIRCLE_PROJECT_REPONAME"]? || "",
    "CIRCLE_PROJECT_USERNAME"   => ENV["CIRCLE_PROJECT_USERNAME"]? || "",
    "STRYKER_DASHBOARD_API_KEY" => ENV["STRYKER_DASHBOARD_API_KEY"]? || "",
  }, Crytic::ProcessProcessRunner.new,
    ->File.delete(String),
    ->(name : String, extension : String, content : String) {
      File.tempfile(name, extension, &.print(content)).path
    }))
  .run(ARGV)

exit(success.to_unsafe)
