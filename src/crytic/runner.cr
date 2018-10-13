require "./io_reporter"
require "./mutant/**"
require "./mutation/mutation"
require "./mutation/no_mutation"
require "./source"

module Crytic
  class Runner
    MUTANTS = [
      Mutant::ConditionFlip.new,
      Mutant::NumberLiteralChange.new,
      Mutant::NumberLiteralSignFlip.new,
      Mutant::BoolLiteralFlip.new,
    ]

    def initialize(@io = IO::Memory.new)
    end

    def run(source : String, specs : Array(String)) : Bool
      if specs.empty?
        raise ArgumentError.new("No spec files given.")
      end

      unless File.exists?(source)
        raise ArgumentError.new("Source file for subject doesn't exist.")
      end

      specs.each do |spec_file|
        unless File.exists?(spec_file)
          raise ArgumentError.new("Spec file #{spec_file} doesn't exist.")
        end
      end

      original_result = Mutation::NoMutation.with(original: source, specs: specs).run
      # return original_result.exit_code == 0
      # pp original_result

      results = MUTANTS.map do |mutant|
        Mutation::Mutation.with(mutant: mutant, original: source, specs: specs).run
      end.select(&.applicable)

      IoReporter.new(@io).report(original_result, results)

      return results.map(&.is_covered).all?
    end
  end
end
