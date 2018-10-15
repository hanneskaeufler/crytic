require "diff"
require "colorize"

module Crytic::Mutation
  class Diff
    def initialize(@original : String, @mutated : String)
    end

    def to_s
      ::Diff.unified_diff(@original, @mutated)
    end
  end
end
