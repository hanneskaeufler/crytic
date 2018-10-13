require "compiler/crystal/syntax/*"

module Crytic
  class Source < Crystal::Visitor
    private getter source

    def initialize(@source : String, @mutant : Mutant::Mutant)
    end

    def original_source
      source
    end

    def mutated_source
      abstract_syntax_tree = Crystal::Parser.parse(source)
      abstract_syntax_tree.accept(@mutant)
      abstract_syntax_tree.to_s
    end
  end

  module Mutant
    abstract class Mutant < Crystal::Visitor
    end

    class NumberLiteralSignFlip < Mutant
      def visit(node : Crystal::NumberLiteral)
        node.value = "-#{node.value}"
        true
      end

       # Ignore other nodes for now
      def visit(node : Crystal::ASTNode)
        true
      end
    end

    class NumberLiteralChange < Mutant
      def visit(node : Crystal::NumberLiteral)
        node.value = "#{node.value}1"
        true
      end

       # Ignore other nodes for now
      def visit(node : Crystal::ASTNode)
        true
      end
    end

    class ConditionFlip < Mutant
      def visit(node : Crystal::If)
        tmp = node.else
        node.else = node.then
        node.then = tmp
        node

        true
      end

       # Ignore other nodes for now
      def visit(node : Crystal::ASTNode)
        true
      end
    end
  end
end

source = <<-SOURCE
require "spec"

def bar
  if 1
    2
  else
    3
  end
end

describe "bar" do
  it "works" do
    bar.should eq 2
  end
end
SOURCE

module Crytic
  class Runner
    def initialize()
      @io = IO::Memory.new
    end

    def run(source : String)
      original_source = source

      mutated_source1 = Crytic::Source.new(source, Crytic::Mutant::ConditionFlip.new)
        .mutated_source

      mutated_source2 = Crytic::Source.new(source, Crytic::Mutant::NumberLiteralChange.new)
        .mutated_source
      puts mutated_source2

      mutated_source3 = Crytic::Source.new(source, Crytic::Mutant::NumberLiteralSignFlip.new)
        .mutated_source
      puts mutated_source3

      results = [
        Process.run("crystal", ["eval", original_source], output: @io, error: STDERR),
        Process.run("crystal", ["eval", mutated_source1], output: @io, error: STDERR),
        Process.run("crystal", ["eval", mutated_source2], output: @io, error: STDERR),
        Process.run("crystal", ["eval", mutated_source3], output: @io, error: STDERR),
      ]

      puts "Ran original suite: #{results.first.exit_code == 0 ? "Passed" : "Failed"}\n Mutations covered by tests:\n    #{results[1..-1].map { |res| res.exit_code == 0 ? "F" : "." }.join("")}"
    end
  end
end

Crytic::Runner.new.run(source)
