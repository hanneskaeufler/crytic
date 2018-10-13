require "./inject_mutated_subject_into_specs"
require "../mutant/mutant"

module Crytic
  class Mutation
    private def initialize(
      @mutant : Mutant::Mutant,
      @subject_file_path : String,
      @specs_file_paths : Array(String))
      @io = IO::Memory.new
    end

    def run
      mutated_source = Source.new(File.read(@subject_file_path), @mutant).mutated_source
      return Result.new(is_covered: false, mutant: @mutant) unless @mutant.did_apply?

      mutated_specs_source = @specs_file_paths.map do |spec_file|
        spec_code = Crystal::Parser.parse(File.read(spec_file))
        spec_code.accept(InjectMutatedSubjectIntoSpecs.new(@subject_file_path, spec_file))
        spec_code.to_s
      end.join("\n").gsub(/require "PUTMEHERE"/, "\n#{mutated_source}\n")

      puts mutated_specs_source

      res = Process.run("crystal", ["eval", mutated_specs_source], output: @io, error: STDERR)
      Result.new(is_covered: res.exit_code != 0, mutant: @mutant)
    end

    def self.with(mutant : Mutant::Mutant, original : String, specs : Array(String) )
      new(mutant, original, specs)
    end
  end

  record Result, is_covered : Bool, mutant : Mutant::Mutant do
    def mutant_name
      mutant.class.to_s.split("::").last
    end

    def applicable
      mutant.did_apply?
    end
  end
end

