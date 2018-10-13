require "./source"
require "./mutant/**"

module Crytic
  class ReplaceSubjectRequireBySubjectContent < Crystal::Visitor
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
        spec_code.accept(ReplaceSubjectRequireBySubjectContent.new(source, spec_file))
        spec_code.to_s
      end.join("\n")

      original_result = Process.run("crystal", ["eval", fixed_specs_source],
                                    output: @io,
                                    error: STDERR)

      return original_result.exit_code == 0
      # pp original_result

      # original_source = File.read(source)
      # results = MUTANTS.map do |mutant|
      #   mutated_source = Source.new(original_source, mutant).mutated_source
      #   full_source = "#{mutated_source}#{specs_source}"

      #   puts full_source
      #   Process.run("crystal", ["eval", full_source], output: @io, error: STDERR)
      # end

      # puts "Ran original suite: #{original_result.exit_code == 0 ? "Passed" : "Failed"}\n Mutations covered by tests:\n    #{results.map { |res| res.exit_code == 0 ? "F" : "." }.join("")}"

      # return results.map(&.exit_code).sum > 0
    end
  end
end
