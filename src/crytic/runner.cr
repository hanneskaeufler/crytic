require "./source"
require "./mutant/**"

module Crytic
  class Runner
    MUTANTS = [
      Mutant::ConditionFlip.new,
      Mutant::NumberLiteralChange.new,
      Mutant::NumberLiteralSignFlip.new
    ]

    def initialize()
      @io = IO::Memory.new
    end

    def run(sources : Array(String), specs : Array(String)) : Bool
      original_source = File.read(sources.first)
      original_source = "#{original_source}#{specs.map { |spec_file| File.read(spec_file) }.join("\n")}"

      original_result = Process.run("crystal", ["eval", original_source],
                                    output: @io,
                                    error: STDERR)

      results = MUTANTS.map do |mutant|
        Process.run("crystal", ["eval", Source.new(original_source, mutant).mutated_source], output: @io, error: STDERR)
      end

      puts "Ran original suite: #{original_result.exit_code == 0 ? "Passed" : "Failed"}\n Mutations covered by tests:\n    #{results.map { |res| res.exit_code == 0 ? "F" : "." }.join("")}"

      return results.map(&.exit_code).sum > 0
    end
  end
end
