require "./command/*"
require "./side_effects"

module Crytic
  # Main entrypoint for the crytic program. Delegates to the chosen command.
  class Cli
    def initialize(@side_effects : SideEffects)
    end

    def run(args)
      args = args.tap(&.shift) if args.first? == "test"
      case args.first?
      when "test"
        test_command.execute(args.tap(&.shift))
      when "noop"
        Command::Noop
          .new(@std_out, @std_err, Command::Noop::DEFAULT_SPEC_FILES_GLOB)
          .execute(args.tap(&.shift))
      else
        test_command.execute(args)
      end
    end

    private def test_command
      Command::Test.new(@side_effects.std_out, @side_effects.std_err, @side_effects.exit_fun, @side_effects.env)
    end
  end
end
