require "./command/*"
require "./runner/parallel"
require "./runner/sequential"
require "./side_effects"

module Crytic
  # Main entrypoint for the crytic program. Delegates to the chosen command.
  class Cli
    def initialize(@side_effects : SideEffects)
    end

    def run(args)
      case args.first?
      when "test"
        Command::Test.new(Runner::Sequential.new, @side_effects).execute(args.tap(&.shift))
      when "test-parallel"
        Command::Test.new(Runner::Parallel.new, @side_effects).execute(args.tap(&.shift))
      when "noop"
        Command::Noop
          .new(@side_effects, Command::Noop::DEFAULT_SPEC_FILES_GLOB)
          .execute(args.tap(&.shift))
      else
        Command::Test.new(Runner::Sequential.new, @side_effects).execute(args)
      end
    end
  end
end
