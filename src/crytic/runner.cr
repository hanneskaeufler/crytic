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
        .with(original: source, specs: specs)
        .run

      if original_result.exit_code != 0
        @io << "❌ Original test suite failed.\n"

        return false
      end

      ast = Crystal::Parser.parse(File.read(source))

      results = MUTANT_POSSIBILITIES.map do |inspector|
        ast.accept(inspector)
        inspector
      end.select(&.any?).map do |inspector|
        inspector.locations.map do |location|
          mutant = inspector.mutant_class.at(location: location)
          Mutation::Mutation
            .with(mutant: mutant, original: source, specs: specs)
            .run
        end
      end.flatten

      IoReporter
        .new(@io)
        .report(original_result, results)

      return results.map(&.is_covered).all?
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
