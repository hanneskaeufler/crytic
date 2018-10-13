require "../mutant/mutant"
require "./diff"
require "./inject_mutated_subject_into_specs"
require "./result"

module Crytic::Mutation
  class Mutation
    private def initialize(
      @mutant : Crytic::Mutant::Mutant,
      @subject_file_path : String,
      @specs_file_paths : Array(String))
      @io = IO::Memory.new
    end

    def run
      subject_source = File.read(@subject_file_path)
      mutated_source = Source.new(subject_source, @mutant).mutated_source
      source_diff = Diff.new(subject_source, mutated_source).to_s

      unless @mutant.did_apply?
        return Result.new(is_covered: false, mutant: @mutant, diff: source_diff)
      end

      mutated_specs_source = @specs_file_paths.map do |spec_file|
        spec_code = Crystal::Parser.parse(File.read(spec_file))
        spec_code.accept(InjectMutatedSubjectIntoSpecs.new(@subject_file_path, spec_file))
        spec_code.to_s
      end.join("\n").gsub(/require "PUTMEHERE"/, "\n#{mutated_source}\n")

      # puts mutated_specs_source

      res = Process.run("crystal", ["eval", mutated_specs_source], output: @io, error: STDERR)
      Result.new(is_covered: res.exit_code != 0, mutant: @mutant, diff: source_diff)
    end

    def self.with(mutant : Mutant::Mutant, original : String, specs : Array(String) )
      new(mutant, original, specs)
    end
  end
end
