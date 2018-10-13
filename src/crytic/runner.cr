require "./source"
require "./mutant/**"

module Crytic
  class Runner
    def initialize()
      @io = IO::Memory.new
    end

    def run(source : String) : Bool
      original_source = source

      mutated_source1 = Crytic::Source.new(source, Crytic::Mutant::ConditionFlip.new)
        .mutated_source

      mutated_source2 = Crytic::Source.new(source, Crytic::Mutant::NumberLiteralChange.new)
        .mutated_source
      puts mutated_source2

      mutated_source3 = Crytic::Source.new(source, Crytic::Mutant::NumberLiteralSignFlip.new)
        .mutated_source

      results = [
        Process.run("crystal", ["eval", original_source], output: @io, error: STDERR),
        Process.run("crystal", ["eval", mutated_source1], output: @io, error: STDERR),
        Process.run("crystal", ["eval", mutated_source2], output: @io, error: STDERR),
        Process.run("crystal", ["eval", mutated_source3], output: @io, error: STDERR),
      ]

      puts "Ran original suite: #{results.first.exit_code == 0 ? "Passed" : "Failed"}\n Mutations covered by tests:\n    #{results[1..-1].map { |res| res.exit_code == 0 ? "F" : "." }.join("")}"

      return results.map(&.exit_code).sum > 0
    end
  end
end
