require "./mutant/mutant"

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
      mutated_specs_source = @specs_file_paths.map do |spec_file|
        spec_code = Crystal::Parser.parse(File.read(spec_file))
        spec_code.accept(InjectMutatedSubjectIntoSpecs.new(@subject_file_path, spec_file))
        spec_code.to_s
      end.join("\n").gsub(/require "PUTMEHERE"/, "\n#{mutated_source}\n")

      puts mutated_specs_source

      Process.run("crystal", ["eval", mutated_specs_source], output: @io, error: STDERR)
    end

    def self.with(mutant : Mutant::Mutant, original : String, specs : Array(String) )
      new(mutant, original, specs)
    end
  end

  class InjectMutatedSubjectIntoSpecs < Crystal::Visitor
    def initialize(@subject_path : String, @spec_path : String)
    end

    def visit(node : Crystal::Require)
      # only care for locally required files, not modules / shards
      return true unless node.string[0..1] == "./"

      if required_file(node) == @subject_path
        node.string = "PUTMEHERE"
      end

      true
    end

    # Ignore other nodes for now
    def visit(node : Crystal::ASTNode)
      true
    end

    private def required_file(node)
      "#{File.dirname(@spec_path)}/#{node.string.[2..-1]}.cr"
    end
  end
end

