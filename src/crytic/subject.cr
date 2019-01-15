require "./diff"
require "./mutant/mutant"
require "compiler/crystal/syntax/*"

module Crytic
  alias SourceCode = String

  class Subject
    getter original_source : SourceCode
    getter! mutated_source : SourceCode
    private getter ast : Crystal::ASTNode

    def self.from_filepath(subject_file_path : String)
      new(source: File.read(subject_file_path),
          subject_file_path: subject_file_path)
    end

    def initialize(@source : SourceCode, subject_file_path : String)
      @ast = Crystal::Parser
        .new(@source)
        .tap { |p| p.filename = subject_file_path }
        .parse
      @original_source = ast.to_s
    end

    def mutate_source!(mutant : Crystal::Transformer) : SourceCode
      @mutated_source ||= ast.transform(mutant).to_s
    end

    def mutate_source!(mutant : Crystal::Visitor) : SourceCode
      ast.accept(mutant)
      @mutated_source ||= ast.to_s
    end

    def diff
      Crytic::Diff.unified_diff(original_source, mutated_source).to_s
    end
  end
end
