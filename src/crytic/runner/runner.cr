require "../side_effects"
require "./run"

module Crytic::Runner
  abstract class Runner
    abstract def run(run : Run, side_effects : SideEffects) : Bool
  end
end
