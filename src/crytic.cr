require "./crytic/runner"

io = IO::Memory.new
success = Crytic::Runner.new(io).run(
        "./spec/fixtures/conditionals/fully_covered.cr",
        [
          "./spec/fixtures/conditionals/uncovered_spec.cr"
        ]
  # "./spec/fixtures/simple/bar.cr",
  # [
  #   "./spec/fixtures/simple/bar_spec.cr"
  # ]
)
puts io.to_s

exit(success ? 0 : 1)
