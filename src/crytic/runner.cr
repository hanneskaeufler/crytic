require "uuid"
require "./source"
require "./mutant/**"

module Crytic
  class AdaptLocalRequirePathsToCurrentWorkingDir < Crystal::Visitor
    def initialize(@subject_path : String, @spec_path : String)
    end

    def visit(node : Crystal::Require)
      # only care for locally required files, not modules / shards
      return true unless node.string[0..1] == "./"

      if required_file(node) == @subject_path
        node.string = @subject_path
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

  class Runner
    MUTANTS = [
      Mutant::ConditionFlip.new,
      # Mutant::NumberLiteralChange.new,
      # Mutant::NumberLiteralSignFlip.new
    ]

    def initialize()
      @io = IO::Memory.new
    end

    def run(source : String, specs : Array(String)) : Bool
      fixed_specs_source = specs.map do |spec_file|
        spec_code = Crystal::Parser.parse(File.read(spec_file))
        spec_code.accept(AdaptLocalRequirePathsToCurrentWorkingDir.new(source, spec_file))
        spec_code.to_s
      end.join("\n")

      original_result = Process.run("crystal", ["eval", fixed_specs_source],
                                    output: @io,
                                    error: STDERR)

      # return original_result.exit_code == 0
      # pp original_result

      uuid = UUID.random

      results = MUTANTS.map do |mutant|
        mutated_source = Source.new(File.read(source), mutant).mutated_source
        mutated_specs_source = specs.map do |spec_file|
          spec_code = Crystal::Parser.parse(File.read(spec_file))
          spec_code.accept(InjectMutatedSubjectIntoSpecs.new(source, spec_file, uuid))
          spec_code.to_s
        end.join("\n").gsub(/require "PUTMEHERE"/, "\n#{mutated_source}\n")

        puts mutated_specs_source

        Process.run("crystal", ["eval", mutated_specs_source], output: @io, error: STDERR)
      end

      puts "Ran original suite: #{original_result.exit_code == 0 ? "Passed" : "Failed"}\n Mutations covered by tests:\n    #{results.map { |res| res.exit_code == 0 ? "F" : "." }.join("")}"

      return results.map(&.exit_code).sum > 0
    end
  end

  class InjectMutatedSubjectIntoSpecs < Crystal::Visitor
    def initialize(@subject_path : String, @spec_path : String, @uuid : UUID)
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
