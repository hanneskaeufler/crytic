require "./diff"
require "./mutant/mutant"
require "./mutant/possibilities"
require "compiler/crystal/syntax/*"

module Crytic
  alias SourceCode = String

  class Subject
    private getter ast : Crystal::ASTNode

    def self.from_filepath(subject_file_path : String)
      new(File.read(subject_file_path), subject_file_path)
    end

    def initialize(source : SourceCode, path)
      @ast = Crystal::Parser
        .new(source)
        .tap(&.filename = path)
        .parse
    end

    def mutated(mutant : Crystal::Transformer)
      MutatedSubject.new(ast.to_s, ast.transform(mutant).to_s)
    end

    def mutated(mutant : Crystal::Visitor)
      new_ast = ast.clone
      new_ast.accept(mutant)
      MutatedSubject.new(ast.to_s, new_ast.to_s)
    end

    def inspect(inspectors : Array(Mutant::Possibilities))
      inspectors
        .map(&.reset)
        .tap(&.each { |inspector| ast.accept(inspector) })
    end
  end

  record MutatedSubject, original_source_code : String, source_code : String do
    def diff
      Crytic::Diff.unified_diff(original_source_code, source_code).to_s
    end
  end
end
