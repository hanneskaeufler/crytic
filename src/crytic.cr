require "./crytic/runner"

io = IO::Memory.new
success = Crytic::Runner.new(io).run(
        "./fixtures/conditionals/fully_covered.cr",
        [
          "./fixtures/conditionals/uncovered_spec.cr"
        ]
  # "./fixtures/simple/bar.cr",
  # [
  #   "./fixtures/simple/bar_spec.cr"
  # ]
)
puts io.to_s

exit(success ? 0 : 1)
