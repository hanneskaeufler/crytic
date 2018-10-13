require "./crytic/runner"

success = Crytic::Runner.new.run(
  [
    "spec/fixtures/simple/bar.cr"
  ],
  [
    "spec/fixtures/simple/bar_spec.cr"
  ]
)

exit(success ? 0 : 1)
