require "./generator"
require "./io_reporter"
require "./mutant/**"
require "./mutation/mutation"
require "./mutation/no_mutation"
require "./source"

module Crytic
  class Runner
    MUTANT_POSSIBILITIES = [
      Mutant::ConditionFlipPossibilities.new,
      Mutant::NumberLiteralChangePossibilities.new,
      Mutant::NumberLiteralSignFlipPossibilities.new,
      Mutant::BoolLiteralFlipPossibilities.new,
    ]

    def initialize(@io = IO::Memory.new)
    end

    def run(source : String, specs : Array(String)) : Bool
      validate_args!(source, specs)

      original_result = Mutation::NoMutation
        .with(specs: specs)
        .run

      if original_result.exit_code != 0
        @io << "❌ Original test suite failed.\n"
        @io << original_result.output

        return false
      end

      results = Generator
        .new
        .mutations_for(source: source, specs: specs)
        .map(&.run)

      IoReporter
        .new(@io)
        .report(original_result, results)

      return results.map(&.successful?).all?
    end

    private def validate_args!(source, specs)
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
    end
  end
end
