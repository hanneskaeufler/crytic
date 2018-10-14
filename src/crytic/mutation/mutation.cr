require "../mutant/mutant"
require "./diff"
require "./inject_mutated_subject_into_specs"
require "./result"
require "../source"

module Crytic::Mutation
  abstract class ProcessRunner
    abstract def run(cmd : String, args, output, error)
  end

  class ProcessProcessRunner < ProcessRunner
    def run(cmd, args, output, error)
      Process.run(cmd, args, output: output, error: error).exit_code
    end
  end

  class Mutation
    property process_runner
    @process_runner : ProcessRunner

    private def initialize(
      @mutant : Crytic::Mutant::Mutant,
      @subject_file_path : String,
      @specs_file_paths : Array(String))
      @io = IO::Memory.new
      @process_runner = ProcessProcessRunner.new
    end

    def run
      subject_source = File.read(@subject_file_path)
      mutated_source = Source.new(subject_source, @mutant).mutated_source
      source_diff = Diff.new(subject_source, mutated_source).to_s

      Result.new(
        is_covered: run_process(mutated_source) != 0,
        mutant: @mutant,
        diff: source_diff)
    end

    def self.with(mutant : Mutant::Mutant, original : String, specs : Array(String) )
      new(mutant, original, specs)
    end

    private def run_process(mutated_source)
      process_runner.run(
        "crystal", ["eval", mutated_specs_source(mutated_source)],
        output: @io,
        error: STDERR)
    end

    private def mutated_specs_source(mutated_source)
      @specs_file_paths.map do |spec_file|
        spec_code = Crystal::Parser.parse(File.read(spec_file))
        spec_code.accept(InjectMutatedSubjectIntoSpecs.new(@subject_file_path, spec_file))
        spec_code.to_s
      end.join("\n").gsub(/require "PUTMEHERE"/, "\n#{mutated_source}\n")
    end
  end
end
