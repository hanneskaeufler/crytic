require "./command/test"
require "./side_effects"

module Crytic
  # Main entrypoint for the crytic program. Delegates to the chosen command.
  class Cli
    def initialize(@side_effects : SideEffects)
    end

    def run(args)
      args = args.tap(&.shift) if args.first? == "test"
      Command::Test.new(@side_effects.std_out, @side_effects.std_err, @side_effects.exit_fun, @side_effects.env).execute(args)
    end
  end
end
