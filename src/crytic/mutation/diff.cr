require "diff"
require "colorize"

module Crytic::Mutation
  class Diff
    def initialize(@original : String, @mutated : String)
    end

    def to_s
      io = IO::Memory.new
      ::Diff.diff(@original, @mutated).each do |chunk|
        io << chunk.data.colorize(
          chunk.append? ? :green : chunk.delete? ? :red : :dark_gray)
        io << "\n"
      end

      io.to_s
    end
  end
end
